import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../logic/cycle_logic.dart';

class CycleCircularChart extends StatelessWidget {
  final int daysIntoCycle; // Day X
  final int cycleLength;
  final int periodLength;
  final CyclePhase currentPhase;

  const CycleCircularChart({
    super.key,
    required this.daysIntoCycle,
    required this.cycleLength,
    required this.periodLength,
    required this.currentPhase,
  });

  @override
  Widget build(BuildContext context) {
    // Determine colors based on phase or just static premium design
    // The reference image 2 uses a dark theme. We should adapt to the context but here we force a style that looks good.
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Text Colors
    final textColor = isDark ? Colors.white : const Color(0xFF2D3142);
    final labelColor = isDark ? Colors.white70 : Colors.grey[600];

    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The Chart
          CustomPaint(
            size: const Size(260, 260),
            painter: _PremiumCycleChartPainter(
              cycleLength: cycleLength,
              periodLength: periodLength,
              currentDay: daysIntoCycle,
              isDark: isDark,
            ),
          ),

          // Center Text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'NGÀY THỨ',
                style: GoogleFonts.inter(
                  color: labelColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$daysIntoCycle',
                style: GoogleFonts.outfit(
                  // Using Outfit for that big modern number look
                  color: textColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 72,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 12),
              _buildPhaseBadge(currentPhase),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseBadge(CyclePhase phase) {
    Color color;
    String text;

    switch (phase) {
      case CyclePhase.menstruation:
        color = const Color(0xFFFF4081); // Hot Pink
        text = 'Kinh nguyệt';
        break;
      case CyclePhase.follicular:
        color = const Color(0xFF9C27B0); // Purple
        text = 'Giai đoạn nang noãn'; // More scientific name from image 2
        break;
      case CyclePhase.ovulation:
        color = const Color(0xFF1DE9B6); // Teal Accent
        text = 'Thụ thai / Rụng trứng';
        break;
      case CyclePhase.luteal:
        color = const Color(0xFF5C6BC0); // Indigo/Blue
        text = 'An toàn / PMS';
        break;
    }

    return Text(
      text,
      style: GoogleFonts.inter(
        color: color, // Text color matches phase
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _PremiumCycleChartPainter extends CustomPainter {
  final int cycleLength;
  final int periodLength;
  final int currentDay;
  final bool isDark;

  _PremiumCycleChartPainter({
    required this.cycleLength,
    required this.periodLength,
    required this.currentDay,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 15; // Padding
    final strokeWidth = 18.0; // Slimmer, more elegant

    final rect = Rect.fromCircle(center: center, radius: radius);

    // COLORS
    final trackColor = isDark
        ? const Color(
            0xFF384050,
          ) // Lighter grey/blue for decent contrast against dark card
        : const Color(0xFFE0E5EC); // Light grey for light mode

    final periodColor = const Color(0xFFFF4081); // Pink
    final ovulationColor = const Color(0xFF1DE9B6); // Teal
    // We treat the rest as "track" or a neutral follicular/luteal color if desired.
    // Image 2 shows mainly Pink and Teal segments popping out against a dark ring.

    // 1. Draw Background Track (Full Ring)
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, 0, 2 * pi, false, trackPaint);

    // Helpers
    final ovulationDay = cycleLength - 14;
    final fertileStart = ovulationDay - 2;
    final fertileEnd = ovulationDay + 2;

    void drawSegment(double startDay, double endDay, Color color) {
      if (startDay >= endDay) return;

      // -90deg is 12 o'clock.
      final startAngle = -pi / 2 + (startDay / cycleLength) * 2 * pi;
      final sweepAngle = ((endDay - startDay) / cycleLength) * 2 * pi;

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
    }

    // 2. Draw Menstruation Segment
    drawSegment(0, periodLength.toDouble(), periodColor);

    // 3. Draw Ovulation Segment
    // Note: If follicular is just the track color, we skip drawing it explicitly
    drawSegment(fertileStart.toDouble(), fertileEnd.toDouble(), ovulationColor);

    // 4. Draw Current Day Indicator
    // Angle
    final currentAngle = -pi / 2 + (currentDay / cycleLength) * 2 * pi;
    final indicatorX = center.dx + radius * cos(currentAngle);
    final indicatorY = center.dy + radius * sin(currentAngle);

    // Draw Shadow for depth
    canvas.drawCircle(
      Offset(indicatorX, indicatorY),
      strokeWidth - 2,
      Paint()
        ..color = Colors.black.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Draw "Cutout" / Border
    // Since the card has a gradient, a solid color cutout isn't perfect,
    // but a dark color close to the card background works well enough to separte the dot from the track.
    final cutoutColor = isDark ? const Color(0xFF1E2432) : Colors.white;
    canvas.drawCircle(
      Offset(indicatorX, indicatorY),
      strokeWidth / 1.1,
      Paint()..color = cutoutColor,
    );

    // Draw ACTUAL Indicator Dot (Middle)
    // White in dark mode for high contrast, Dark Blue in light mode.
    final indicatorColor = isDark ? Colors.white : const Color(0xFF2C3E50);
    canvas.drawCircle(
      Offset(indicatorX, indicatorY),
      strokeWidth / 1.6,
      Paint()..color = indicatorColor,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
