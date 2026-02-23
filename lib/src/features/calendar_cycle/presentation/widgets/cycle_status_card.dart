import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../logic/cycle_logic.dart';
import 'cycle_circular_chart.dart';
import 'cycle_wave_chart.dart';

class CycleStatusCard extends StatefulWidget {
  final bool isDark;
  final DateTime? lastPeriodStart;
  final int cycleLength;
  final List<Map<String, dynamic>> logs;

  const CycleStatusCard({
    super.key,
    required this.isDark,
    this.lastPeriodStart,
    this.cycleLength = 28, // Default standard
    this.logs = const [],
  });

  @override
  State<CycleStatusCard> createState() => _CycleStatusCardState();
}

class _CycleStatusCardState extends State<CycleStatusCard> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    // Handling no data case
    if (widget.lastPeriodStart == null) {
      return _buildEmptyState();
    }

    // Calculate Cycle Data
    final lastStart = widget.lastPeriodStart!;
    final now = DateTime.now();
    final daysIntoCycle = max(
      1,
      now.difference(lastStart).inDays + 1,
    ); // 1-based, min 1

    // Dynamic Period Length Logic
    // If active cycle (no endDate) exceeds default 5 days, extend period length to today.
    int periodLength = 5;
    if (widget.logs.isNotEmpty) {
      final latestLog = widget.logs.first;
      // We assume logs.first corresponds to lastPeriodStart as per parent logic
      if (latestLog['endDate'] == null) {
        if (daysIntoCycle > 5) {
          periodLength = daysIntoCycle;
        }
      }
    }

    final currentPhase = CycleLogic.getPhase(
      now,
      lastStart,
      widget.cycleLength,
      periodLength: periodLength,
    );

    // Get History Data
    final historyData = CycleLogic.getRecentCyclesData(widget.logs);

    // Gradient for Cycle Card
    final cycleCardGradient = widget.isDark
        ? const LinearGradient(
            colors: [Color(0xFF2C3545), Color(0xFF1E2432)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [
              Color(0xFF67B0F0),
              Color(0xFF4B89EA),
            ], // Bright Blue Gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: cycleCardGradient,
        borderRadius: BorderRadius.circular(32),
        boxShadow: widget.isDark
            ? []
            : [
                BoxShadow(
                  color: const Color(0xFF4B89EA).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Column(
        children: [
          // Charts PageView
          SizedBox(
            height: 300,
            child: PageView(
              controller: _pageController,
              children: [
                CycleCircularChart(
                  daysIntoCycle: daysIntoCycle,
                  cycleLength: widget.cycleLength,
                  periodLength: periodLength,
                  currentPhase: currentPhase,
                ),
                CycleWaveChart(historyData: historyData, isDark: widget.isDark),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SmoothPageIndicator(
            controller: _pageController,
            count: 2,
            effect: ExpandingDotsEffect(
              dotColor: Colors.white24,
              activeDotColor: Colors.white,
              dotHeight: 6,
              dotWidth: 6,
            ),
          ),
          const SizedBox(height: 16),
          // Bottom Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chu kỳ hiện tại',
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tháng ${now.month}',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  // Period Legend
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF4081),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Kỳ kinh',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  // Ovulation Legend
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFF1DE9B6),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Rụng trứng',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: widget.isDark
            ? const Color(0xFF2C3545)
            : const Color(0xFF67B0F0),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Center(
        child: Text(
          'Chưa có dữ liệu chu kỳ.\nHãy cập nhật kỳ kinh mới nhất!',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
