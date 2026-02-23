import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class CycleHistory extends StatelessWidget {
  final bool isDark;
  final List<Map<String, dynamic>> logs;
  final VoidCallback? onViewAll;
  final Function(Map<String, dynamic> log)? onItemTap;
  final int limit;

  const CycleHistory({
    super.key,
    required this.isDark,
    this.logs = const [],
    this.onViewAll,
    this.onItemTap,
    this.limit = 3,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? const Color(0xFF1E2432) : Colors.white;
    final primaryTextColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark ? Colors.white54 : Colors.black54;

    final displayLogs = logs.take(limit).toList();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Lịch sử chu kỳ',
              style: GoogleFonts.inter(
                color: primaryTextColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            GestureDetector(
              onTap: onViewAll,
              child: Text(
                'Xem tất cả',
                style: GoogleFonts.inter(
                  color: secondaryTextColor,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (displayLogs.isEmpty)
          Center(
            child: Text(
              'Chưa có dữ liệu chu kỳ',
              style: GoogleFonts.inter(color: secondaryTextColor),
            ),
          )
        else
          ...displayLogs.asMap().entries.map((entry) {
            final index = entry.key;
            final log = entry.value;

            DateTime? startDate;
            if (log['startDate'] is Timestamp) {
              startDate = (log['startDate'] as Timestamp).toDate();
            }

            final monthStr = startDate != null
                ? "Tháng ${DateFormat('MM', 'vi_VN').format(startDate)}"
                : 'Unknown';

            final startDateStr = startDate != null
                ? DateFormat('dd/MM', 'vi_VN').format(startDate)
                : '--';

            // Calculate Cycle Length (Distance to next cycle start)
            String cycleLengthStr = '-- ngày';
            bool isCurrent = false;

            if (index == 0) {
              // Current Cycle: Show "Day N"
              if (startDate != null) {
                final days = DateTime.now().difference(startDate).inDays + 1;
                cycleLengthStr = 'Ngày $days';
                isCurrent = true;
              }
            } else {
              // Past Cycle: Start of Next - Start of This
              final nextLog = logs[index - 1];
              DateTime? nextStart;
              if (nextLog['startDate'] is Timestamp) {
                nextStart = (nextLog['startDate'] as Timestamp).toDate();
              }

              if (startDate != null && nextStart != null) {
                final days = nextStart.difference(startDate).inDays;
                cycleLengthStr = '$days ngày';
              }
            }

            DateTime? endDate;
            if (log['endDate'] is Timestamp) {
              endDate = (log['endDate'] as Timestamp).toDate();
            }
            final endDateStr = endDate != null
                ? DateFormat('dd/MM').format(endDate)
                : '...';

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => onItemTap?.call(log),
                child: _buildHistoryTile(
                  monthStr,
                  '$startDateStr - $endDateStr',
                  cycleLengthStr,
                  cardColor,
                  primaryTextColor,
                  secondaryTextColor,
                  isWarning: isCurrent, // Highlight current cycle
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildHistoryTile(
    String month,
    String dates,
    String length,
    Color cardColor,
    Color primaryTextColor,
    Color secondaryTextColor, {
    bool isWarning = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  month,
                  style: GoogleFonts.inter(
                    color: primaryTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  dates,
                  style: GoogleFonts.inter(
                    color: secondaryTextColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isWarning
                  ? const Color(0xFFE6A23C).withOpacity(0.15)
                  : const Color(0xFF67C23A).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              length,
              style: GoogleFonts.inter(
                color: isWarning
                    ? const Color(0xFFE6A23C)
                    : const Color(0xFF67C23A),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right,
            color: secondaryTextColor.withOpacity(0.5),
            size: 16,
          ),
        ],
      ),
    );
  }
}
