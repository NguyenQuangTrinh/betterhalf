import 'package:betterhalf/src/features/settings/data/services/connection_service.dart';
import 'package:betterhalf/src/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final ConnectionService _connectionService = ConnectionService();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Type definition for custom colors to match design
    final backgroundColor = isDark
        ? const Color(0xFF161B22)
        : const Color(0xFFF3F5FA);
    final cardColor = isDark ? const Color(0xFF1E2432) : Colors.white;
    final primaryTextColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark ? Colors.white54 : Colors.black54;
    final searchBarColor = isDark ? const Color(0xFF2C3545) : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // --- Header ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Thông báo',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {},
                    icon: Icon(
                      Icons.done_all,
                      color: Colors.blue[400],
                      size: 18,
                    ),
                    label: Text(
                      'Đã đọc',
                      style: GoogleFonts.inter(
                        color: Colors.blue[400],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- Search Bar ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: searchBarColor,
                  borderRadius: BorderRadius.circular(30),
                  border: isDark
                      ? null
                      : Border.all(color: Colors.grey.shade200),
                ),
                child: TextField(
                  style: GoogleFonts.inter(color: primaryTextColor),
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm thông báo...',
                    hintStyle: GoogleFonts.inter(color: secondaryTextColor),
                    prefixIcon: Icon(Icons.search, color: secondaryTextColor),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // --- Filter Chips ---
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildFilterChip(
                    'Tất cả',
                    Icons.mark_chat_unread,
                    true,
                    isDark,
                    primaryTextColor,
                  ),
                  const SizedBox(width: 10),
                  _buildFilterChip(
                    'Ảnh',
                    Icons.image,
                    false,
                    isDark,
                    primaryTextColor,
                  ),
                  const SizedBox(width: 10),
                  _buildFilterChip(
                    'Lịch',
                    Icons.calendar_today,
                    false,
                    isDark,
                    primaryTextColor,
                  ),
                  const SizedBox(width: 10),
                  _buildFilterChip(
                    'Công việc',
                    Icons.check_circle_outline,
                    false,
                    isDark,
                    primaryTextColor,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // --- Notification List ---
            Expanded(
              child: Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      // --- Connection Requests Section ---
                      if (auth.user != null && !auth.isConnected)
                        StreamBuilder<List<Map<String, dynamic>>>(
                          stream: _connectionService.getReceivedRequests(
                            auth.user!.uid,
                          ),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            final requests = snapshot.data!;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionHeader(
                                  'Lời mời kết nối',
                                  const Color(0xFF4B89EA),
                                ),
                                const SizedBox(height: 12),
                                ...requests
                                    .map(
                                      (req) => _buildConnectionRequestItem(
                                        context,
                                        req,
                                        auth,
                                        cardColor,
                                        primaryTextColor,
                                        secondaryTextColor,
                                        isDark,
                                      ),
                                    )
                                    .toList(),
                                const SizedBox(height: 24),
                              ],
                            );
                          },
                        ),

                      // Section: Mới
                      _buildSectionHeader('Mới', secondaryTextColor),
                      const SizedBox(height: 12),
                      _buildNotificationItem(
                        title: 'Sắp đến kỳ kinh nguyệt',
                        description:
                            'Nhắc nhở: 2 ngày nữa là đến kỳ. Anh đã mua sô-cô-la cho em rồi nhé! ❤️',
                        time: '10 phút trước',
                        icon: Icons.favorite,
                        iconColor: const Color(0xFFFF6B6B),
                        iconBgColor: const Color(0xFFFF6B6B).withOpacity(0.1),
                        isUnread: true,
                        cardColor: cardColor,
                        primaryTextColor: primaryTextColor,
                        secondaryTextColor: secondaryTextColor,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 12),
                      _buildNotificationItem(
                        title: 'Kỷ niệm Đà Lạt',
                        description:
                            'Anh yêu đã thêm 5 ảnh mới vào album "Chuyến đi Đà Lạt".',
                        time: '1 giờ trước',
                        icon: Icons.image,
                        iconColor: const Color(0xFF4B89EA),
                        iconBgColor: const Color(0xFF4B89EA).withOpacity(0.1),
                        isUnread: true,
                        cardColor: cardColor,
                        primaryTextColor: primaryTextColor,
                        secondaryTextColor: secondaryTextColor,
                        isDark: isDark,
                        contentImage: Row(
                          children: [
                            _buildMiniImage(),
                            Transform.translate(
                              offset: const Offset(-10, 0),
                              child: _buildMiniImage(),
                            ),
                            Transform.translate(
                              offset: const Offset(-20, 0),
                              child: _buildMiniImage(),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Section: Trước đó
                      _buildSectionHeader('Trước đó', secondaryTextColor),
                      const SizedBox(height: 12),
                      _buildNotificationItem(
                        title: 'Dự báo thời tiết',
                        description:
                            'Ngày mai có thể mưa vào buổi chiều, nhớ mang ô khi đi làm nhé!',
                        time: 'Hôm qua',
                        icon: Icons.wb_sunny,
                        iconColor: const Color(0xFFFFD93D),
                        iconBgColor: const Color(0xFFFFD93D).withOpacity(0.1),
                        isUnread: false,
                        cardColor: cardColor,
                        primaryTextColor: primaryTextColor,
                        secondaryTextColor: secondaryTextColor,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 12),
                      _buildNotificationItem(
                        title: 'Công việc hoàn thành',
                        description: 'Đặt bàn ăn tối kỷ niệm',
                        time: 'Hôm qua',
                        icon: Icons.check_circle,
                        iconColor: const Color(0xFF2ECC71),
                        iconBgColor: const Color(0xFF2ECC71).withOpacity(0.1),
                        isUnread: false,
                        cardColor: cardColor,
                        primaryTextColor: primaryTextColor,
                        secondaryTextColor: secondaryTextColor,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 12),
                      _buildNotificationItem(
                        title: 'Lời mời chơi game',
                        description:
                            'Em yêu muốn thách đấu bạn trong trò chơi "Ai hiểu ai hơn?"',
                        time: '2 ngày trước',
                        icon: Icons.gamepad,
                        iconColor: const Color(0xFF9B59B6),
                        iconBgColor: const Color(0xFF9B59B6).withOpacity(0.1),
                        isUnread: false,
                        cardColor: cardColor,
                        primaryTextColor: primaryTextColor,
                        secondaryTextColor: secondaryTextColor,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 40),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF29B6F6),
        child: const Icon(Icons.email, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    IconData icon,
    bool isSelected,
    bool isDark,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF29B6F6)
            : (isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white70 : Colors.black54),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white70 : Colors.black54),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color textColor) {
    return Text(
      title,
      style: GoogleFonts.inter(
        color: textColor,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );
  }

  Widget _buildConnectionRequestItem(
    BuildContext context,
    Map<String, dynamic> req,
    AuthProvider auth,
    Color cardColor,
    Color primaryTextColor,
    Color secondaryTextColor,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF4B89EA).withOpacity(0.3)),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.pinkAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.favorite, color: Colors.pinkAccent),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      req['senderEmail'] ?? 'Người lạ',
                      style: GoogleFonts.inter(
                        color: primaryTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Đã gửi lời mời kết nối đôi với bạn ❤️',
                      style: GoogleFonts.inter(
                        color: secondaryTextColor,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    await _connectionService.rejectConnectionRequest(req['id']);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Từ chối',
                    style: GoogleFonts.inter(
                      color: secondaryTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    await _connectionService.approveConnectionRequest(
                      req['id'],
                      req['senderUid'],
                      auth.user!.uid,
                    );
                    if (mounted) {
                      await auth.refreshUserData();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã kết nối thành công!')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4B89EA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                  child: Text(
                    'Đồng ý',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniImage() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        image: const DecorationImage(
          image: NetworkImage('https://placeholder.com/scene.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required String title,
    required String description,
    required String time,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required bool isUnread,
    required Color cardColor,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required bool isDark,
    Widget? contentImage,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Box
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF2C2C2E)
                  : iconBgColor.withOpacity(
                      0.1,
                    ), // Adjusted for Dark Mode match
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor),
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
                    color: primaryTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    color: secondaryTextColor,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                if (contentImage != null) ...[
                  const SizedBox(height: 8),
                  contentImage,
                ],
                const SizedBox(height: 8),
                Text(
                  time,
                  style: GoogleFonts.inter(
                    color: secondaryTextColor.withOpacity(0.6),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          // Unread Dot
          if (isUnread)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF29B6F6),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
