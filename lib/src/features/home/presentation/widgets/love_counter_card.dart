import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoveCounterCard extends StatelessWidget {
  final DateTime startDate;

  const LoveCounterCard({super.key, required this.startDate});

  @override
  Widget build(BuildContext context) {
    final daysTogether = DateTime.now().difference(startDate).inDays;
    // Format number with commas if needed, but for now simple string
    final daysString = daysTogether.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF67B0F0), // Light Blue
            const Color(0xFF4B89EA), // Darker Blue
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4B89EA).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // --- Avatars ---
          SizedBox(
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Avatar 1 (Left)
                Positioned(
                  left: 70, // Adjust based on alignment
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white24,
                    ),
                    child: const CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(
                        'https://placeholder.com/male_avatar.png',
                      ),
                    ),
                  ),
                ),
                // Avatar 2 (Right)
                Positioned(
                  right: 70, // Adjust based on alignment
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white24,
                    ),
                    child: const CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(
                        'https://placeholder.com/female_avatar.png',
                      ),
                    ),
                  ),
                ),
                // Heart Icon (Center)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Color(0xFF4B89EA),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'Chúng ta đã bên nhau',
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            daysString, // Dynamic count
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
              height: 1.0,
            ),
          ),

          Text(
            'Ngày',
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
