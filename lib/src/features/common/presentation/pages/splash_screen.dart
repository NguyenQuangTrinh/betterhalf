import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Background Colors
    final bgColor = isDark
        ? const Color(0xFF0F172A) // Dark blue/black
        : const Color(0xFFEBF8FF); // Light blueish

    // Text Colors
    final titleColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subtitleColor = isDark ? Colors.white70 : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2), // Top spacing
            // --- Logo Section ---
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? const Color(0xFF38BDF8).withOpacity(0.3)
                        : const Color(0xFF38BDF8).withOpacity(0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                // Assuming slap.png is the logo. If transparent, container color might be needed.
                // Image provided looked like an icon. I'll wrap in container if needed.
                child: Image.asset('assets/images/slap.png', fit: BoxFit.cover),
              ),
            ),

            const SizedBox(height: 32),

            // --- Title & Slogan ---
            Text(
              'Tình Yêu',
              style: GoogleFonts.inter(
                color: titleColor,
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kết nối yêu thương',
              style: GoogleFonts.inter(
                color: subtitleColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),

            const Spacer(flex: 3), // Middle spacing
            // --- Bottom Section: Loading & Version ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Đang tải...',
                        style: GoogleFonts.inter(
                          color: titleColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: const Color(0xFF38BDF8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Custom Linear Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      minHeight: 6,
                      color: const Color(0xFF38BDF8), // Blue
                      backgroundColor: isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFCBD5E1),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Version 1.0',
              style: GoogleFonts.inter(
                color: subtitleColor.withOpacity(0.5),
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 32), // Bottom padding
          ],
        ),
      ),
    );
  }
}
