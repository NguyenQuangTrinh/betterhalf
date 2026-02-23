import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TaskItem extends StatelessWidget {
  final String title;
  final String dueDate;
  final String assigneeName;
  final String assigneeAvatar;
  final bool isOverdue;
  final bool isMe;
  final bool isDark;

  final bool isCompleted;
  final VoidCallback? onToggle;
  final Function(String)? onMenuSelected;

  const TaskItem({
    super.key,
    required this.title,
    required this.dueDate,
    required this.assigneeName,
    required this.assigneeAvatar,
    required this.isOverdue,
    this.isMe = false,
    required this.isDark,
    this.isCompleted = false,
    this.onToggle,
    this.onMenuSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2329) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        children: [
          // Radio/Check Circle
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? (isMe ? const Color(0xFF4B89EA) : Colors.green)
                    : Colors.transparent,
                border: Border.all(
                  color: isCompleted
                      ? (isMe ? const Color(0xFF4B89EA) : Colors.green)
                      : (isDark ? Colors.grey : Colors.grey[300]!),
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (dueDate.isNotEmpty || assigneeName.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      // Date
                      if (dueDate.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isOverdue
                                ? (isDark
                                      ? const Color(0xFF3F2022)
                                      : const Color(0xFFFFEBEE))
                                : (isMe
                                      ? const Color(0xFFE3F2FD) // Blueish if ME
                                      : (isDark
                                            ? const Color(0xFF1D2B3A)
                                            : Colors.grey[100])),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isMe
                                    ? Icons.access_time_filled
                                    : Icons
                                          .calendar_today, // Change icon based on context ?
                                size: 10,
                                color: isOverdue
                                    ? const Color(0xFFEF4444)
                                    : (isMe
                                          ? const Color(0xFF4B89EA)
                                          : (isDark
                                                ? const Color(0xFF3B82F6)
                                                : Colors.grey)),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                dueDate,
                                style: GoogleFonts.inter(
                                  color: isOverdue
                                      ? const Color(0xFFEF4444)
                                      : (isMe
                                            ? const Color(0xFF4B89EA)
                                            : (isDark
                                                  ? const Color(0xFF3B82F6)
                                                  : Colors.grey)),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (dueDate.isNotEmpty) const SizedBox(width: 10),
                      // Assignee
                      if (assigneeName.isNotEmpty)
                        Row(
                          children: [
                            if (assigneeAvatar.isNotEmpty)
                              CircleAvatar(
                                radius: 8,
                                backgroundImage: NetworkImage(assigneeAvatar),
                                backgroundColor: Colors.grey[200],
                              )
                            else
                              const CircleAvatar(
                                radius: 8,
                                child: Icon(Icons.person, size: 10),
                              ),
                            const SizedBox(width: 4),
                            Text(
                              assigneeName,
                              style: GoogleFonts.inter(
                                color: isDark ? Colors.white : Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.grey[400], size: 20),
            onSelected: onMenuSelected,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text("Xóa", style: GoogleFonts.inter(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
