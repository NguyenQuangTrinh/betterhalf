import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CycleReminders extends StatelessWidget {
  final bool isDark;

  const CycleReminders({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? const Color(0xFF1E2432) : Colors.white;
    final primaryTextColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark ? Colors.white54 : Colors.black54;
    final primaryBlue = const Color(0xFF4B89EA);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Nhắc nhở tùy chỉnh',
              style: GoogleFonts.inter(
                color: primaryTextColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'Thêm mới',
              style: GoogleFonts.inter(
                color: primaryBlue,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildReminderTile(
          'Mua quà vặt',
          'Trước 2 ngày khi đến kỳ',
          FontAwesomeIcons.bagShopping,
          const Color(0xFF7986CB),
          true,
          cardColor,
          primaryTextColor,
          secondaryTextColor,
        ),
        const SizedBox(height: 12),
        _buildReminderTile(
          'Nhắc uống nước ấm',
          'Mỗi ngày trong kỳ',
          FontAwesomeIcons.droplet,
          const Color(0xFF64B5F6),
          false,
          cardColor,
          primaryTextColor,
          secondaryTextColor,
        ),
      ],
    );
  }

  Widget _buildReminderTile(
    String title,
    String subtitle,
    IconData icon,
    Color iconBgColor,
    bool isActive,
    Color cardColor,
    Color primaryTextColor,
    Color secondaryTextColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
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
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconBgColor, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: primaryTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    color: secondaryTextColor,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isActive,
            onChanged: (val) {},
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFF4B89EA),
            inactiveTrackColor: Colors.grey[300],
            inactiveThumbColor: Colors.white,
            trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
          ),
        ],
      ),
    );
  }
}
