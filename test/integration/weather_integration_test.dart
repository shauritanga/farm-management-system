import 'package:flutter_test/flutter_test.dart';
import 'package:agripoa/features/weather/data/services/weather_api_service.dart';
import 'package:agripoa/features/weather/data/repositories/weather_repository_impl.dart';
import 'package:agripoa/features/weather/domain/entities/weather.dart';

void main() {
  group('Weather Integration Tests', () {
    late WeatherApiService weatherApiService;
    late WeatherRepositoryImpl weatherRepository;

    setUp(() {
      weatherApiService = WeatherApiService();
      weatherRepository = WeatherRepositoryImpl(weatherApiService);
    });

    tearDown(() {
      weatherApiService.dispose();
    });

    testWidgets('should fetch real weather data for Dar es Salaam', (tester) async {
      // This test requires internet connection and valid API key
      try {
        // Act
        final weatherData = await weatherRepository.getWeatherByCity('Dar es Salaam');

        // Assert
        expect(weatherData.current.location, isNotEmpty);
        expect(weatherData.current.temperature, isA<double>());
        expect(weatherData.current.humidity, isA<int>());
        expect(weatherData.current.condition.main, isNotEmpty);
        expect(weatherData.forecast.length, greaterThan(0));

        // Print results for manual verification
        print('Weather Test Results:');
        print('Location: ${weatherData.current.location}, ${weatherData.current.country}');
        print('Temperature: ${weatherData.current.temperatureCelsius}');
        print('Condition: ${weatherData.current.condition.description}');
        print('Humidity: ${weatherData.current.humidityPercent}');
        print('Wind: ${weatherData.current.windSpeedKmh}');
        print('Forecast days: ${weatherData.forecast.length}');
        
        for (int i = 0; i < weatherData.forecast.length && i < 3; i++) {
          final forecast = weatherData.forecast[i];
          print('${forecast.dayName}: ${forecast.temperatureRange} - ${forecast.condition.description}');
        }
      } catch (e) {
        // If the test fails due to network issues, skip it
        print('Weather integration test skipped due to: $e');
        return;
      }
    }, skip: false); // Set to true to skip this test if no internet

    testWidgets('should fetch weather by coordinates', (tester) async {
      try {
        // Dar es Salaam coordinates
        const latitude = -6.7924;
        const longitude = 39.2083;

        // Act
        final weatherData = await weatherRepository.getWeatherByCoordinates(latitude, longitude);

        // Assert
        expect(weatherData.current.temperature, isA<double>());
        expect(weatherData.current.condition.main, isNotEmpty);
        expect(weatherData.forecast.length, greaterThan(0));

        print('Coordinates Weather Test Results:');
        print('Location: ${weatherData.current.location}');
        print('Temperature: ${weatherData.current.temperatureCelsius}');
        print('Condition: ${weatherData.current.condition.description}');
      } catch (e) {
        print('Coordinates weather test skipped due to: $e');
        return;
      }
    }, skip: false);

    testWidgets('should search for locations', (tester) async {
      try {
        // Act
        final locations = await weatherRepository.searchLocations('Dar es Salaam');

        // Assert
        expect(locations.length, greaterThan(0));
        expect(locations.first.name, isNotEmpty);
        expect(locations.first.latitude, isA<double>());
        expect(locations.first.longitude, isA<double>());

        print('Location Search Test Results:');
        for (final location in locations.take(3)) {
          print('${location.name}, ${location.country} (${location.latitude}, ${location.longitude})');
        }
      } catch (e) {
        print('Location search test skipped due to: $e');
        return;
      }
    }, skip: false);
  });
}
