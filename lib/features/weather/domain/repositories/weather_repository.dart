import '../entities/weather.dart';

/// Repository interface for weather data
abstract class WeatherRepository {
  /// Get current weather for a location
  Future<CurrentWeather> getCurrentWeather(WeatherLocation location);

  /// Get weather forecast for a location
  Future<List<WeatherForecast>> getWeatherForecast(
    WeatherLocation location, {
    int days = 5,
  });

  /// Get complete weather data (current + forecast)
  Future<WeatherData> getWeatherData(WeatherLocation location);

  /// Get weather by city name
  Future<WeatherData> getWeatherByCity(String cityName);

  /// Get weather by coordinates
  Future<WeatherData> getWeatherByCoordinates(
    double latitude,
    double longitude,
  );

  /// Search for locations by name
  Future<List<WeatherLocation>> searchLocations(String query);
}
