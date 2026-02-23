import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pokemon_memory_game_page.dart';
import 'game_2048_page.dart';

class GamePage extends StatelessWidget {
  const GamePage({super.key});

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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Của chúng mình',
                        style: GoogleFonts.inter(
                          color: primaryTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      Text(
                        'Cùng nhau xây dựng & giải trí',
                        style: GoogleFonts.inter(
                          color: secondaryTextColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 60,
                    height: 35,
                    child: Stack(
                      children: [
                        Positioned(
                          right: 0,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundImage: NetworkImage(
                              'https://placeholder.com/partner_avatar.jpg',
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundImage: NetworkImage(
                              'https://placeholder.com/user_avatar.jpg',
                            ),
                            backgroundColor: Colors.white, // Border effect
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // --- Stats Cards ---
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Đang làm',
                      '3',
                      Icons.assignment_outlined,
                      Colors.blue,
                      cardColor,
                      primaryTextColor,
                      secondaryTextColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Đã xong',
                      '12',
                      Icons.check_circle_outline,
                      Colors.green,
                      cardColor,
                      primaryTextColor,
                      secondaryTextColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // --- Shared Tasks ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Công việc chung',
                    style: GoogleFonts.inter(
                      color: primaryTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    '+ Thêm mới',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF4B89EA),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTaskTile(
                'Đi siêu thị mua đồ tối',
                'Giao cho: Anh',
                true,
                cardColor,
                primaryTextColor,
                secondaryTextColor,
              ),
              const SizedBox(height: 12),
              _buildTaskTile(
                'Đặt vé xem phim Mai',
                'Giao cho: Em',
                true,
                cardColor,
                primaryTextColor,
                secondaryTextColor,
                isFemale: true,
              ),
              const SizedBox(height: 12),
              _buildTaskTile(
                'Lên kế hoạch Đà Lạt',
                'Giao cho: Cả hai',
                false,
                cardColor,
                primaryTextColor,
                secondaryTextColor,
                isDone: true,
                isBoth: true,
              ),

              const SizedBox(height: 32),

              // --- Mini Games ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mini Game',
                    style: GoogleFonts.inter(
                      color: primaryTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'Xem tất cả',
                    style: GoogleFonts.inter(
                      color: secondaryTextColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Game Lists
              // Placeholder for rich game card
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.black, // Placeholder bg
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://placeholder.com/game_banner_2048.jpg',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.1),
                            Colors.black.withOpacity(0.8),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'MỚI',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // Centered content placeholder if image fails
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '2048 Classic',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                const Shadow(
                                  blurRadius: 4,
                                  color: Colors.black54,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Thử thách trí tuệ cực cuốn!',
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 14,
                              shadows: [
                                const Shadow(
                                  blurRadius: 4,
                                  color: Colors.black54,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Game Action Bar (Mock from image)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildIconAction(
                    Icons.home,
                    'Trang chủ',
                    true,
                    const Color(0xFF4B89EA),
                    secondaryTextColor,
                  ),
                  _buildIconAction(
                    Icons.favorite,
                    'Kỷ niệm',
                    false,
                    const Color(0xFF4B89EA),
                    secondaryTextColor,
                  ),
                  _buildIconAction(
                    Icons.apps,
                    'Tiện ích',
                    false,
                    const Color(0xFF4B89EA),
                    secondaryTextColor,
                  ),
                  _buildIconAction(
                    Icons.person,
                    'Tài khoản',
                    false,
                    const Color(0xFF4B89EA),
                    secondaryTextColor,
                  ),
                  // NOTE: The image shows a bottom tab bar here, but this page is INSIDE a tab bar.
                  // The image likely implies this "Game Dashboard" acts like a mini-app or the tab bar in the image IS the main app tab bar.
                  // Since I already have a main nav bar, I will OMIT this inner tab bar to avoid confusion,
                  // OR user wants this specific look. Given "hãy code giao diện như", I should probably omit the redundant nav
                  // or implement it as sub-categories for games if that's what it means.
                  // Re-reading image: It looks like the standard bottom nav.
                  // Since I have my own custom bottom nav, I will NOT duplicate it here inside the scroll view.
                ],
              ),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Game2048Page(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    foregroundColor: Colors.blue,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    'Chơi ngay',
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Pokemon Game Card
              Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: isDark
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Column(
                  children: [
                    Container(
                      height: 150,
                      color: const Color(0xFFCC0000), // Pokemon Red
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Positioned(
                            right: -20,
                            bottom: -20,
                            child: Icon(
                              Icons.catching_pokemon,
                              size: 150,
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          const Center(
                            child: Icon(
                              Icons.catching_pokemon,
                              size: 80,
                              color: Colors.white,
                            ),
                          ),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'CLASSIC',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pokemon Memory',
                            style: GoogleFonts.inter(
                              color: primaryTextColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Luyện trí nhớ với các thẻ bài Pokemon cổ điển! Tìm cặp hình giống nhau.',
                            style: GoogleFonts.inter(
                              color: secondaryTextColor,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const PokemonMemoryGamePage(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(
                                  0xFFCC0000,
                                ).withOpacity(0.1),
                                foregroundColor: const Color(0xFFCC0000),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              child: Text(
                                'Chơi ngay',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2048 Game Card
              Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: isDark
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Column(
                  children: [
                    Container(
                      height: 150,
                      color: const Color(0xFFEDC22E),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          const Center(
                            child: Text(
                              '2048',
                              style: TextStyle(
                                fontSize: 60,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.grid_view,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'PUZZLE',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '2048 Classic',
                            style: GoogleFonts.inter(
                              color: primaryTextColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ghép các ô số giống nhau để đạt được ô 2048. Trò chơi trí tuệ gây nghiện!',
                            style: GoogleFonts.inter(
                              color: secondaryTextColor,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Game2048Page(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(
                                  0xFFEDC22E,
                                ).withOpacity(0.1),
                                foregroundColor: const Color(0xFFEDC22E),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              child: Text(
                                'Chơi ngay',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Wheel Game Card
              Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: isDark
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Column(
                  children: [
                    Container(
                      height: 150,
                      color: Colors.grey[900],
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Using an icon as placeholder for the colorful wheel
                          const Center(
                            child: Icon(
                              Icons.pie_chart,
                              size: 80,
                              color: Colors.orange,
                            ),
                          ),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.local_fire_department,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'STREAK 3',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vòng quay việc nhà',
                            style: GoogleFonts.inter(
                              color: primaryTextColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ai sẽ là người rửa bát hôm nay? Quay để quyết định!',
                            style: GoogleFonts.inter(
                              color: secondaryTextColor,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.withOpacity(0.1),
                                foregroundColor: Colors.blue,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              child: Text(
                                'Chơi ngay',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Drawing Game Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: isDark
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C3E50),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.edit, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Đoán ý đồng đội',
                            style: GoogleFonts.inter(
                              color: primaryTextColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Vẽ hình và để người kia đoán.',
                            style: GoogleFonts.inter(
                              color: secondaryTextColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 100), // Bottom padding for Nav
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String count,
    IconData icon,
    Color iconColor,
    Color cardColor,
    Color primaryTextColor,
    Color secondaryTextColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.inter(
                  color: secondaryTextColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            count,
            style: GoogleFonts.inter(
              color: primaryTextColor,
              fontWeight: FontWeight.bold,
              fontSize: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskTile(
    String title,
    String assignee,
    bool isRadio,
    Color cardColor,
    Color primaryTextColor,
    Color secondaryTextColor, {
    bool isFemale = false,
    bool isDone = false,
    bool isBoth = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: isDone ? Border.all(color: Colors.transparent) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isDone ? Colors.blue : Colors.grey,
                width: 2,
              ),
              color: isDone ? Colors.blue : null,
            ),
            child: isDone
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: isDone ? secondaryTextColor : primaryTextColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    // Mini Avatar
                    if (isBoth)
                      SizedBox(
                        width: 30,
                        height: 16,
                        child: Stack(
                          children: const [
                            Positioned(
                              left: 0,
                              child: CircleAvatar(
                                radius: 8,
                                backgroundImage: NetworkImage(
                                  'https://placeholder.com/user_avatar.jpg',
                                ),
                              ),
                            ),
                            Positioned(
                              left: 12,
                              child: CircleAvatar(
                                radius: 8,
                                backgroundImage: NetworkImage(
                                  'https://placeholder.com/partner_avatar.jpg',
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      CircleAvatar(
                        radius: 8,
                        backgroundImage: NetworkImage(
                          isFemale
                              ? 'https://placeholder.com/partner_avatar.jpg'
                              : 'https://placeholder.com/user_avatar.jpg',
                        ),
                      ),

                    const SizedBox(width: 6),
                    Text(
                      assignee,
                      style: GoogleFonts.inter(
                        color: secondaryTextColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconAction(
    IconData icon,
    String label,
    bool isActive,
    Color activeColor,
    Color inactiveColor,
  ) {
    // This is purely visual to match the 'image', but functionally inactive as we have a real nav bar
    return Column(
      children: [
        Icon(
          icon,
          color: isActive ? activeColor : inactiveColor.withOpacity(0.5),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            color: isActive ? activeColor : inactiveColor.withOpacity(0.5),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
