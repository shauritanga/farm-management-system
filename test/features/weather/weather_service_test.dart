import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:agripoa/features/weather/data/services/weather_api_service.dart';
import 'package:agripoa/features/weather/data/repositories/weather_repository_impl.dart';

// Generate mocks
@GenerateMocks([http.Client])
import 'weather_service_test.mocks.dart';

void main() {
  group('Weather Service Tests', () {
    late WeatherApiService weatherApiService;
    late WeatherRepositoryImpl weatherRepository;
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
      weatherApiService = WeatherApiService(client: mockClient);
      weatherRepository = WeatherRepositoryImpl(weatherApiService);
    });

    tearDown(() {
      weatherApiService.dispose();
    });

    test('should fetch current weather successfully', () async {
      // Arrange
      const mockResponse = '''
      {
        "coord": {"lon": 39.2083, "lat": -6.7924},
        "weather": [
          {
            "id": 801,
            "main": "Clouds",
            "description": "few clouds",
            "icon": "02d"
          }
        ],
        "base": "stations",
        "main": {
          "temp": 28.5,
          "feels_like": 32.1,
          "temp_min": 28.5,
          "temp_max": 28.5,
          "pressure": 1013,
          "humidity": 65
        },
        "visibility": 10000,
        "wind": {
          "speed": 3.6,
          "deg": 120
        },
        "clouds": {
          "all": 20
        },
        "dt": 1640995200,
        "sys": {
          "type": 1,
          "id": 2006,
          "country": "TZ",
          "sunrise": 1640995200,
          "sunset": 1641038400
        },
        "timezone": 10800,
        "id": 160263,
        "name": "Dar es Salaam",
        "cod": 200
      }
      ''';

      when(mockClient.get(any)).thenAnswer(
        (_) async => http.Response(mockResponse, 200),
      );

      // Act
      final result = await weatherApiService.getCurrentWeatherByCity('Dar es Salaam');

      // Assert
      expect(result.location, 'Dar es Salaam');
      expect(result.country, 'TZ');
      expect(result.temperature, 28.5);
      expect(result.humidity, 65);
      expect(result.condition.main, 'Clouds');
      expect(result.condition.description, 'few clouds');
    });

    test('should handle API errors gracefully', () async {
      // Arrange
      when(mockClient.get(any)).thenAnswer(
        (_) async => http.Response('Not Found', 404),
      );

      // Act & Assert
      expect(
        () => weatherApiService.getCurrentWeatherByCity('InvalidCity'),
        throwsA(isA<WeatherApiException>()),
      );
    });

    test('should fetch weather forecast successfully', () async {
      // Arrange
      const mockResponse = '''
      {
        "cod": "200",
        "message": 0,
        "cnt": 40,
        "list": [
          {
            "dt": 1640995200,
            "main": {
              "temp": 28.5,
              "feels_like": 32.1,
              "temp_min": 26.0,
              "temp_max": 30.0,
              "pressure": 1013,
              "humidity": 65
            },
            "weather": [
              {
                "id": 801,
                "main": "Clouds",
                "description": "few clouds",
                "icon": "02d"
              }
            ],
            "wind": {
              "speed": 3.6,
              "deg": 120
            },
            "pop": 0.2
          }
        ]
      }
      ''';

      when(mockClient.get(any)).thenAnswer(
        (_) async => http.Response(mockResponse, 200),
      );

      // Act
      final result = await weatherApiService.getForecastByCity('Dar es Salaam');

      // Assert
      expect(result.isNotEmpty, true);
      expect(result.first.maxTemperature, 30.0);
      expect(result.first.minTemperature, 26.0);
      expect(result.first.condition.main, 'Clouds');
      expect(result.first.precipitationProbability, 0.2);
    });
  });
}
