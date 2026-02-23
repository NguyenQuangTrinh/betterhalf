import 'package:betterhalf/src/features/calendar_cycle/presentation/pages/calendar_cycle_page.dart';
import 'package:betterhalf/src/features/gallery/presentation/pages/gallery_page.dart';
import 'package:betterhalf/src/features/games/presentation/pages/game_page.dart';
import 'package:betterhalf/src/features/notifications/presentation/pages/notification_page.dart'; // Correctly placed import
import 'package:betterhalf/src/features/settings/presentation/pages/settings_page.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:betterhalf/src/features/weather_place/presentation/pages/place_weather_page.dart';
import 'package:betterhalf/src/features/tasks/presentation/pages/shared_tasks_page.dart';
import 'package:betterhalf/src/features/tasks/presentation/pages/add_task_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:betterhalf/src/providers/auth_provider.dart';

import '../widgets/custom_bottom_nav.dart';
import '../widgets/home_content_widgets.dart';
import '../widgets/love_counter_card.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/weather_info_card.dart';

class HomePage extends StatefulWidget {
  final String title;

  const HomePage({super.key, required this.title});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  bool _isGalleryMode = false;

  // Custom Navigation History Stack to handle nested navigation within modes
  // Stores past states: (index, isGalleryMode)
  final List<({int index, bool isGalleryMode})> _navigationStack = [];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? const Color(0xFF161B22)
        : const Color(0xFFF3F5FA);

    // Mock Data
    // final startDate = DateTime(2023, 2, 14);

    // Define which indices should have hidden Bottom Nav
    // Hide on Map (2), Calendar (4), Tasks (6)
    final hideNavIndices = [2, 3];
    // Note: Index 5 (Game) is NOT hidden, so it will show the nav bar.

    return WillPopScope(
      onWillPop: () async {
        // If there is history, go back to previous state
        if (_navigationStack.isNotEmpty) {
          final previousState = _navigationStack.removeLast();
          setState(() {
            _currentIndex = previousState.index;
            _isGalleryMode = previousState.isGalleryMode;
          });
          return false;
        }

        // If no history but somehow deeper in navigation (e.g. initial launch to deep link?)
        // Or if user wants to exit from non-home page without history (rare case with this logic)
        // Fallback: If not at Home (0), go Home.
        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
            _isGalleryMode = false;
          });
          return false;
        }

        // System handles exit if at Home and empty stack
        return true;
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        // Removed bottomNavigationBar property to use Stack for custom positioning
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              // --- Main Content Switcher ---
              Positioned.fill(
                child: IndexedStack(
                  index: _currentIndex,
                  children: [
                    // Index 0: Home Dashboard
                    _buildHomeDashboard(isDark),

                    // Index 1: Gallery (Memories)
                    GalleryPage(onBack: () => _handleManualBack()),

                    // Index 2: Place & Weather (Map replacement)
                    // Index 2: Place & Weather (Map replacement)
                    PlaceWeatherPage(onBack: () => _handleManualBack()),

                    // Index 3: Settings
                    SettingsPage(onBack: () => _handleManualBack()),

                    // Index 4: Calendar
                    CalendarCyclePage(onBack: () => _handleManualBack()),

                    // Index 5: Game
                    const GamePage(),

                    // Index 6: Shared Tasks
                    SharedTasksPage(onBack: () => _handleManualBack()),
                  ],
                ),
              ),

              // --- Bottom Nav Bar (Positioned at bottom) ---
              if (!hideNavIndices.contains(_currentIndex))
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: CustomBottomNav(
                    currentIndex: _currentIndex,
                    isGalleryMode: _isGalleryMode,
                    onTap: (index) {
                      if (_currentIndex == index) return;

                      setState(() {
                        // Push current state to stack before moving
                        _navigationStack.add((
                          index: _currentIndex,
                          isGalleryMode: _isGalleryMode,
                        ));

                        if (!_isGalleryMode) {
                          // Switching from Home Mode
                          if (index == 1 || index == 6) {
                            _isGalleryMode =
                                true; // Switch to Gallery/Secondary Nav
                          }
                          _currentIndex = index;
                        } else {
                          // In Gallery Mode
                          _currentIndex = index;
                        }
                      });
                    },
                  ),
                ),
              // --- Floating FAB (Positioned relative to Stack, overlapping Nav Bar) ---
              // Only show FAB on Home (0) and maybe others, but NOT on Tasks (2) as it has its own FAB.
              if (!_isGalleryMode && !hideNavIndices.contains(_currentIndex))
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 65,
                      height: 65,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFF67B0F0), Color(0xFF4B89EA)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x404B89EA),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: FloatingActionButton(
                        onPressed: () {
                          _showQuickAddMenu(context);
                        },
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleManualBack() {
    if (_navigationStack.isNotEmpty) {
      final previousState = _navigationStack.removeLast();
      setState(() {
        _currentIndex = previousState.index;
        _isGalleryMode = previousState.isGalleryMode;
      });
    } else {
      if (_currentIndex != 0) {
        setState(() {
          _currentIndex = 0;
          _isGalleryMode = false;
        });
      }
    }
  }

  void _showQuickAddMenu(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF1E2432) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white54 : Colors.black54;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'Thêm mới',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Lưu giữ mọi khoảnh khắc yêu thương',
                style: GoogleFonts.inter(fontSize: 14, color: subTextColor),
              ),
              const SizedBox(height: 32),

              // Grid Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildQuickActionItem(
                    context,
                    icon: Icons.camera_alt,
                    label: 'Thêm ảnh',
                    color: const Color(0xFF4B89EA),
                    bgColor: const Color(0xFFE3F2FD),
                    isDark: isDark,
                  ),
                  _buildQuickActionItem(
                    context,
                    icon: Icons.check_circle,
                    label: 'Công việc',
                    color: const Color(0xFF2ECC71),
                    bgColor: const Color(0xFFE8F5E9),
                    isDark: isDark,
                    onTap: () {
                      final authProvider = Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      );
                      final coupleId = authProvider.coupleId;
                      final userId = authProvider.user?.uid;

                      if (coupleId != null && userId != null) {
                        Navigator.pop(context); // Close sheet
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                AddTaskPage(coupleId: coupleId, userId: userId),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Vui lòng kết nối với người ấy để sử dụng tính năng này",
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildQuickActionItem(
                    context,
                    icon: Icons.location_on,
                    label: 'Check-in',
                    color: const Color(0xFFFF6B6B),
                    bgColor: const Color(0xFFFFEBEE),
                    isDark: isDark,
                  ),
                  _buildQuickActionItem(
                    context,
                    icon: Icons.edit_note,
                    label: 'Nhật ký',
                    color: const Color(0xFFFFD93D),
                    bgColor: const Color(0xFFFFFDE7),
                    isDark: isDark,
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Mini Game Tile
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : const Color(0xFFF0F4FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.gamepad,
                        color: Color(0xFF9B59B6),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mini Game',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: textColor,
                            ),
                          ),
                          Text(
                            'Giải trí cùng nhau',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: subTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: subTextColor),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Close Button
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, size: 20, color: textColor),
                  label: Text(
                    'Đóng',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.grey.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActionItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2C3545) : bgColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: isDark ? color : color, size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeDashboard(bool isDark) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final userData = authProvider.userData;
        final coupleData = authProvider.coupleData;
        final myName =
            userData?['firstName'] ??
            userData?['name']?.split(' ').last ??
            'Bạn';

        // Determine Start Date
        // Priority: 'anniversaryDate' -> 'createdAt' -> Now
        DateTime loveStartDate = DateTime.now();
        if (coupleData != null) {
          if (coupleData['anniversaryDate'] != null) {
            loveStartDate = (coupleData['anniversaryDate'] as Timestamp)
                .toDate();
          } else if (coupleData['createdAt'] != null) {
            loveStartDate = (coupleData['createdAt'] as Timestamp).toDate();
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.only(
            bottom: 120,
          ), // More space for BottomNav + FAB
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // --- Header ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Xin chào,',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        // Dynamic Name Display
                        Builder(
                          builder: (context) {
                            String displayName = myName;
                            final partnerData = authProvider.partnerData;
                            if (partnerData != null) {
                              final partnerName =
                                  partnerData['firstName'] ??
                                  partnerData['name']?.split(' ').last ??
                                  'Người thương';
                              displayName = "$myName & $partnerName";
                            }

                            return Row(
                              children: [
                                Text(
                                  displayName,
                                  style: GoogleFonts.inter(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                if (authProvider.partnerId != null) ...[
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.favorite,
                                    color: Colors.redAccent,
                                    size: 20,
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                    GestureDetector(
                      // Changed to GestureDetector for better touch handling
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const NotificationPage(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF2C3545)
                              : Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Badge(
                          smallSize: 8,
                          backgroundColor: Colors.red,
                          child: Icon(
                            Icons.notifications_none,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // --- Love Counter ---
                LoveCounterCard(startDate: loveStartDate),

                const SizedBox(height: 30),

                // --- Quick Actions ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    QuickActionButton(
                      icon: Icons.water_drop,
                      label: 'Chu kỳ',
                      iconColor: const Color(0xFFFF6B6B),
                      onTap: () {
                        setState(() {
                          _currentIndex = 4; // Switch to Calendar/Cycle
                        });
                      },
                    ),
                    QuickActionButton(
                      icon: Icons.gamepad,
                      label: 'Game',
                      iconColor: const Color(0xFF4BCFFA),
                      onTap: () {
                        setState(() {
                          _currentIndex = 5; // Switch to Game
                        });
                      },
                    ),
                    QuickActionButton(
                      icon: Icons.location_on,
                      label: 'Check-in',
                      iconColor: const Color(0xFFFFD93D),
                      onTap: () {
                        setState(() {
                          _currentIndex = 2; // Switch to Map
                        });
                      },
                    ),
                    QuickActionButton(
                      icon: Icons.account_balance_wallet,
                      label: 'Ví chung',
                      iconColor: const Color(0xFF6C5CE7),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Tính năng 'Ví chung' đang phát triển!",
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // --- Weather Card ---
                const WeatherInfoCard(
                  temperature: 24,
                  condition: 'Cloudy',
                  description: 'Mưa nhẹ, trời se lạnh',
                  humidity: 60,
                  locationName: 'Hà Nội',
                ),

                const SizedBox(height: 30),

                // --- Content Row (Events & Checklists) ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column (Memory) - Resized and ratio balanced
                    Expanded(
                      flex: 1, // Balanced 1:1 ratio
                      child: Container(
                        height: 180, // Reduced from 220
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          image: const DecorationImage(
                            image: NetworkImage(
                              'https://placeholder.com/couple_moment.jpg',
                            ),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.7),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 16,
                              left: 16,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Kỷ niệm',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Đà Lạt - 12/2023',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Right Column (Event + Tasks)
                    const Expanded(
                      flex: 1, // Balanced 1:1 ratio
                      child: Column(
                        children: [
                          UpcomingEventCard(
                            title: 'Kỷ niệm 3 năm',
                            date: '2 NGÀY TỚI',
                            time: '19:00',
                            location: 'Nhà hàng Lotus',
                          ),
                          SizedBox(height: 16),
                          CheckListCard(
                            items: ['Mua hoa tặng em', 'Đặt vé xem phim'],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                Center(
                  child: Text(
                    'Vuốt để xem dòng thời gian',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                ),
                const Center(
                  child: Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
