import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../domain/entities/weather.dart';
import '../../domain/repositories/weather_repository.dart';
import '../../data/repositories/weather_repository_impl.dart';
import '../../data/services/weather_api_service.dart';
import '../../../../core/services/location_service.dart';

/// Provider for weather API service
final weatherApiServiceProvider = Provider<WeatherApiService>((ref) {
  return WeatherApiService(client: http.Client());
});

/// Provider for weather repository
final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  final apiService = ref.read(weatherApiServiceProvider);
  return WeatherRepositoryImpl(apiService);
});

/// Weather state
sealed class WeatherState {}

class WeatherInitial extends WeatherState {}

class WeatherLoading extends WeatherState {}

class WeatherLoaded extends WeatherState {
  final WeatherData data;

  WeatherLoaded(this.data);
}

class WeatherError extends WeatherState {
  final String message;

  WeatherError(this.message);
}

/// Weather notifier
class WeatherNotifier extends StateNotifier<WeatherState> {
  final WeatherRepository _repository;

  WeatherNotifier(this._repository) : super(WeatherInitial());

  /// Get weather by city name
  Future<void> getWeatherByCity(String cityName) async {
    state = WeatherLoading();

    try {
      final weatherData = await _repository.getWeatherByCity(cityName);
      state = WeatherLoaded(weatherData);
    } catch (e) {
      state = WeatherError(e.toString());
    }
  }

  /// Get weather by coordinates
  Future<void> getWeatherByCoordinates(
    double latitude,
    double longitude,
  ) async {
    state = WeatherLoading();

    try {
      final weatherData = await _repository.getWeatherByCoordinates(
        latitude,
        longitude,
      );
      state = WeatherLoaded(weatherData);
    } catch (e) {
      state = WeatherError(e.toString());
    }
  }

  /// Refresh current weather data
  Future<void> refreshWeather() async {
    final currentState = state;
    if (currentState is WeatherLoaded) {
      // Get the location from current data and refresh
      final location = WeatherLocation(
        latitude: 0.0, // Would need to store this in the state
        longitude: 0.0,
        name: currentState.data.current.location,
        country: currentState.data.current.country,
      );

      try {
        final weatherData = await _repository.getWeatherData(location);
        state = WeatherLoaded(weatherData);
      } catch (e) {
        state = WeatherError(e.toString());
      }
    }
  }

  /// Clear weather data
  void clearWeather() {
    state = WeatherInitial();
  }
}

/// Provider for weather notifier
final weatherProvider = StateNotifierProvider<WeatherNotifier, WeatherState>((
  ref,
) {
  final repository = ref.read(weatherRepositoryProvider);
  return WeatherNotifier(repository);
});

/// Provider for default location weather (Dar es Salaam)
final defaultLocationWeatherProvider = FutureProvider<WeatherData>((ref) async {
  final repository = ref.read(weatherRepositoryProvider);

  try {
    // Default to Dar es Salaam, Tanzania
    return await repository.getWeatherByCity('Dar es Salaam');
  } catch (e) {
    // Fallback to coordinates if city search fails
    return await repository.getWeatherByCoordinates(-6.7924, 39.2083);
  }
});

/// Provider for location search
final locationSearchProvider =
    FutureProvider.family<List<WeatherLocation>, String>((ref, query) async {
      if (query.isEmpty) return [];

      final repository = ref.read(weatherRepositoryProvider);
      return await repository.searchLocations(query);
    });

/// Provider for weather by specific city
final weatherByCityProvider = FutureProvider.family<WeatherData, String>((
  ref,
  cityName,
) async {
  final repository = ref.read(weatherRepositoryProvider);
  return await repository.getWeatherByCity(cityName);
});

/// Provider for weather by coordinates
final weatherByCoordinatesProvider =
    FutureProvider.family<WeatherData, ({double lat, double lon})>((
      ref,
      coords,
    ) async {
      final repository = ref.read(weatherRepositoryProvider);
      return await repository.getWeatherByCoordinates(coords.lat, coords.lon);
    });

/// Provider for GPS-based weather (uses device location)
final gpsWeatherProvider = FutureProvider<WeatherData>((ref) async {
  final repository = ref.read(weatherRepositoryProvider);

  try {
    // Try to get current GPS location
    final position = await LocationService.getCurrentPositionSafe(
      timeout: const Duration(seconds: 10),
    );

    if (position != null) {
      // Use GPS coordinates for weather
      return await repository.getWeatherByCoordinates(
        position.latitude,
        position.longitude,
      );
    }
  } catch (e) {
    // GPS failed, continue to fallback
  }

  // Fallback to default location (Dar es Salaam)
  try {
    return await repository.getWeatherByCity('Dar es Salaam');
  } catch (e) {
    // Final fallback to coordinates
    return await repository.getWeatherByCoordinates(-6.7924, 39.2083);
  }
});
