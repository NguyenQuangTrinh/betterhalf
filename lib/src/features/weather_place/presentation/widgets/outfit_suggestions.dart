import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class OutfitSuggestions extends StatelessWidget {
  final bool isDark;
  final Color primaryTextColor;

  const OutfitSuggestions({
    super.key,
    required this.isDark,
    required this.primaryTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Gợi ý trang phục',
              style: GoogleFonts.inter(
                color: primaryTextColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              'Xem thêm',
              style: GoogleFonts.inter(
                color: const Color(0xFF4B89EA),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildOutfitChip('Áo khoác mỏng', FontAwesomeIcons.shirt, isDark),
              const SizedBox(width: 12),
              _buildOutfitChip(
                'Giày thể thao',
                FontAwesomeIcons.shoePrints,
                isDark,
              ),
              const SizedBox(width: 12),
              _buildOutfitChip(
                'Khăn quàng',
                FontAwesomeIcons.snowflake,
                isDark,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOutfitChip(String label, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF2C3545)
            : const Color(0xFFE3F2FD), // Light Blue tint
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: isDark ? Colors.white70 : const Color(0xFF546E7A),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              color: isDark ? Colors.white : const Color(0xFF37474F),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
