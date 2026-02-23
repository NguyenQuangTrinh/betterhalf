import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isGalleryMode;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isGalleryMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF1E2432) : Colors.white;

    // Use full width and no margin for Gallery Mode ("straight")
    // Keep floating for Home Mode
    final margin = isGalleryMode
        ? EdgeInsets.zero
        : const EdgeInsets.fromLTRB(20, 0, 20, 20);
    final borderRadius = isGalleryMode
        ? const BorderRadius.vertical(top: Radius.circular(20))
        : BorderRadius.circular(35);
    final height = isGalleryMode ? 80.0 : 70.0;

    return Container(
      margin: margin,
      height: height,
      decoration: BoxDecoration(
        color: isGalleryMode && !isDark ? Colors.white : backgroundColor,
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: isGalleryMode
            ? [
                Expanded(
                  child: _buildNavItem(isDark, Icons.collections, 'Kỷ niệm', 1),
                ),
                Expanded(
                  child: _buildNavItem(isDark, Icons.calendar_month, 'Lịch', 4),
                ),
                Expanded(
                  child: _buildNavItem(
                    isDark,
                    Icons.check_circle,
                    'Công việc',
                    6,
                  ),
                ),
                Expanded(
                  child: _buildNavItem(isDark, Icons.gamepad, 'Game', 5),
                ),
                Expanded(child: _buildNavItem(isDark, Icons.map, 'Map', 2)),
              ]
            : [
                Expanded(child: _buildNavItem(isDark, Icons.home, 'Home', 0)),
                Expanded(
                  child: _buildNavItem(
                    isDark,
                    Icons.grid_view_rounded,
                    'Tiện ích',
                    1,
                  ),
                ),
                // Placeholder for FAB space
                const SizedBox(width: 40),
                Expanded(child: _buildNavItem(isDark, Icons.map, 'Map', 2)),
                Expanded(
                  child: _buildNavItem(isDark, Icons.settings, 'Settings', 3),
                ),
              ],
      ),
    );
  }

  Widget _buildNavItem(bool isDark, IconData icon, String label, int index) {
    final isSelected = currentIndex == index;
    final inactiveColor = const Color(0xFF8E99A6); // Grey

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.translucent,
      child: Container(
        height: double.infinity,
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isGalleryMode ? 6 : 8), // Reduced padding
              decoration: isSelected && isGalleryMode
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF293245), const Color(0xFF232A3B)]
                            : [
                                const Color(0xFFF0F4F8),
                                const Color(0xFFE6EAF0),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    )
                  : null,
              child: isGalleryMode && isSelected
                  ? Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4B89EA).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: const Color(0xFF4B89EA),
                        size: 22,
                      ), // Reduced icon size slightly
                    )
                  : Icon(
                      icon,
                      color: isSelected
                          ? const Color(0xFF4B89EA)
                          : inactiveColor,
                      size: 26,
                    ),
            ),
            const SizedBox(height: 2), // Reduced spacing
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF4B89EA) : inactiveColor,
                fontSize: isGalleryMode ? 11 : 10, // Adjusted font size
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
