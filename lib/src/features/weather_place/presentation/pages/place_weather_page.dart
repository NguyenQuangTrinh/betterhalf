import 'package:betterhalf/src/core/models/weather_model.dart';
import 'package:betterhalf/src/core/services/weather_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../widgets/place_weather_tab_bar.dart';
import '../widgets/weather_plan_tab.dart';
import '../widgets/weather_memories_tab.dart';
import '../widgets/quick_add_menu.dart';
import '../widgets/add_memory_modal.dart';

class PlaceWeatherPage extends StatefulWidget {
  final VoidCallback? onBack;

  const PlaceWeatherPage({super.key, this.onBack});

  @override
  State<PlaceWeatherPage> createState() => _PlaceWeatherPageState();
}

class _PlaceWeatherPageState extends State<PlaceWeatherPage> {
  int _tabIndex = 0; // 0: Plan, 1: Memories

  // Weather State
  WeatherModel? _weather;
  String _locationName = 'Đang tải...';
  bool _isLoading = true;
  String? _error;

  final WeatherService _weatherService = WeatherService();

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  Future<void> _fetchWeatherData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // 1. Get Location
      final position = await _weatherService.getCurrentLocation();

      // 2. Get Location Name
      _locationName = await _weatherService.getLocationName(
        position.latitude,
        position.longitude,
      );

      // 3. Get Weather
      final weather = await _weatherService.getWeather(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _weather = weather;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = "Không thể lấy dữ liệu: $e";
        _isLoading = false;
        _locationName = "Không xác định";
      });
      // Fallback or print error
      print("Weather fetch error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? const Color(0xFF161B22)
        : const Color(0xFFF3F5FA);
    final cardColor = isDark ? const Color(0xFF1E2432) : Colors.white;
    final primaryTextColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark ? Colors.white60 : Colors.black54;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryTextColor),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        centerTitle: true,
        title: Text(
          'Địa điểm & Thời tiết',
          style: GoogleFonts.inter(
            color: primaryTextColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(
              FontAwesomeIcons.mapLocationDot,
              color: const Color(0xFF4B89EA),
              size: 20,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(_error!, textAlign: TextAlign.center),
                  TextButton(
                    onPressed: _fetchWeatherData,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Toggle Buttons ---
                  PlaceWeatherTabBar(
                    selectedIndex: _tabIndex,
                    onTabSelected: (index) => setState(() => _tabIndex = index),
                    isDark: isDark,
                    secondaryTextColor: secondaryTextColor,
                  ),
                  const SizedBox(height: 24),

                  // Content Switcher
                  if (_tabIndex == 0)
                    WeatherPlanTab(
                      isDark: isDark,
                      cardColor: cardColor,
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                      weather: _weather, // Pass data
                      locationName: _locationName,
                    )
                  else
                    WeatherMemoriesTab(
                      isDark: isDark,
                      cardColor: cardColor,
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                    ),

                  const SizedBox(height: 100), // Bottom padding
                ],
              ),
            ),
      floatingActionButton: _tabIndex == 1
          ? Container(
              height: 60,
              width: 60,
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
                onPressed: () => _showAddMemoryModal(context),
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            )
          : Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x404B89EA),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: () => _showQuickAddMenu(context),
                backgroundColor: const Color(0xFF90B6F4),
                elevation: 0,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
    );
  }

  void _showQuickAddMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return const QuickAddMenu();
      },
    );
  }

  void _showAddMemoryModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const AddMemoryModal();
      },
    );
  }
}
