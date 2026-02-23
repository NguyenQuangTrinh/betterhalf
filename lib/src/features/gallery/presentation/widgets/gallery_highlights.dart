import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GalleryHighlights extends StatelessWidget {
  final bool isDark;

  const GalleryHighlights({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final primaryBlue = const Color(0xFF4B89EA);

    return Column(
      children: [
        // --- Highlights Header ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ảnh nổi bật',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                'Xem tất cả',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: primaryBlue,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // --- Highlights List ---
        SizedBox(
          height: 140,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildHighlightItem(
                'Đà Lạt 2023',
                'https://placeholder.com/dalat.jpg',
                isDark,
              ),
              _buildHighlightItem(
                'Kỷ niệm 1 năm',
                'https://placeholder.com/anniversary.jpg',
                isDark,
                isSpecial: true,
              ),
              _buildHighlightItem(
                'Hẹn hò',
                'https://placeholder.com/date.jpg',
                isDark,
              ),
              _buildHighlightItem(
                'Giáng sinh',
                'https://placeholder.com/xmas.jpg',
                isDark,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHighlightItem(
    String title,
    String imageUrl,
    bool isDark, {
    bool isSpecial = false,
  }) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: isSpecial
                  ? Border.all(color: const Color(0xFF4B89EA), width: 2)
                  : null,
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: isSpecial ? FontWeight.bold : FontWeight.w500,
              color: isSpecial
                  ? const Color(0xFF4B89EA)
                  : (isDark ? Colors.white70 : Colors.black87),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
