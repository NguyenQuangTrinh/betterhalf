import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../logic/cycle_logic.dart';

class CycleInfoRow extends StatelessWidget {
  final bool isDark;
  final DateTime? lastPeriodStart;
  final int cycleLength;

  const CycleInfoRow({
    super.key,
    required this.isDark,
    this.lastPeriodStart,
    this.cycleLength = 28,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? const Color(0xFF1E2432) : Colors.white;
    final primaryTextColor = isDark ? Colors.white : Colors.black87;
    final primaryBlue = const Color(0xFF4B89EA);

    // Default values if no data
    String nextPeriodDays = "--";
    String nextPeriodDate = "--/--";
    String fertilityTitle = "--";
    String fertilitySub = "--";
    Color fertilityColor = Colors.grey;

    if (lastPeriodStart != null) {
      final now = DateTime.now();

      // Next Period Calc
      final nextPeriod = CycleLogic.predictNextPeriod(
        lastPeriodStart!,
        cycleLength,
      );
      final daysToNext = nextPeriod.difference(now).inDays;

      nextPeriodDays = "$daysToNext ngày nữa";
      nextPeriodDate = "Khoảng ${nextPeriod.day}/${nextPeriod.month}";

      // Fertility Calc
      final currentPhase = CycleLogic.getPhase(
        now,
        lastPeriodStart!,
        cycleLength,
      );
      final status = CycleLogic.getFertilityStatus(currentPhase);
      fertilityTitle = status['title'];
      fertilitySub = status['sub'];
      fertilityColor = status['color'];
    }

    return Row(
      children: [
        Expanded(
          child: _InfoCard(
            icon: FontAwesomeIcons.calendar,
            title: 'Dự kiến kỳ tới',
            mainText: nextPeriodDays,
            subText: nextPeriodDate,
            iconColor: const Color(0xFF64B5F6),
            bgColor: cardColor,
            mainTextColor: primaryTextColor,
            subTextColor: primaryBlue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _InfoCard(
            icon: Icons
                .favorite, // Changed icon to match "Fertility/Love" better? Or keep sentiment
            // User image had a smiley face
            customIcon: FontAwesomeIcons.faceSmile,
            title: 'Khả năng thụ thai',
            mainText: fertilityTitle,
            subText: fertilitySub,
            mainTextColor: primaryTextColor,
            subTextColor: fertilityColor,
            iconColor: fertilityColor,
            bgColor: cardColor,
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String mainText;
  final String subText;
  final Color iconColor;
  final Color bgColor;
  final Color mainTextColor;
  final Color subTextColor;
  final IconData? customIcon;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.mainText,
    required this.subText,
    required this.iconColor,
    required this.bgColor,
    required this.mainTextColor,
    required this.subTextColor,
    this.customIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(customIcon ?? icon, color: iconColor, size: 16),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.inter(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            mainText,
            style: GoogleFonts.inter(
              color: mainTextColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subText,
            style: GoogleFonts.inter(color: subTextColor, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
