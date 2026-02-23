import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PlaceWeatherTabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final bool isDark;
  final Color secondaryTextColor;

  const PlaceWeatherTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.isDark,
    required this.secondaryTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C3545) : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onTabSelected(0),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selectedIndex == 0
                      ? const Color(0xFF90B6F4)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Lên kế hoạch',
                  style: GoogleFonts.inter(
                    color: selectedIndex == 0
                        ? Colors.white
                        : secondaryTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onTabSelected(1),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selectedIndex == 1
                      ? const Color(0xFF90B6F4)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Kỷ niệm đã qua',
                  style: GoogleFonts.inter(
                    color: selectedIndex == 1
                        ? Colors.white
                        : secondaryTextColor,
                    fontWeight: selectedIndex == 1
                        ? FontWeight.bold
                        : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
