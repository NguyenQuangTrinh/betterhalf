import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SuggestedPlacesSection extends StatelessWidget {
  final bool isDark;
  final Color cardColor;
  final Color primaryTextColor;
  final Color secondaryTextColor;

  const SuggestedPlacesSection({
    super.key,
    required this.isDark,
    required this.cardColor,
    required this.primaryTextColor,
    required this.secondaryTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Địa điểm gợi ý',
              style: GoogleFonts.inter(
                color: primaryTextColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2C3545) : Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.filter_list,
                    size: 16,
                    color: secondaryTextColor,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2C3545) : Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.map_outlined,
                    size: 16,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        _SuggestedPlaceCard(
          title: 'Tranquil Books & Coffee',
          subtitle: '2.5km • Quán cà phê • Yên tĩnh',
          imageUrl:
              'https://placeholder.com/cafe.jpg', // Replace with real image or asset
          rating: 4.8,
          cardColor: cardColor,
          primaryColor: primaryTextColor,
          secondaryColor: secondaryTextColor,
        ),
        const SizedBox(height: 16),
        _SuggestedPlaceCard(
          title: 'Hồ Tây - Góc Phủ Tây Hồ',
          subtitle: '5.0km • Ngoài trời • Lãng mạn',
          imageUrl:
              'https://placeholder.com/lake.jpg', // Replace with real image or asset
          rating: 4.9,
          cardColor: cardColor,
          primaryColor: primaryTextColor,
          secondaryColor: secondaryTextColor,
        ),
      ],
    );
  }
}

class _SuggestedPlaceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final double rating;
  final Color cardColor;
  final Color primaryColor;
  final Color secondaryColor;

  const _SuggestedPlaceCard({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.rating,
    required this.cardColor,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Image Section
          Container(
            height: 150,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          '$rating',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_border,
                      size: 16,
                      color: Color(0xFF546E7A),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Info Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: const Color(0xFF4B89EA),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        color: secondaryColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Thêm vào kế hoạch',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF546E7A),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
