import '../../domain/entities/weather.dart';
import '../../domain/repositories/weather_repository.dart';
import '../models/weather_models.dart';
import '../services/weather_api_service.dart';

/// Implementation of WeatherRepository using OpenWeatherMap API
class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherApiService _apiService;

  WeatherRepositoryImpl(this._apiService);

  @override
  Future<CurrentWeather> getCurrentWeather(WeatherLocation location) async {
    try {
      final currentWeather = await _apiService.getCurrentWeatherByCoordinates(
        location.latitude,
        location.longitude,
      );

      // Get UV index separately
      final uvIndex = await _apiService.getUvIndex(
        location.latitude,
        location.longitude,
      );

      // Create updated current weather with UV index
      return CurrentWeatherModel(
        temperature: currentWeather.temperature,
        feelsLike: currentWeather.feelsLike,
        humidity: currentWeather.humidity,
        windSpeed: currentWeather.windSpeed,
        windDirection: currentWeather.windDirection,
        pressure: currentWeather.pressure,
        visibility: currentWeather.visibility,
        uvIndex: uvIndex,
        condition: currentWeather.condition,
        timestamp: currentWeather.timestamp,
        location: currentWeather.location,
        country: currentWeather.country,
      );
    } catch (e) {
      throw Exception('Failed to get current weather: $e');
    }
  }

  @override
  Future<List<WeatherForecast>> getWeatherForecast(
    WeatherLocation location, {
    int days = 5,
  }) async {
    try {
      final forecast = await _apiService.getForecastByCoordinates(
        location.latitude,
        location.longitude,
      );

      return forecast.take(days).toList();
    } catch (e) {
      throw Exception('Failed to get weather forecast: $e');
    }
  }

  @override
  Future<WeatherData> getWeatherData(WeatherLocation location) async {
    try {
      // Get current weather and forecast concurrently
      final results = await Future.wait([
        getCurrentWeather(location),
        getWeatherForecast(location),
      ]);

      final current = results[0] as CurrentWeather;
      final forecast = results[1] as List<WeatherForecast>;

      return WeatherDataModel(
        current: current,
        forecast: forecast,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to get weather data: $e');
    }
  }

  @override
  Future<WeatherData> getWeatherByCity(String cityName) async {
    try {
      // Get current weather and forecast by city name concurrently
      final results = await Future.wait([
        _apiService.getCurrentWeatherByCity(cityName),
        _apiService.getForecastByCity(cityName),
      ]);

      final current = results[0] as CurrentWeatherModel;
      final forecast = results[1] as List<WeatherForecastModel>;

      // Get UV index (using default coordinates for now)
      final uvIndex = await _apiService.getUvIndex(
        -6.7924, // Dar es Salaam latitude
        39.2083, // Dar es Salaam longitude
      );

      // Create updated current weather with UV index
      final updatedCurrent = CurrentWeatherModel(
        temperature: current.temperature,
        feelsLike: current.feelsLike,
        humidity: current.humidity,
        windSpeed: current.windSpeed,
        windDirection: current.windDirection,
        pressure: current.pressure,
        visibility: current.visibility,
        uvIndex: uvIndex,
        condition: current.condition,
        timestamp: current.timestamp,
        location: current.location,
        country: current.country,
      );

      return WeatherDataModel(
        current: updatedCurrent,
        forecast: forecast,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to get weather by city: $e');
    }
  }

  @override
  Future<WeatherData> getWeatherByCoordinates(
    double latitude,
    double longitude,
  ) async {
    final location = WeatherLocation(latitude: latitude, longitude: longitude);
    return getWeatherData(location);
  }

  @override
  Future<List<WeatherLocation>> searchLocations(String query) async {
    try {
      final locations = await _apiService.searchLocations(query);
      return locations;
    } catch (e) {
      throw Exception('Failed to search locations: $e');
    }
  }
}
