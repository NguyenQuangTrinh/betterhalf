import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';

class GalleryPhotoGrid extends StatelessWidget {
  const GalleryPhotoGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: MasonryGridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        itemCount: 6,
        itemBuilder: (context, index) {
          // Mock data for varying heights and content
          final heights = [180.0, 240.0, 160.0, 200.0, 220.0, 150.0];
          final mockImages = [
            'https://placeholder.com/hand_hold.jpg',
            'https://placeholder.com/girl_portrait.jpg',
            'https://placeholder.com/hotel_room.jpg',
            'https://placeholder.com/minimal.jpg',
            'https://placeholder.com/wedding.jpg',
            'https://placeholder.com/landscape.jpg',
          ];

          return Container(
            height: heights[index % heights.length],
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: NetworkImage(mockImages[index % mockImages.length]),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                // Example Label (on first item)
                if (index == 2)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'NHA TRANG',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                // Example Icon (Heart on 2nd item)
                if (index == 1)
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Color(0xFF4B89EA),
                        size: 16,
                      ),
                    ),
                  ),
                // Example Icon (Camera on 4th item)
                if (index == 3)
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF4B89EA),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
