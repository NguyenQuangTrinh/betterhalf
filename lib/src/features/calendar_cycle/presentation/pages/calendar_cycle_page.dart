import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../providers/auth_provider.dart';
import '../../../common/presentation/pages/coming_soon_page.dart';
import '../widgets/cycle_status_card.dart';
import '../widgets/cycle_info_row.dart';
import '../widgets/cycle_calendar.dart';
import '../widgets/cycle_reminders.dart';
import '../widgets/cycle_history.dart';
import '../widgets/update_cycle_modal.dart';
import '../../logic/cycle_logic.dart';

import '../../data/services/cycle_service.dart';
import '../../../settings/data/services/connection_service.dart';

class CalendarCyclePage extends StatelessWidget {
  final VoidCallback? onBack;

  const CalendarCyclePage({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    // 1. Check Access Logic
    final authProvider = context.watch<AuthProvider>();

    // Debug prints
    // print('Gender: ${authProvider.gender}, Connected: ${authProvider.isConnected}, UserData: ${authProvider.userData}');

    if (authProvider.isLoading || authProvider.userData == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final gender = (authProvider.gender ?? '').toLowerCase();
    final isMale = gender == 'nam' || gender == 'm';
    final isConnected = authProvider.isConnected;

    if (isMale && !isConnected) {
      return ComingSoonPage(
        onBack: onBack,
        title: 'Dành cho các cặp đôi',
        message:
            'Tính năng theo dõi chu kỳ chỉ khả dụng khi bạn đã kết nối với "nửa kia".\nHãy kết nối để cùng nhau chăm sóc sức khỏe nhé!',
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cycleService = CycleService();

    // Theme Colors
    final backgroundColor = isDark
        ? const Color(0xFF161B22)
        : const Color(0xFFF3F5FA);
    final primaryTextColor = isDark ? Colors.white : Colors.black87;
    final primaryBlue = const Color(0xFF4B89EA);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryTextColor),
          onPressed: () {
            if (onBack != null) {
              onBack!();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: FutureBuilder<Map<String, dynamic>?>(
          future: isMale
              ? ConnectionService().getUserData(authProvider.partnerId!)
              : Future.value(authProvider.userData),
          builder: (context, snapshot) {
            final data = snapshot.data;
            final name =
                data?['firstName'] ??
                data?['name']?.split(' ').last ??
                'Người thương';
            final avatarUrl = data?['avatarUrl'];

            return Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: avatarUrl != null
                      ? NetworkImage(avatarUrl)
                      : const NetworkImage(
                          'https://placeholder.com/user_avatar.jpg',
                        ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.inter(
                            color: primaryTextColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.favorite, color: Colors.red, size: 14),
                      ],
                    ),
                    Text(
                      'Đang trực tuyến',
                      style: GoogleFonts.inter(
                        color: Colors.greenAccent,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications, color: primaryTextColor),
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: cycleService.getCycleLogs(
          userId: isMale ? authProvider.partnerId : authProvider.user?.uid,
        ),
        builder: (context, snapshot) {
          final logs = snapshot.data ?? [];

          /* Calculate Data derived from logs */
          DateTime? lastPeriodStart;
          if (logs.isNotEmpty && logs.first['startDate'] is Timestamp) {
            lastPeriodStart = (logs.first['startDate'] as Timestamp).toDate();
          }

          final avgCycleLength = CycleLogic.calculateAverageCycleLength(logs);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Cycle Status Card ---
                  CycleStatusCard(
                    isDark: isDark,
                    lastPeriodStart: lastPeriodStart,
                    cycleLength: avgCycleLength,
                    logs: logs,
                  ),

                  const SizedBox(height: 20),

                  // --- Two Info Cards ---
                  CycleInfoRow(
                    isDark: isDark,
                    lastPeriodStart: lastPeriodStart,
                    cycleLength: avgCycleLength,
                  ),

                  const SizedBox(height: 24),

                  // --- Calendar Section ---
                  CycleCalendar(
                    isDark: isDark,
                    logs: logs,
                    cycleLength: avgCycleLength,
                    lastPeriodStart: lastPeriodStart,
                  ),

                  const SizedBox(height: 24),

                  // --- Reminders ---
                  CycleReminders(isDark: isDark),

                  const SizedBox(height: 24),

                  // --- History Header ---
                  CycleHistory(
                    isDark: isDark,
                    logs: logs,
                    onItemTap: (log) {
                      _showUpdateCycleModal(context, log: log);
                    },
                    onViewAll: () {
                      _showFullHistoryModal(context, logs, isDark);
                    },
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: Container(
          height: 56,
          width: 56,
          decoration: BoxDecoration(
            color: primaryBlue,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: primaryBlue.withValues(alpha: 0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(
              FontAwesomeIcons.penToSquare,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => _showUpdateCycleModal(context),
          ),
        ),
      ),
    );
  }

  void _showUpdateCycleModal(
    BuildContext context, {
    Map<String, dynamic>? log,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final authProvider = context.read<AuthProvider>();
        final gender = (authProvider.gender ?? '').toLowerCase();
        final isMale = gender == 'nam' || gender == 'm';
        final targetUserId = isMale
            ? authProvider.partnerId
            : authProvider.user?.uid;

        return UpdateCycleModal(userId: targetUserId, initialLog: log);
      },
    );
  }

  void _showFullHistoryModal(
    BuildContext context,
    List<Map<String, dynamic>> logs,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2432) : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                controller: controller,
                child: Column(
                  children: [
                    Container(
                      height: 4,
                      width: 40,
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    CycleHistory(
                      isDark: isDark,
                      logs: logs,
                      limit: logs.length,
                      onItemTap: (log) {
                        Navigator.pop(context);
                        _showUpdateCycleModal(context, log: log);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
