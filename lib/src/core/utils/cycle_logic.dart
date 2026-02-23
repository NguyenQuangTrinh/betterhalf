import '../models/cycle_model.dart';

class CycleLogic {
  static const int _averageCycleLength = 28;
  static const int _ovulationOffset = 14;

  /// Predicts the start date of the next period.
  /// Uses the average cycle length of the last 3 cycles, or defaults to 28 days.
  static DateTime predictNextPeriod(List<CycleModel> pastCycles) {
    if (pastCycles.isEmpty) {
      return DateTime.now(); // No data, fallback
    }

    // Sort by start date descending
    pastCycles.sort((a, b) => b.startDate.compareTo(a.startDate));

    final lastCycle = pastCycles.first;
    int cycleLength = _averageCycleLength;

    if (pastCycles.length >= 2) {
      // Calculate average length of recent cycles
      int totalDays = 0;
      int count = 0;
      // Use up to 3 intervals between cycles
      for (int i = 0; i < pastCycles.length - 1 && i < 3; i++) {
        final current = pastCycles[i];
        final previous = pastCycles[i + 1];
        totalDays += current.startDate.difference(previous.startDate).inDays;
        count++;
      }
      if (count > 0) {
        cycleLength = (totalDays / count).round();
      }
    }

    return lastCycle.startDate.add(Duration(days: cycleLength));
  }

  /// Predicts ovulation date based on the next predicted period start date.
  /// Typically occurs 14 days BEFORE the next period.
  static DateTime predictOvulation(DateTime nextPeriodStart) {
    return nextPeriodStart.subtract(const Duration(days: _ovulationOffset));
  }

  /// Helper to check if a date is within the likely fertile window (Ovulation +/- 2 days)
  static bool isFertileWindow(DateTime date, DateTime ovulationDate) {
    final difference = date.difference(ovulationDate).inDays.abs();
    return difference <= 2;
  }
}
