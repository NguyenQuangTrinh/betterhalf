class WeatherModel {
  final double temp;
  final String mainCondition; // e.g., Rain, Clear, Clouds
  final String description;
  final String iconCode;

  WeatherModel({
    required this.temp,
    required this.mainCondition,
    required this.description,
    required this.iconCode,
  });

  factory WeatherModel.fromOpenMeteo(Map<String, dynamic> json) {
    final current = json['current'];
    final weatherCode = current['weather_code'] as int;

    return WeatherModel(
      temp: (current['temperature_2m'] as num).toDouble(),
      mainCondition: _mapWmoCodeToCondition(weatherCode),
      description: _mapWmoCodeToDescription(weatherCode),
      iconCode: _mapWmoCodeToIcon(weatherCode),
    );
  }

  // WMO Weather Codes interpretation
  static String _mapWmoCodeToCondition(int code) {
    if (code == 0) return 'Clear';
    if (code == 1 || code == 2 || code == 3) return 'Cloudy';
    if (code == 45 || code == 48) return 'Fog';
    if (code >= 51 && code <= 67) return 'Rain';
    if (code >= 71 && code <= 77) return 'Snow';
    if (code >= 80 && code <= 82) return 'Rain';
    if (code >= 85 && code <= 86) return 'Snow';
    if (code >= 95 && code <= 99) return 'Thunderstorm';
    return 'Unknown';
  }

  static String _mapWmoCodeToDescription(int code) {
    switch (code) {
      case 0:
        return 'Trời quang đãng';
      case 1:
        return 'Chủ yếu là nắng';
      case 2:
        return 'Có mây rải rác';
      case 3:
        return 'Trời nhiều mây';
      case 45:
        return 'Sương mù';
      case 48:
        return 'Sương mù rime';
      case 51:
        return 'Mưa phùn nhẹ';
      case 53:
        return 'Mưa phùn vừa';
      case 55:
        return 'Mưa phùn dày đặc';
      case 61:
        return 'Mưa nhẹ';
      case 63:
        return 'Mưa vừa';
      case 65:
        return 'Mưa lớn';
      case 80:
        return 'Mưa rào nhẹ';
      case 81:
        return 'Mưa rào vừa';
      case 82:
        return 'Mưa rào dữ dội';
      case 95:
        return 'Dông';
      default:
        return 'Thời tiết thay đổi';
    }
  }

  static String _mapWmoCodeToIcon(int code) {
    // Return codes compatible with your existing icon logic or font_awesome
    // For now, returning simple string keys
    if (code == 0) return '01d'; // Clear
    if (code == 1 || code == 2) return '02d'; // Few clouds
    if (code == 3) return '03d'; // Clouds
    if (code >= 51) return '09d'; // Rain
    return '01d';
  }

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final weather = json['weather'][0];
    final main = json['main'];
    return WeatherModel(
      temp: (main['temp'] as num).toDouble(),
      mainCondition: weather['main'] as String,
      description: weather['description'] as String,
      iconCode: weather['icon'] as String,
    );
  }
}
