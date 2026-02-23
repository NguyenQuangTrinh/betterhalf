import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GallerySearchBar extends StatelessWidget {
  final bool isDark;

  const GallerySearchBar({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 48,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2432) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.grey[400]),
            const SizedBox(width: 12),
            Text(
              'Tìm kiếm kỷ niệm...',
              style: GoogleFonts.inter(color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }
}
