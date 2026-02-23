import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CycleCalendar extends StatefulWidget {
  final bool isDark;
  final List<Map<String, dynamic>> logs;
  final int cycleLength;
  final DateTime? lastPeriodStart;

  const CycleCalendar({
    super.key,
    required this.isDark,
    this.logs = const [],
    this.cycleLength = 28,
    this.lastPeriodStart,
  });

  @override
  State<CycleCalendar> createState() => _CycleCalendarState();
}

class _CycleCalendarState extends State<CycleCalendar> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final cardColor = widget.isDark ? const Color(0xFF1E2432) : Colors.white;
    final primaryTextColor = widget.isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = widget.isDark ? Colors.white54 : Colors.black54;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: widget.isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: TableCalendar(
        locale: 'vi_VN',
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        availableCalendarFormats: const {CalendarFormat.month: 'Month'},
        startingDayOfWeek: StartingDayOfWeek.monday,
        availableGestures: AvailableGestures.horizontalSwipe,

        // --- Selection Logic ---
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          if (!isSameDay(_selectedDay, selectedDay)) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          }
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },

        // --- Styling ---
        headerStyle: HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
          titleTextStyle: GoogleFonts.inter(
            color: primaryTextColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          leftChevronIcon: Icon(Icons.chevron_left, color: secondaryTextColor),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            color: secondaryTextColor,
          ),
        ),

        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: GoogleFonts.inter(
            color: secondaryTextColor,
            fontSize: 12,
          ),
          weekendStyle: GoogleFonts.inter(
            color: secondaryTextColor,
            fontSize: 12,
          ),
        ),

        calendarBuilders: CalendarBuilders(
          prioritizedBuilder: (context, day, focusedDay) {
            final primaryTextColor = widget.isDark
                ? Colors.white
                : Colors.black87;
            final primaryBlue = const Color(0xFF4B89EA);

            // Helper to check range status
            RangeType getRangeType(DateTime d, DateTime start, DateTime end) {
              final isStart = isSameDay(d, start);
              final isEnd = isSameDay(d, end);

              if (isStart && isEnd) return RangeType.single;
              if (isStart) return RangeType.start;
              if (isEnd) return RangeType.end;
              if (d.isAfter(start) && d.isBefore(end)) return RangeType.middle;
              return RangeType.none;
            }

            final d = DateTime(day.year, day.month, day.day);
            final isToday = isSameDay(DateTime.now(), day);
            final isSelected = isSameDay(_selectedDay, day);

            RangeType rangeType = RangeType.none;
            Color? rangeColor;
            bool isOvulation = false;

            // 1. Check Past Period (From Logs)
            for (final log in widget.logs) {
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
                // If open-ended (active cycle)
                // Default prediction: 5 days (start + 4)
                final predictedEnd = start.add(const Duration(days: 4));
                final now = DateTime.now();
                final today = DateTime(now.year, now.month, now.day);

                // User Request: If duration > 5 days (i.e., today > predictedEnd),
                // extend highlight to including today.
                if (today.isAfter(predictedEnd)) {
                  end = today;
                } else {
                  end = predictedEnd;
                }
              }

              // Normalize
              start = DateTime(start.year, start.month, start.day);
              end = DateTime(end.year, end.month, end.day);

              final type = getRangeType(d, start, end);
              if (type != RangeType.none) {
                rangeType = type;
                rangeColor = const Color(0xFFFF4081).withOpacity(0.25);
                break;
              }
            }

            // 2. Check Predicted Future Events
            if (rangeType == RangeType.none && widget.lastPeriodStart != null) {
              if (d.isAfter(widget.lastPeriodStart!)) {
                for (int i = 1; i <= 12; i++) {
                  final pStart = widget.lastPeriodStart!.add(
                    Duration(days: widget.cycleLength * i),
                  );
                  final pEnd = pStart.add(const Duration(days: 4)); // 5 days

                  final type = getRangeType(d, pStart, pEnd);
                  if (type != RangeType.none) {
                    rangeType = type;
                    rangeColor = const Color(0xFFFF4081).withOpacity(0.15);
                  }

                  // Ovulation
                  final nextCycleStart = pStart.add(
                    Duration(days: widget.cycleLength),
                  );
                  final ovulationDay = nextCycleStart.subtract(
                    const Duration(days: 14),
                  );

                  if (isSameDay(d, ovulationDay)) {
                    isOvulation = true;
                  }

                  if (rangeType != RangeType.none && isOvulation) break;
                }
              }
            }

            // 3. Build Content Widget (Text + Selection/Today/Ovulation Shape)
            Widget content = Center(
              child: Text(
                '${day.day}',
                style: GoogleFonts.inter(
                  color: isSelected ? Colors.white : primaryTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            );

            // Layering Priority: Selection > Today > Ovulation
            if (isSelected) {
              content = Container(
                margin: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: content,
              );
            } else if (isToday) {
              content = Container(
                margin: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  border: Border.all(color: primaryBlue, width: 1.5),
                  shape: BoxShape.circle,
                ),
                child: content,
              );
            } else if (isOvulation) {
              content = Container(
                margin: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1DE9B6).withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: content,
              );
            }

            // 4. Combine with Range Background
            if (rangeType != RangeType.none) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  _buildRangeBackground(rangeType, rangeColor!),
                  content,
                ],
              );
            }

            // If only content (no range), return content (if decorated)
            if (isSelected || isToday || isOvulation) {
              return content;
            }

            return null; // Fallback to default
          },
        ),
      ),
    );
  }

  Widget _buildRangeBackground(RangeType type, Color bgColor) {
    BorderRadius? radius;
    // margin horizontal 0 to connect
    // margin vertical 4 to separate weeks

    switch (type) {
      case RangeType.start:
        radius = const BorderRadius.horizontal(left: Radius.circular(20));
        break;
      case RangeType.end:
        radius = const BorderRadius.horizontal(right: Radius.circular(20));
        break;
      case RangeType.single:
        radius = BorderRadius.circular(20);
        break;
      case RangeType.middle:
        radius = BorderRadius.zero;
        break;
      default:
        radius = BorderRadius.circular(0);
    }

    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 6,
        horizontal: 0,
      ), // Connect horizontally
      decoration: BoxDecoration(color: bgColor, borderRadius: radius),
    );
  }
}

enum RangeType { start, middle, end, single, none }
