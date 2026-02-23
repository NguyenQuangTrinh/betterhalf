import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:betterhalf/src/features/settings/data/services/connection_service.dart';
import '../../../tasks/presentation/pages/shared_tasks_page.dart';
import 'package:betterhalf/src/providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CoupleProfilePage extends StatefulWidget {
  const CoupleProfilePage({super.key});

  @override
  State<CoupleProfilePage> createState() => _CoupleProfilePageState();
}

class _CoupleProfilePageState extends State<CoupleProfilePage> {
  // Mock Data removed, using real data now

  String _getZodiacSign(DateTime? date) {
    if (date == null) return "Cập nhật";
    final day = date.day;
    final month = date.month;

    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) {
      return "Bạch Dương";
    }
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) {
      return "Kim Ngưu";
    }
    if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) {
      return "Song Tử";
    }
    if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) {
      return "Cự Giải";
    }
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return "Sư Tử";
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return "Xử Nữ";
    if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) {
      return "Thiên Bình";
    }
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) {
      return "Bọ Cạp";
    }
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) {
      return "Nhân Mã";
    }
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) {
      return "Ma Kết";
    }
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) {
      return "Bảo Bình";
    }
    if ((month == 2 && day >= 19) || (month == 3 && day <= 20)) {
      return "Song Ngư";
    }
    return "";
  }

  // Helper to format date like "20 Tháng 10, 2020"
  String _formatDate(DateTime date) {
    return "${date.day} Tháng ${date.month}, ${date.year}";
  }

  final ConnectionService _connectionService = ConnectionService();

  DateTime? _parseDate(dynamic date) {
    if (date == null) return null;
    if (date is Timestamp) return date.toDate();
    if (date is String) return DateTime.tryParse(date);
    return null;
  }

  List<BoxShadow> _getShadow(bool isDark) {
    return isDark
        ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ]
        : [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ];
  }

  Future<void> _handleDateEdit(
    BuildContext context,
    AuthProvider auth,
    String field,
    DateTime? initialDate,
  ) async {
    final picked = await showDatePicker(
      context: context,
      locale: const Locale('vi', 'VN'),
      initialDate: initialDate ?? DateTime(2025),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      if (field == 'anniversaryDate') {
        await auth.updateCoupleData({field: Timestamp.fromDate(picked)});
      } else {
        await auth.updateUser({field: Timestamp.fromDate(picked)});
      }
    }
  }

  Future<void> _handleBioEdit(
    BuildContext context,
    AuthProvider auth,
    String? currentBio,
  ) async {
    final controller = TextEditingController(text: currentBio);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cập nhật giới thiệu"),
        content: TextField(
          controller: controller,
          maxLines: 3,
          maxLength: 150,
          decoration: const InputDecoration(
            hintText: "Nhập lời giới thiệu...",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              if (controller.text.isNotEmpty) {
                await auth.updateCoupleData({'bioQuote': controller.text});
              }
            },
            child: const Text("Lưu"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
          'Quản lý hồ sơ cặp đôi',
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
          icon: Icon(Icons.arrow_back_ios, color: primaryTextColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final user = auth.user;
          if (user == null) return const SizedBox();

          return FutureBuilder<Map<String, dynamic>?>(
            future: auth.partnerId != null
                ? _connectionService.getUserData(auth.partnerId!)
                : Future.value(null),
            builder: (context, snapshot) {
              final partnerData = snapshot.data;
              final userData = auth.userData ?? {};

              // User Info
              // User Info
              final userName =
                  userData['firstName'] ??
                  userData['name'] ??
                  user.displayName ??
                  'Tôi';
              final userAvatar = userData['avatarUrl'];
              final userDob = _parseDate(userData['dob']);
              final userZodiac = _getZodiacSign(userDob);

              // Partner Info
              final partnerName =
                  partnerData?['firstName'] ??
                  partnerData?['name'] ??
                  'Người ấy';
              final partnerAvatar = partnerData?['avatarUrl'];
              final partnerDob = _parseDate(partnerData?['dob']);
              final partnerZodiac = _getZodiacSign(partnerDob);

              // Relationship Info
              final coupleData = auth.coupleData;
              final anniversaryDate = _parseDate(
                coupleData?['anniversaryDate'],
              );
              final bioQuote = coupleData?['bioQuote'] as String?;

              // Calculate days together
              final daysTogether = anniversaryDate != null
                  ? DateTime.now().difference(anniversaryDate).inDays
                  : 0;

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: Column(
                    children: [
                      // --- Header (Avatars) ---
                      _buildHeader(
                        isDark,
                        primaryTextColor,
                        userZodiac,
                        partnerZodiac,
                        userName,
                        partnerName,
                        userAvatar,
                        partnerAvatar,
                      ),

                      const SizedBox(height: 32),

                      // --- Anniversary Card ---
                      _buildSectionTitle(
                        'NGÀY KỶ NIỆM',
                        secondaryTextColor,
                        trailing: "Chỉnh sửa",
                        onTrailingTap: () => _handleDateEdit(
                          context,
                          auth,
                          'anniversaryDate',
                          anniversaryDate,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: _getShadow(isDark),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFF4B89EA),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.calendar_today,
                                color: Color(0xFF38BDF8),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    anniversaryDate != null
                                        ? _formatDate(anniversaryDate)
                                        : "Chưa cập nhật",
                                    style: GoogleFonts.inter(
                                      color: primaryTextColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    anniversaryDate != null
                                        ? "${daysTogether.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} ngày bên nhau"
                                        : "Hãy thiết lập ngày kỷ niệm",
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
                      ),

                      const SizedBox(height: 24),

                      // --- Introduction Card ---
                      _buildSectionTitle(
                        'GIỚI THIỆU CHUNG',
                        secondaryTextColor,
                        trailing: "Sửa",
                        onTrailingTap: () =>
                            _handleBioEdit(context, auth, bioQuote),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF4B89EA).withOpacity(0.3),
                          ),
                          gradient: isDark
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFF1E2432),
                                    Color(0xFF161B22),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          boxShadow: _getShadow(isDark),
                        ),
                        child: Stack(
                          children: [
                            Text(
                              "❝",
                              style: TextStyle(
                                fontSize: 40,
                                color: const Color(0xFF4B89EA).withOpacity(0.3),
                                height: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Text(
                                bioQuote ??
                                    "Hãy viết đôi dòng giới thiệu về câu chuyện tình yêu của hai bạn...",
                                style: GoogleFonts.inter(
                                  color: bioQuote != null
                                      ? primaryTextColor.withValues(alpha: 0.9)
                                      : secondaryTextColor,
                                  fontStyle: FontStyle.italic,
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Positioned(
                              bottom: -10,
                              right: 0,
                              child: Text(
                                "❞",
                                style: TextStyle(
                                  fontSize: 40,
                                  color: const Color(
                                    0xFF4B89EA,
                                  ).withOpacity(0.3),
                                  height: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                      // --- Utilities Section ---
                      _buildSectionTitle('TIỆN ÍCH CHUNG', secondaryTextColor),
                      const SizedBox(height: 8),
                      // Shared Tasks Button
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SharedTasksPage(onBack: () => null),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: _getShadow(isDark),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFE91E63,
                                  ).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.task_alt,
                                  color: Color(0xFFE91E63),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Công việc chung",
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: primaryTextColor,
                                      ),
                                    ),
                                    Text(
                                      "Quản lý to-do list cùng nhau",
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: secondaryTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: secondaryTextColor,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // --- Members Section ---
                      _buildSectionTitle(
                        'QUẢN LÝ THÀNH VIÊN',
                        secondaryTextColor,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: _getShadow(isDark),
                        ),
                        child: Column(
                          children: [
                            _buildMemberTile(
                              "$userName (Bạn)",
                              "Hồ sơ, biệt danh & sở thích",
                              userAvatar,
                              true,
                              primaryTextColor,
                              secondaryTextColor,
                            ),
                            Divider(
                              height: 1,
                              color: isDark ? Colors.white10 : Colors.black12,
                              indent: 64,
                              endIndent: 16,
                            ),
                            _buildMemberTile(
                              partnerName,
                              "Hồ sơ, biệt danh & sở thích",
                              partnerAvatar,
                              false,
                              primaryTextColor,
                              secondaryTextColor,
                            ),
                            Divider(
                              height: 1,
                              color: isDark ? Colors.white10 : Colors.black12,
                              indent: 64,
                              endIndent: 16,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF1B5E20,
                                      ), // Green bg
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.link,
                                      color: Colors.greenAccent,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Trạng thái kết nối",
                                          style: GoogleFonts.inter(
                                            color: primaryTextColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          "Đang kết nối với $partnerName",
                                          style: GoogleFonts.inter(
                                            color: Colors.greenAccent,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.red.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      "Ngắt kết nối",
                                      style: GoogleFonts.inter(
                                        color: Colors.redAccent,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // --- Personal Info Section ---
                      _buildSectionTitle(
                        'THÔNG TIN CÁ NHÂN',
                        secondaryTextColor,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: _getShadow(isDark),
                        ),
                        child: Column(
                          children: [
                            _buildInfoTile(
                              Icons.cake,
                              const Color(0xFF4B89EA),
                              "Ngày sinh của bạn",
                              userDob != null
                                  ? "${userDob.day}/${userDob.month}/${userDob.year} ($userZodiac)"
                                  : "Cập nhật ngày sinh",
                              primaryTextColor,
                              secondaryTextColor,
                              onEdit: () => _handleDateEdit(
                                context,
                                auth,
                                'dob',
                                userDob,
                              ),
                            ),
                            Divider(
                              height: 1,
                              color: isDark ? Colors.white10 : Colors.black12,
                              indent: 56,
                              endIndent: 16,
                            ),
                            _buildInfoTile(
                              Icons.cake_outlined,
                              const Color(0xFFE91E63),
                              "Ngày sinh người ấy",
                              partnerDob != null
                                  ? "${partnerDob.day}/${partnerDob.month}/${partnerDob.year} ($partnerZodiac)"
                                  : "Chưa cập nhật",
                              primaryTextColor,
                              secondaryTextColor,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),
                      Text(
                        "Thông tin được bảo mật và chỉ chia sẻ giữa hai bạn.",
                        style: GoogleFonts.inter(
                          color: secondaryTextColor,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(
    String title,
    Color color, {
    String? trailing,
    VoidCallback? onTrailingTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        if (trailing != null)
          GestureDetector(
            onTap: onTrailingTap,
            child: Text(
              trailing,
              style: GoogleFonts.inter(
                color: const Color(0xFF38BDF8),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(
    bool isDark,
    Color primaryColor,
    String uZodiac,
    String pZodiac,
    String userName,
    String partnerName,
    String? userAvatar,
    String? partnerAvatar,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // User
        Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 36,
                    backgroundImage:
                        (userAvatar != null && userAvatar.isNotEmpty)
                        ? NetworkImage(userAvatar) as ImageProvider
                        : const AssetImage('assets/images/boy_avatar.png'),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFF4B89EA), // Blue
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              userName,
              style: GoogleFonts.inter(
                color: primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2432), // Dark badge
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF4B89EA).withOpacity(0.5),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.stars, color: Color(0xFF4B89EA), size: 10),
                  const SizedBox(width: 4),
                  Text(
                    uZodiac,
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(width: 24),
        const Icon(Icons.favorite, color: Color(0xFFE91E63), size: 28), // Heart
        const SizedBox(width: 24),

        // Partner
        Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ), // Maybe gold for female?
                  ),
                  child: CircleAvatar(
                    radius: 36,
                    backgroundImage:
                        (partnerAvatar != null && partnerAvatar.isNotEmpty)
                        ? NetworkImage(partnerAvatar) as ImageProvider
                        : const AssetImage('assets/images/girl_avatar.png'),
                    // backgroundColor: Colors.grey,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFF5A6372), // Grey/Dark
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              partnerName,
              style: GoogleFonts.inter(
                color: primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF2D1E2F), // Purplish dark badge
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFE91E63).withOpacity(0.5),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.stars, color: Color(0xFFE91E63), size: 10),
                  const SizedBox(width: 4),
                  Text(
                    pZodiac,
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMemberTile(
    String name,
    String subtitle,
    String? avatarUrl,
    bool isMe,
    Color primaryColor,
    Color subColor,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
            ? NetworkImage(avatarUrl) as ImageProvider
            : AssetImage(
                isMe
                    ? 'assets/images/boy_avatar.png'
                    : 'assets/images/girl_avatar.png',
              ),
        radius: 20,
      ),
      title: Text(
        name,
        style: GoogleFonts.inter(
          color: primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(color: subColor, fontSize: 12),
      ),
      trailing: Icon(Icons.chevron_right, color: subColor),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
    );
  }

  Widget _buildInfoTile(
    IconData icon,
    Color iconBg,
    String title,
    String subtitle,
    Color primaryColor,
    Color subColor, {
    VoidCallback? onEdit,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconBg.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconBg, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(color: subColor, fontSize: 12),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          color: primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      trailing: onEdit != null
          ? GestureDetector(
              onTap: onEdit,
              child: Icon(Icons.edit, color: subColor, size: 16),
            )
          : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
