import 'package:betterhalf/src/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../features/auth/presentation/pages/login_page.dart';
import 'package:betterhalf/src/features/settings/data/services/connection_service.dart';
import 'package:betterhalf/src/features/settings/presentation/pages/couple_profile_page.dart';
// ... (imports remain similar, assume ConnectionService is imported)

class SettingsPage extends StatefulWidget {
  final VoidCallback? onBack;

  const SettingsPage({super.key, this.onBack});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Local state for toggles (mocking preferences)
  bool _remindAnniversary = true;
  bool _weatherForecast = true;
  bool _partnerMessages = true;
  bool _appLock = false;
  bool _hideSensitive = false;
  int _selectedThemeIndex = 0; // 0: Mùa Yêu, 1: Thu Vàng, 2: Noel

  final ConnectionService _connectionService = ConnectionService();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Theme Colors
    final backgroundColor = isDark
        ? const Color(0xFF161B22)
        : const Color(0xFFF3F5FA);
    final cardColor = isDark ? const Color(0xFF1E2432) : Colors.white;
    final primaryTextColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark ? Colors.white54 : Colors.black54;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Cài đặt cá nhân hóa',
          style: GoogleFonts.inter(
            color: primaryTextColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: primaryTextColor, size: 28),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Profile Card ---
              Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  final user = auth.user;
                  final displayName = user?.displayName ?? 'Người dùng';
                  final isConnected = auth.isConnected;

                  if (!isConnected) {
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
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: const Color(0xFF4B89EA),
                            child: Text(
                              displayName.isNotEmpty
                                  ? displayName[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName,
                                  style: GoogleFonts.inter(
                                    color: primaryTextColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'Đang độc thân',
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
                    );
                  }

                  // Connected State UI
                  // Connected State UI
                  return FutureBuilder<Map<String, dynamic>?>(
                    future: _connectionService.getUserData(auth.partnerId!),
                    builder: (context, snapshot) {
                      final partnerData = snapshot.data;
                      final partnerFirstName =
                          partnerData?['firstName'] ??
                          partnerData?['name']?.split(' ').last ??
                          'Người ấy';

                      final userFirstName =
                          auth.userData?['firstName'] ??
                          auth.user?.displayName?.split(' ').last ??
                          'Tôi';

                      // Avatar URLs
                      final userAvatarUrl = auth.userData?['avatarUrl'];
                      final partnerAvatarUrl = partnerData?['avatarUrl'];

                      // Dynamic Colors for Profile Card
                      final profileBg = isDark
                          ? const Color(0xFF1E2432)
                          : Colors.white;
                      final profileTextColor = isDark
                          ? Colors.white
                          : Colors.black87;
                      final profileSubTextColor = isDark
                          ? Colors.white54
                          : Colors.black54;
                      final borderColor = isDark
                          ? const Color(0xFF1E2432)
                          : Colors.white;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CoupleProfilePage(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 24,
                          ),
                          decoration: BoxDecoration(
                            color: profileBg,
                            borderRadius: BorderRadius.circular(30),
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
                            children: [
                              // Overlapping Avatars with Heart
                              SizedBox(
                                width: 76,
                                height: 48,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    // User Avatar (Left)
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: borderColor,
                                          width: 2,
                                        ),
                                        image: userAvatarUrl != null
                                            ? DecorationImage(
                                                image: NetworkImage(
                                                  userAvatarUrl,
                                                ),
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                        color: Colors.grey[800],
                                      ),
                                      child: userAvatarUrl == null
                                          ? Center(
                                              child: Text(
                                                userFirstName.isNotEmpty
                                                    ? userFirstName[0]
                                                          .toUpperCase()
                                                    : 'U',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            )
                                          : null,
                                    ),
                                    // Partner Avatar (Right, overlapping)
                                    Positioned(
                                      left: 28,
                                      child: Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: borderColor,
                                            width: 2,
                                          ),
                                          image: partnerAvatarUrl != null
                                              ? DecorationImage(
                                                  image: NetworkImage(
                                                    partnerAvatarUrl,
                                                  ),
                                                  fit: BoxFit.cover,
                                                )
                                              : null,
                                          color: Colors.grey[800],
                                        ),
                                        child: partnerAvatarUrl == null
                                            ? Center(
                                                child: Text(
                                                  partnerFirstName.isNotEmpty
                                                      ? partnerFirstName[0]
                                                            .toUpperCase()
                                                      : 'P',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              )
                                            : null,
                                      ),
                                    ),
                                    // Heart Icon (Center overlay)
                                    Positioned(
                                      left: 24,
                                      top: 12,
                                      child: Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: borderColor,
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(2),
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.favorite,
                                            color: Color(0xFF4B89EA),
                                            size: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Names and Subtitle
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$userFirstName & $partnerFirstName',
                                      style: GoogleFonts.inter(
                                        color: profileTextColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Quản lý hồ sơ đôi',
                                      style: GoogleFonts.inter(
                                        color: profileSubTextColor,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: profileSubTextColor,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 24),

              // --- Pending Requests Section ---
              Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  if (auth.user == null || auth.isConnected)
                    return const SizedBox.shrink();

                  return StreamBuilder<List<Map<String, dynamic>>>(
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
                          Text(
                            'LỜI MỜI KẾT NỐI',
                            style: GoogleFonts.inter(
                              color: secondaryTextColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...requests
                              .map(
                                (req) => Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: cardColor,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(
                                        0xFF4B89EA,
                                      ).withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: Colors.pinkAccent
                                            .withOpacity(0.1),
                                        child: const Icon(
                                          Icons.favorite,
                                          color: Colors.pinkAccent,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              req['senderEmail'] ?? 'Người lạ',
                                              style: GoogleFonts.inter(
                                                fontWeight: FontWeight.bold,
                                                color: primaryTextColor,
                                              ),
                                            ),
                                            Text(
                                              'Muốn kết nối với bạn',
                                              style: GoogleFonts.inter(
                                                fontSize: 12,
                                                color: secondaryTextColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.check_circle,
                                          color: Color(0xFF4B89EA),
                                        ),
                                        onPressed: () async {
                                          await _connectionService
                                              .approveConnectionRequest(
                                                req['id'],
                                                req['senderUid'],
                                                auth.user!.uid,
                                              );
                                          if (mounted) {
                                            await auth.refreshUserData();
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Đã kết nối thành công!',
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.cancel,
                                          color: Colors.redAccent,
                                        ),
                                        onPressed: () async {
                                          await _connectionService
                                              .rejectConnectionRequest(
                                                req['id'],
                                              );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                          const SizedBox(height: 24),
                        ],
                      );
                    },
                  );
                },
              ),

              // --- Theme Section ---
              Text(
                'GIAO DIỆN',
                style: GoogleFonts.inter(
                  color: secondaryTextColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 140,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildThemeCard(
                      'Mùa Yêu',
                      [const Color(0xFFFF69B4), const Color(0xFFE91E63)],
                      0,
                      isDark,
                      primaryTextColor,
                    ),
                    const SizedBox(width: 12),
                    _buildThemeCard(
                      'Thu Vàng',
                      [const Color(0xFFFFC107), const Color(0xFFFF9800)],
                      1,
                      isDark,
                      primaryTextColor,
                    ),
                    const SizedBox(width: 12),
                    _buildThemeCard(
                      'Noel',
                      [const Color(0xFFD32F2F), const Color(0xFF388E3C)],
                      2,
                      isDark,
                      primaryTextColor,
                    ),
                    const SizedBox(width: 12),
                    _buildThemeCard(
                      'Biển Xanh',
                      [const Color(0xFF42A5F5), const Color(0xFF1976D2)],
                      3,
                      isDark,
                      primaryTextColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Light/Dark Switch
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isDark ? Colors.white12 : Colors.black12,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          // Switch to Light Mode
                          context.read<ThemeProvider>().toggleTheme(false);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: !isDark ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: !isDark
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : [],
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.wb_sunny_outlined,
                                size: 18,
                                color: !isDark
                                    ? Colors.black87
                                    : secondaryTextColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Sáng',
                                style: GoogleFonts.inter(
                                  color: !isDark
                                      ? Colors.black87
                                      : secondaryTextColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          // Switch to Dark Mode
                          context.read<ThemeProvider>().toggleTheme(true);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF2C3545)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: isDark
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : [],
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.nightlight_round,
                                size: 18,
                                color: isDark
                                    ? Colors.white
                                    : secondaryTextColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Tối',
                                style: GoogleFonts.inter(
                                  color: isDark
                                      ? Colors.white
                                      : secondaryTextColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // --- Notifications ---
              Text(
                'THÔNG BÁO',
                style: GoogleFonts.inter(
                  color: secondaryTextColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
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
                child: Column(
                  children: [
                    _buildSwitchTile(
                      'Nhắc nhở ngày kỷ niệm',
                      FontAwesomeIcons.calendar,
                      const Color(0xFF4B89EA),
                      _remindAnniversary,
                      (v) => setState(() => _remindAnniversary = v),
                      primaryTextColor,
                    ),
                    Divider(
                      height: 1,
                      color: isDark ? Colors.white10 : Colors.black12,
                      indent: 50,
                      endIndent: 16,
                    ),
                    _buildSwitchTile(
                      'Dự báo thời tiết đôi',
                      Icons.wb_sunny,
                      const Color(0xFF29B6F6),
                      _weatherForecast,
                      (v) => setState(() => _weatherForecast = v),
                      primaryTextColor,
                    ),
                    Divider(
                      height: 1,
                      color: isDark ? Colors.white10 : Colors.black12,
                      indent: 50,
                      endIndent: 16,
                    ),
                    _buildSwitchTile(
                      'Tin nhắn từ người ấy',
                      Icons.message,
                      const Color(0xFF26A69A),
                      _partnerMessages,
                      (v) => setState(() => _partnerMessages = v),
                      primaryTextColor,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // --- Account & Privacy ---
              Text(
                'TÀI KHOẢN & RIÊNG TƯ',
                style: GoogleFonts.inter(
                  color: secondaryTextColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
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
                child: Column(
                  children: [
                    _buildActionTile(
                      'Đổi mật khẩu',
                      Icons.lock,
                      primaryTextColor,
                    ),
                    Divider(
                      height: 1,
                      color: isDark ? Colors.white10 : Colors.black12,
                      indent: 50,
                      endIndent: 16,
                    ),
                    _buildSwitchTile(
                      'Khóa ứng dụng (FaceID)',
                      Icons.filter_center_focus,
                      primaryTextColor.withOpacity(0.7),
                      _appLock,
                      (v) => setState(() => _appLock = v),
                      primaryTextColor,
                    ),
                    Divider(
                      height: 1,
                      color: isDark ? Colors.white10 : Colors.black12,
                      indent: 50,
                      endIndent: 16,
                    ),
                    _buildSwitchTile(
                      'Ẩn thông tin nhạy cảm',
                      Icons.visibility_off,
                      primaryTextColor.withOpacity(0.7),
                      _hideSensitive,
                      (v) => setState(() => _hideSensitive = v),
                      primaryTextColor,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // --- Footer Buttons ---
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: TextButton(
                    onPressed: () {
                      context.read<AuthProvider>().signOut().then((_) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                          (route) => false,
                        );
                      });
                    },
                    child: Text(
                      'Đăng xuất',
                      style: GoogleFonts.inter(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Connection Button
              Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  final isConnected = auth.isConnected;

                  if (isConnected) {
                    return SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () async {
                          // Show confirmation dialog before disconnecting
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Hủy kết đôi?'),
                              content: const Text(
                                'Bạn có chắc chắn muốn hủy kết nối với người này không?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Không'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    'Có',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true &&
                              auth.partnerId != null &&
                              auth.user != null) {
                            await _connectionService.disconnect(
                              auth.user!.uid,
                              auth.partnerId!,
                            );
                            await auth.refreshUserData();
                          }
                        },
                        child: Text(
                          'Hủy kết đôi',
                          style: GoogleFonts.inter(
                            color: Colors.red.withOpacity(0.8),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  } else {
                    return SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF4B89EA), // Primary Blue
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4B89EA).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextButton.icon(
                          onPressed: () =>
                              _showConnectionDialog(context, isDark),
                          icon: const Icon(
                            Icons.person_add,
                            color: Colors.white,
                          ),
                          label: Text(
                            'Tìm kết nối người yêu',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),

              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Phiên bản 1.0.2 • Love App Inc.',
                  style: GoogleFonts.inter(
                    color: secondaryTextColor,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeCard(
    String label,
    List<Color> colors,
    int index,
    bool isDark,
    Color textColor,
  ) {
    // Determine active state visually
    final isSelected = _selectedThemeIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedThemeIndex = index;
        });
      },
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100, // Reduced height for better fit in scroll
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: isSelected
                  ? Border.all(color: Colors.white, width: 3)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: colors.last.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              color: isSelected ? textColor : textColor.withOpacity(0.6),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    IconData icon,
    Color iconColor,
    bool value,
    Function(bool) onChanged,
    Color textColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFF4B89EA),
            inactiveTrackColor: Colors.grey[300],
            inactiveThumbColor: Colors.white,
            trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(String title, IconData icon, Color textColor) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: Colors.grey),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: () {},
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      visualDensity: VisualDensity.compact,
    );
  }

  void _showConnectionDialog(BuildContext context, bool isDark) {
    final emailController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF1E2432) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                'Kết nối với người ấy',
                style: GoogleFonts.inter(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Nhập email của người yêu để gửi lời mời kết nối.',
                    style: GoogleFonts.inter(
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: 'email.nguoiyeu@example.com',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.white30 : Colors.black38,
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.white10 : Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                  if (isLoading) ...[
                    const SizedBox(height: 16),
                    const CircularProgressIndicator(),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Hủy',
                    style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (emailController.text.isNotEmpty) {
                            setState(() => isLoading = true);
                            try {
                              final auth = context.read<AuthProvider>();
                              if (auth.user != null) {
                                await _connectionService.sendConnectionRequest(
                                  emailController.text.trim(),
                                  auth.user!.uid,
                                  auth.user!.email ?? '',
                                );
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Đã gửi lời mời kết nối!'),
                                    ),
                                  );
                                }
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      e.toString().replaceAll(
                                        'Exception: ',
                                        '',
                                      ),
                                    ),
                                  ),
                                );
                              }
                            } finally {
                              if (context.mounted) {
                                setState(() => isLoading = false);
                              }
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4B89EA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Gửi lời mời'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
