/// Weather condition entity
class WeatherCondition {
  final String main;
  final String description;
  final String icon;

  const WeatherCondition({
    required this.main,
    required this.description,
    required this.icon,
  });

  /// Get weather icon URL from OpenWeatherMap
  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';

  /// Get appropriate Flutter icon based on weather condition
  String get flutterIcon {
    switch (main.toLowerCase()) {
      case 'clear':
        return 'sunny';
      case 'clouds':
        return 'cloudy';
      case 'rain':
        return 'rainy';
      case 'drizzle':
        return 'drizzle';
      case 'thunderstorm':
        return 'thunderstorm';
      case 'snow':
        return 'snowy';
      case 'mist':
      case 'fog':
        return 'foggy';
      default:
        return 'partly_cloudy';
    }
  }
}

/// Current weather entity
class CurrentWeather {
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final int windDirection;
  final int pressure;
  final int visibility;
  final double uvIndex;
  final WeatherCondition condition;
  final DateTime timestamp;
  final String location;
  final String country;

  const CurrentWeather({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.pressure,
    required this.visibility,
    required this.uvIndex,
    required this.condition,
    required this.timestamp,
    required this.location,
    required this.country,
  });

  /// Get temperature in Celsius
  String get temperatureCelsius => '${temperature.round()}°C';

  /// Get feels like temperature in Celsius
  String get feelsLikeCelsius => '${feelsLike.round()}°C';

  /// Get wind speed in km/h
  String get windSpeedKmh => '${(windSpeed * 3.6).round()} km/h';

  /// Get humidity percentage
  String get humidityPercent => '$humidity%';

  /// Get pressure in hPa
  String get pressureHpa => '$pressure hPa';

  /// Get visibility in km
  String get visibilityKm => '${(visibility / 1000).round()} km';

  /// Get UV index description
  String get uvIndexDescription {
    if (uvIndex <= 2) return 'Low';
    if (uvIndex <= 5) return 'Moderate';
    if (uvIndex <= 7) return 'High';
    if (uvIndex <= 10) return 'Very High';
    return 'Extreme';
  }

  /// Get wind direction description
  String get windDirectionDescription {
    if (windDirection >= 337.5 || windDirection < 22.5) return 'N';
    if (windDirection < 67.5) return 'NE';
    if (windDirection < 112.5) return 'E';
    if (windDirection < 157.5) return 'SE';
    if (windDirection < 202.5) return 'S';
    if (windDirection < 247.5) return 'SW';
    if (windDirection < 292.5) return 'W';
    if (windDirection < 337.5) return 'NW';
    return 'N';
  }
}

/// Weather forecast for a single day
class WeatherForecast {
  final DateTime date;
  final double maxTemperature;
  final double minTemperature;
  final WeatherCondition condition;
  final int humidity;
  final double windSpeed;
  final double precipitationProbability;

  const WeatherForecast({
    required this.date,
    required this.maxTemperature,
    required this.minTemperature,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
    required this.precipitationProbability,
  });

  /// Get temperature range string
  String get temperatureRange => 
      '${maxTemperature.round()}°/${minTemperature.round()}°';

  /// Get day name
  String get dayName {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final forecastDate = DateTime(date.year, date.month, date.day);
    
    final difference = forecastDate.difference(today).inDays;
    
    switch (difference) {
      case 0:
        return 'Today';
      case 1:
        return 'Tomorrow';
      default:
        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return days[date.weekday - 1];
    }
  }

  /// Get precipitation probability percentage
  String get precipitationPercent => '${(precipitationProbability * 100).round()}%';
}

/// Complete weather data including current and forecast
class WeatherData {
  final CurrentWeather current;
  final List<WeatherForecast> forecast;
  final DateTime lastUpdated;

  const WeatherData({
    required this.current,
    required this.forecast,
    required this.lastUpdated,
  });

  /// Check if data is stale (older than 30 minutes)
  bool get isStale {
    final now = DateTime.now();
    return now.difference(lastUpdated).inMinutes > 30;
  }

  /// Get forecast for next 5 days
  List<WeatherForecast> get fiveDayForecast => 
      forecast.take(5).toList();
}

/// Location coordinates for weather requests
class WeatherLocation {
  final double latitude;
  final double longitude;
  final String? name;
  final String? country;

  const WeatherLocation({
    required this.latitude,
    required this.longitude,
    this.name,
    this.country,
  });

  @override
  String toString() {
    if (name != null && country != null) {
      return '$name, $country';
    } else if (name != null) {
      return name!;
    } else {
      return '${latitude.toStringAsFixed(2)}, ${longitude.toStringAsFixed(2)}';
    }
  }
}
