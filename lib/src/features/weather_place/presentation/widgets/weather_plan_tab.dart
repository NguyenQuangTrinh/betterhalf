import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

import 'weather_info_card.dart';
import 'outfit_suggestions.dart';
import 'weekly_forecast.dart';
import 'suggested_places_section.dart';
import 'package:betterhalf/src/core/models/weather_model.dart';

class WeatherPlanTab extends StatelessWidget {
  final bool isDark;
  final Color cardColor;
  final Color primaryTextColor;
  final Color secondaryTextColor;

  final WeatherModel? weather;
  final String? locationName;

  const WeatherPlanTab({
    super.key,
    required this.isDark,
    required this.cardColor,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    this.weather,
    this.locationName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Weather Card ---
        WeatherInfoCard(
          temperature: weather?.temp,
          condition: weather?.mainCondition ?? 'Unknown',
          description: weather?.description ?? 'Đang cập nhật...',
          humidity: 60, // Placeholder or add to model
          locationName: locationName ?? 'Unknown Location',
        ),
        const SizedBox(height: 24),

        // --- Outfit Suggestions ---
        OutfitSuggestions(isDark: isDark, primaryTextColor: primaryTextColor),
        const SizedBox(height: 24),

        // --- Weekly Forecast ---
        WeeklyForecast(isDark: isDark),
        const SizedBox(height: 24),

        // --- Suggested Places ---
        SuggestedPlacesSection(
          isDark: isDark,
          cardColor: cardColor,
          primaryTextColor: primaryTextColor,
          secondaryTextColor: secondaryTextColor,
        ),
      ],
    );
  }
}
