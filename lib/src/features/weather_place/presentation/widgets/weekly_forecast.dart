import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class WeeklyForecast extends StatelessWidget {
  final bool isDark;

  const WeeklyForecast({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildForecastCard('Hôm nay', '24°', Icons.wb_sunny, true, isDark),
        _buildForecastCard('T6', '22°', Icons.cloud, false, isDark),
        _buildForecastCard(
          'T7',
          '19°',
          FontAwesomeIcons.cloudBolt,
          false,
          isDark,
        ),
        _buildForecastCard(
          'CN',
          '21°',
          FontAwesomeIcons.cloudSun,
          false,
          isDark,
        ),
      ],
    );
  }

  Widget _buildForecastCard(
    String day,
    String temp,
    IconData icon,
    bool isActive,
    bool isDark,
  ) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF90B6F4)
              : (isDark ? const Color(0xFF2C3545) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.grey[200]!,
            width: isActive ? 0 : 1,
          ),
          boxShadow: isActive
              ? [
                  const BoxShadow(
                    color: Color(0x3390B6F4),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Text(
              day,
              style: GoogleFonts.inter(
                color: isActive
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.grey),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Icon(
              icon,
              color: isActive
                  ? Colors.white
                  : (day == 'T7' || day == 'T6'
                        ? Colors.amber
                        : (isDark ? Colors.white : Colors.grey)),
              size: 20,
            ),
            const SizedBox(height: 12),
            Text(
              temp,
              style: GoogleFonts.inter(
                color: isActive
                    ? Colors.white
                    : (isDark ? Colors.white : Colors.black87),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
