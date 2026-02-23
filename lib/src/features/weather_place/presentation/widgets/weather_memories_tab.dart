import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'memories_summary_card.dart';
import 'memory_card.dart';

class WeatherMemoriesTab extends StatelessWidget {
  final bool isDark;
  final Color cardColor;
  final Color primaryTextColor;
  final Color secondaryTextColor;

  const WeatherMemoriesTab({
    super.key,
    required this.isDark,
    required this.cardColor,
    required this.primaryTextColor,
    required this.secondaryTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Summary Card ---
        const MemoriesSummaryCard(),
        const SizedBox(height: 24),

        // --- Filters ---
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('Mới nhất', true, isDark),
              const SizedBox(width: 12),
              _buildFilterChip('Theo địa điểm', false, isDark),
              const SizedBox(width: 12),
              _buildFilterChip('Có video', false, isDark),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // --- Timeline: Valentine 2024 ---
        _buildTimelineHeader(
          '14',
          'TH02',
          'Valentine 2024',
          'Một ngày mưa lãng mạn',
        ),
        const SizedBox(height: 16),

        // Memory Card 1
        MemoryCard(
          title: 'Tranquil Books & Coffee',
          location: 'Nguyễn Quang Bích, Hà Nội',
          description:
              'Không gian ấm cúng, nhạc Trịnh nhẹ nhàng. Hai đứa ngồi đọc sách cả buổi chiều không biết chán.',
          imageUrl: 'https://placeholder.com/memory1.jpg',
          temp: '18°C',
          badge: 'Check-in',
          isDark: isDark,
          cardColor: cardColor,
          primaryTextColor: primaryTextColor,
          secondaryTextColor: secondaryTextColor,
          hasStack: true,
          isSunset: false,
        ),

        const SizedBox(height: 32),

        // --- Timeline: Kỷ niệm 1 năm ---
        _buildTimelineHeader('20', 'TH10', 'Kỷ niệm 1 năm', 'Hoàng hôn Hồ Tây'),
        const SizedBox(height: 16),

        // Memory Card 2
        MemoryCard(
          title: 'Hồ Tây - Góc Phủ',
          location: 'Tây Hồ, Hà Nội',
          description:
              'Hoàng hôn hôm nay đẹp xuất sắc. Cảm ơn anh vì buổi chiều tuyệt vời này. Mong năm sau vẫn cùng nhau ngắm.',
          imageUrl: 'https://placeholder.com/memory2.jpg',
          temp: '25°C',
          badge: 'Date',
          isDark: isDark,
          cardColor: cardColor,
          primaryTextColor: primaryTextColor,
          secondaryTextColor: secondaryTextColor,
          hasStack: false,
          isSunset: true,
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF4B89EA)
            : (isDark ? const Color(0xFF2C3545) : Colors.white),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected
              ? Colors.transparent
              : (isDark ? Colors.white10 : Colors.grey[300]!),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: isSelected
              ? Colors.white
              : (isDark ? Colors.white70 : Colors.black87),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildTimelineHeader(
    String day,
    String month,
    String title,
    String subtitle,
  ) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2C3545) : const Color(0xFFE3F2FD),
            shape: BoxShape.circle,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                day,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: const Color(0xFF4B89EA),
                ),
              ),
              Text(
                month,
                style: GoogleFonts.inter(
                  fontSize: 8,
                  color: const Color(0xFF4B89EA),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                color: primaryTextColor,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.inter(color: secondaryTextColor, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}
