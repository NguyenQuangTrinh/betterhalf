import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum CyclePhase {
  menstruation, // Period days
  follicular, // After period, before ovulation
  ovulation, // Fertile window
  luteal, // After ovulation, before next period (PMS)
}

class CycleLogic {
  // Constants
  static const int defaultCycleLength = 28;
  static const int defaultPeriodLength = 5;
  static const int lutealPhaseLength = 14; // Usually constant

  /// Calculate average cycle length from history
  /// Returns [defaultCycleLength] if not enough data
  static int calculateAverageCycleLength(List<Map<String, dynamic>> logs) {
    if (logs.length < 2) return defaultCycleLength;

    int totalDays = 0;
    int count = 0;

    // Sort logs by date descending just in case, but usually they come sorted
    // Logic: Distance between Start Date of adjacent cycles
    for (int i = 0; i < logs.length - 1; i++) {
      DateTime? currentStart;
      if (logs[i]['startDate'] is Timestamp) {
        currentStart = (logs[i]['startDate'] as Timestamp).toDate();
      } else if (logs[i]['startDate'] is DateTime) {
        currentStart = logs[i]['startDate'] as DateTime;
      }

      DateTime? prevStart;
      if (logs[i + 1]['startDate'] is Timestamp) {
        prevStart = (logs[i + 1]['startDate'] as Timestamp).toDate();
      } else if (logs[i + 1]['startDate'] is DateTime) {
        prevStart = logs[i + 1]['startDate'] as DateTime;
      }

      if (currentStart != null && prevStart != null) {
        final diff = currentStart.difference(prevStart).inDays;
        // Filter out absurdly short or long cycles (e.g., < 21 or > 45) to avoid skewing?
        // For simple MVP, just take all.
        if (diff > 20 && diff < 50) {
          totalDays += diff;
          count++;
        }
      }
    }

    if (count == 0) return defaultCycleLength;
    return (totalDays / count).round();
  }

  /// Predict next period start date
  static DateTime predictNextPeriod(
    DateTime lastPeriodStart,
    int avgCycleLength,
  ) {
    return lastPeriodStart.add(Duration(days: avgCycleLength));
  }

  /// Predict ovulation date (usually 14 days before NEXT period)
  static DateTime predictOvulation(DateTime nextPeriodStart) {
    return nextPeriodStart.subtract(const Duration(days: lutealPhaseLength));
  }

  /// Get current phase for a given date
  static CyclePhase getPhase(
    DateTime date,
    DateTime cycleStart,
    int cycleLength, {
    int periodLength = defaultPeriodLength,
  }) {
    final daysIntoCycle = date.difference(cycleStart).inDays;

    // 1. Menstruation
    if (daysIntoCycle >= 0 && daysIntoCycle < periodLength) {
      return CyclePhase.menstruation;
    }

    // Next Period Start (Predicted)
    final nextPeriod = cycleStart.add(Duration(days: cycleLength));
    final ovulationDay = nextPeriod.subtract(
      const Duration(days: lutealPhaseLength),
    );

    // Fertile Window: Ovulation day +/- 2 days (Standard approx)
    final fertileStart = ovulationDay.subtract(const Duration(days: 2));
    final fertileEnd = ovulationDay.add(const Duration(days: 2));

    // 2. Ovulation (Fertile)
    // Check if date is within fertile window
    if (date.isAfter(fertileStart.subtract(const Duration(days: 1))) &&
        date.isBefore(fertileEnd.add(const Duration(days: 1)))) {
      return CyclePhase.ovulation;
    }

    // 3. Follicular (After period, before fertile)
    if (date.isAfter(cycleStart.add(Duration(days: periodLength - 1))) &&
        date.isBefore(fertileStart)) {
      return CyclePhase.follicular;
    }

    // 4. Luteal (After fertile, before next period)
    return CyclePhase.luteal;
  }

  static Color getPhaseColor(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstruation:
        return const Color(0xFFFF9A9E); // Pink/Red
      case CyclePhase.follicular:
        return const Color(0xFFA18CD1); // Purple
      case CyclePhase.ovulation:
        return const Color(0xFF4B89EA); // Blue (Fertile)
      case CyclePhase.luteal:
        return const Color(0xFFFFD1FF); // Light Purple/PMS
    }
  }

  static String getPhaseId(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstruation:
        return 'menstruation';
      case CyclePhase.follicular:
        return 'follicular';
      case CyclePhase.ovulation:
        return 'ovulation';
      case CyclePhase.luteal:
        return 'luteal';
    }
  }

  /// Get status text and color for "Fertility Chance" card
  static Map<String, dynamic> getFertilityStatus(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstruation:
        return {
          'title': 'Thấp',
          'sub': 'Đang trong kỳ kinh',
          'color':
              Colors.green, // "Safe" in terms of pregnancy risk, logic-wise
        };
      case CyclePhase.follicular:
        return {
          'title': 'Trung bình',
          'sub': 'Sắp rụng trứng',
          'color': Colors.orangeAccent,
        };
      case CyclePhase.ovulation:
        return {
          'title': 'Rất cao',
          'sub': 'Dễ thụ thai',
          'color': const Color(0xFFFF4081), // Pink/Red for attention
        };
      case CyclePhase.luteal:
        return {'title': 'Thấp', 'sub': 'Ngày an toàn', 'color': Colors.green};
    }
  }

  /// Get lengths of recent completed cycles
  /// Returns list of pairs: [Values, MonthLabels] or just helper data
  static List<Map<String, dynamic>> getRecentCyclesData(
    List<Map<String, dynamic>> logs, {
    int limit = 6, // Get a bit more to show trend
  }) {
    if (logs.length < 2) return [];

    List<Map<String, dynamic>> result = [];

    // logs are sorted desc (Newest first)
    // Log 0 (Current/Latest Period)
    // Cycle 1 Length = Log 0 Start - Log 1 Start

    for (int i = 0; i < logs.length - 1; i++) {
      if (result.length >= limit) break;

      DateTime? currentStart;
      if (logs[i]['startDate'] is Timestamp) {
        currentStart = (logs[i]['startDate'] as Timestamp).toDate();
      } else if (logs[i]['startDate'] is DateTime) {
        currentStart = logs[i]['startDate'] as DateTime;
      }

      DateTime? prevStart;
      if (logs[i + 1]['startDate'] is Timestamp) {
        prevStart = (logs[i + 1]['startDate'] as Timestamp).toDate();
      } else if (logs[i + 1]['startDate'] is DateTime) {
        prevStart = logs[i + 1]['startDate'] as DateTime;
      }

      if (currentStart != null && prevStart != null) {
        final length = currentStart.difference(prevStart).inDays;
        // Basic validation
        if (length > 15 && length < 60) {
          result.add({
            'length': length,
            'month': currentStart
                .month, // The cycle ended in this month (roughly) or started?
            // Usually cycle is named by start month.
            // Length corresponds to the cycle STARTED at prevStart.
            // So label should probably be prevStart.month.
            'labelMonth': prevStart.month,
          });
        }
      }
    }

    // Reverse to show oldest -> newest (Left to Right)
    return result.reversed.toList();
  }

  /// Check if a specific date is within a recorded period in logs
  static bool isLogPeriodDay(DateTime date, List<Map<String, dynamic>> logs) {
    for (final log in logs) {
      DateTime start;
      if (log['startDate'] is Timestamp) {
        start = (log['startDate'] as Timestamp).toDate();
      } else {
        start = log['startDate'] as DateTime;
      }

      DateTime end;
      if (log['endDate'] != null) {
        if (log['endDate'] is Timestamp) {
          end = (log['endDate'] as Timestamp).toDate();
        } else {
          end = log['endDate'] as DateTime;
        }
      } else {
        // If end is null (current), assume 5 days or until now?
        // Let's assume default period length of 5 days for visualization if not finished
        end = start.add(const Duration(days: 4));
      }

      // Check range
      // Normalize to Date only (remove time)
      final d = DateTime(date.year, date.month, date.day);
      final s = DateTime(start.year, start.month, start.day);
      final e = DateTime(end.year, end.month, end.day);

      if (d.compareTo(s) >= 0 && d.compareTo(e) <= 0) {
        return true;
      }
    }
    return false;
  }
}
