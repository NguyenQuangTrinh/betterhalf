import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UpcomingEventCard extends StatelessWidget {
  final String title;
  final String date;
  final String time;
  final String location;

  const UpcomingEventCard({
    super.key,
    required this.title,
    required this.date,
    required this.time,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2432) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF4B89EA).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.calendar_today,
                  color: Color(0xFF4B89EA),
                  size: 20,
                ),
              ),
              Text(
                date,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4B89EA),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),

          const SizedBox(height: 4),
          Text(
            '$time, $location',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: isDark ? Colors.white60 : Colors.black45,
            ),
          ),
        ],
      ),
    );
  }
}

class CheckListCard extends StatelessWidget {
  final List<String> items;

  const CheckListCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2432) : Colors.white,
        borderRadius: BorderRadius.circular(30), // Rounded pill shape style
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Icon(
                  // Alternating checked/unchecked for demo
                  items.indexOf(item) == 0
                      ? Icons.check_circle_outline
                      : Icons.circle_outlined,
                  color: items.indexOf(item) == 0
                      ? const Color(0xFF4B89EA)
                      : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: items.indexOf(item) == 0
                          ? (isDark
                                ? Colors.white54
                                : Colors.black45) // Completed
                          : (isDark ? Colors.white : Colors.black87), // Active
                      decoration: items.indexOf(item) == 0
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
