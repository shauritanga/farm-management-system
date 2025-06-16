import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_models.dart';

/// OpenWeatherMap API service
class WeatherApiService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String _geoUrl = 'https://api.openweathermap.org/geo/1.0';
  static const String _apiKey = 'e4fcd40550f556863daee85d5a764042';

  final http.Client _client;

  WeatherApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Get current weather by coordinates
  Future<CurrentWeatherModel> getCurrentWeatherByCoordinates(
    double latitude,
    double longitude,
  ) async {
    final url = Uri.parse(
      '$_baseUrl/weather?lat=$latitude&lon=$longitude&appid=$_apiKey&units=metric',
    );

    try {
      final response = await _client.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return CurrentWeatherModel.fromJson(data);
      } else {
        throw WeatherApiException(
          'Failed to get current weather: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is WeatherApiException) rethrow;
      throw WeatherApiException('Network error: $e');
    }
  }

  /// Get current weather by city name
  Future<CurrentWeatherModel> getCurrentWeatherByCity(String cityName) async {
    final url = Uri.parse(
      '$_baseUrl/weather?q=$cityName&appid=$_apiKey&units=metric',
    );

    try {
      final response = await _client.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return CurrentWeatherModel.fromJson(data);
      } else if (response.statusCode == 404) {
        throw WeatherApiException('City not found: $cityName');
      } else {
        throw WeatherApiException(
          'Failed to get current weather: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is WeatherApiException) rethrow;
      throw WeatherApiException('Network error: $e');
    }
  }

  /// Get 5-day weather forecast by coordinates
  Future<List<WeatherForecastModel>> getForecastByCoordinates(
    double latitude,
    double longitude,
  ) async {
    final url = Uri.parse(
      '$_baseUrl/forecast?lat=$latitude&lon=$longitude&appid=$_apiKey&units=metric',
    );

    try {
      final response = await _client.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final list = data['list'] as List<dynamic>;
        
        // Group forecasts by day and take the midday forecast for each day
        final dailyForecasts = <String, WeatherForecastModel>{};
        
        for (final item in list) {
          final forecast = WeatherForecastModel.fromJson(item);
          final dateKey = forecast.date.toIso8601String().substring(0, 10);
          
          // Take the forecast closest to midday (12:00)
          if (!dailyForecasts.containsKey(dateKey) ||
              (forecast.date.hour - 12).abs() < 
              (dailyForecasts[dateKey]!.date.hour - 12).abs()) {
            dailyForecasts[dateKey] = forecast;
          }
        }
        
        return dailyForecasts.values.toList()..sort((a, b) => a.date.compareTo(b.date));
      } else {
        throw WeatherApiException(
          'Failed to get weather forecast: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is WeatherApiException) rethrow;
      throw WeatherApiException('Network error: $e');
    }
  }

  /// Get 5-day weather forecast by city name
  Future<List<WeatherForecastModel>> getForecastByCity(String cityName) async {
    final url = Uri.parse(
      '$_baseUrl/forecast?q=$cityName&appid=$_apiKey&units=metric',
    );

    try {
      final response = await _client.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final list = data['list'] as List<dynamic>;
        
        // Group forecasts by day and take the midday forecast for each day
        final dailyForecasts = <String, WeatherForecastModel>{};
        
        for (final item in list) {
          final forecast = WeatherForecastModel.fromJson(item);
          final dateKey = forecast.date.toIso8601String().substring(0, 10);
          
          // Take the forecast closest to midday (12:00)
          if (!dailyForecasts.containsKey(dateKey) ||
              (forecast.date.hour - 12).abs() < 
              (dailyForecasts[dateKey]!.date.hour - 12).abs()) {
            dailyForecasts[dateKey] = forecast;
          }
        }
        
        return dailyForecasts.values.toList()..sort((a, b) => a.date.compareTo(b.date));
      } else if (response.statusCode == 404) {
        throw WeatherApiException('City not found: $cityName');
      } else {
        throw WeatherApiException(
          'Failed to get weather forecast: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is WeatherApiException) rethrow;
      throw WeatherApiException('Network error: $e');
    }
  }

  /// Search for locations by name
  Future<List<LocationModel>> searchLocations(String query) async {
    final url = Uri.parse(
      '$_geoUrl/direct?q=$query&limit=5&appid=$_apiKey',
    );

    try {
      final response = await _client.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        return data.map((item) => LocationModel.fromJson(item)).toList();
      } else {
        throw WeatherApiException(
          'Failed to search locations: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is WeatherApiException) rethrow;
      throw WeatherApiException('Network error: $e');
    }
  }

  /// Get UV index by coordinates
  Future<double> getUvIndex(double latitude, double longitude) async {
    // Note: UV Index API requires a separate subscription in OpenWeatherMap
    // For now, we'll return a mock value based on time of day
    final hour = DateTime.now().hour;
    if (hour < 6 || hour > 18) return 0.0;
    if (hour < 10 || hour > 16) return 3.0;
    return 7.0; // Peak UV hours
  }

  void dispose() {
    _client.close();
  }
}

/// Custom exception for weather API errors
class WeatherApiException implements Exception {
  final String message;
  
  const WeatherApiException(this.message);
  
  @override
  String toString() => 'WeatherApiException: $message';
}
