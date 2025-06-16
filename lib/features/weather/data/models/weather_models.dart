import '../../domain/entities/weather.dart';

/// Weather condition model for API responses
class WeatherConditionModel extends WeatherCondition {
  const WeatherConditionModel({
    required super.main,
    required super.description,
    required super.icon,
  });

  factory WeatherConditionModel.fromJson(Map<String, dynamic> json) {
    return WeatherConditionModel(
      main: json['main'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'main': main,
      'description': description,
      'icon': icon,
    };
  }
}

/// Current weather model for API responses
class CurrentWeatherModel extends CurrentWeather {
  const CurrentWeatherModel({
    required super.temperature,
    required super.feelsLike,
    required super.humidity,
    required super.windSpeed,
    required super.windDirection,
    required super.pressure,
    required super.visibility,
    required super.uvIndex,
    required super.condition,
    required super.timestamp,
    required super.location,
    required super.country,
  });

  factory CurrentWeatherModel.fromJson(Map<String, dynamic> json) {
    final main = json['main'] as Map<String, dynamic>;
    final weather = (json['weather'] as List<dynamic>).first as Map<String, dynamic>;
    final wind = json['wind'] as Map<String, dynamic>? ?? {};
    final sys = json['sys'] as Map<String, dynamic>? ?? {};

    return CurrentWeatherModel(
      temperature: (main['temp'] as num).toDouble(),
      feelsLike: (main['feels_like'] as num).toDouble(),
      humidity: main['humidity'] as int,
      windSpeed: (wind['speed'] as num?)?.toDouble() ?? 0.0,
      windDirection: (wind['deg'] as num?)?.toInt() ?? 0,
      pressure: main['pressure'] as int,
      visibility: (json['visibility'] as num?)?.toInt() ?? 10000,
      uvIndex: 0.0, // Will be fetched separately
      condition: WeatherConditionModel.fromJson(weather),
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (json['dt'] as int) * 1000,
      ),
      location: json['name'] as String,
      country: sys['country'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'main': {
        'temp': temperature,
        'feels_like': feelsLike,
        'humidity': humidity,
        'pressure': pressure,
      },
      'weather': [
        {
          'main': condition.main,
          'description': condition.description,
          'icon': condition.icon,
        },
      ],
      'wind': {
        'speed': windSpeed,
        'deg': windDirection,
      },
      'visibility': visibility,
      'dt': timestamp.millisecondsSinceEpoch ~/ 1000,
      'name': location,
      'sys': {
        'country': country,
      },
    };
  }
}

/// Weather forecast model for API responses
class WeatherForecastModel extends WeatherForecast {
  const WeatherForecastModel({
    required super.date,
    required super.maxTemperature,
    required super.minTemperature,
    required super.condition,
    required super.humidity,
    required super.windSpeed,
    required super.precipitationProbability,
  });

  factory WeatherForecastModel.fromJson(Map<String, dynamic> json) {
    final main = json['main'] as Map<String, dynamic>;
    final weather = (json['weather'] as List<dynamic>).first as Map<String, dynamic>;
    final wind = json['wind'] as Map<String, dynamic>? ?? {};

    return WeatherForecastModel(
      date: DateTime.fromMillisecondsSinceEpoch(
        (json['dt'] as int) * 1000,
      ),
      maxTemperature: (main['temp_max'] as num).toDouble(),
      minTemperature: (main['temp_min'] as num).toDouble(),
      condition: WeatherConditionModel.fromJson(weather),
      humidity: main['humidity'] as int,
      windSpeed: (wind['speed'] as num?)?.toDouble() ?? 0.0,
      precipitationProbability: (json['pop'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dt': date.millisecondsSinceEpoch ~/ 1000,
      'main': {
        'temp_max': maxTemperature,
        'temp_min': minTemperature,
        'humidity': humidity,
      },
      'weather': [
        {
          'main': condition.main,
          'description': condition.description,
          'icon': condition.icon,
        },
      ],
      'wind': {
        'speed': windSpeed,
      },
      'pop': precipitationProbability,
    };
  }
}

/// Location model for API responses
class LocationModel extends WeatherLocation {
  const LocationModel({
    required super.latitude,
    required super.longitude,
    super.name,
    super.country,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: (json['lat'] as num).toDouble(),
      longitude: (json['lon'] as num).toDouble(),
      name: json['name'] as String?,
      country: json['country'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': latitude,
      'lon': longitude,
      'name': name,
      'country': country,
    };
  }
}

/// Weather data model for API responses
class WeatherDataModel extends WeatherData {
  const WeatherDataModel({
    required super.current,
    required super.forecast,
    required super.lastUpdated,
  });

  factory WeatherDataModel.fromCurrentAndForecast(
    CurrentWeatherModel current,
    List<WeatherForecastModel> forecast,
  ) {
    return WeatherDataModel(
      current: current,
      forecast: forecast,
      lastUpdated: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current': (current as CurrentWeatherModel).toJson(),
      'forecast': forecast
          .map((f) => (f as WeatherForecastModel).toJson())
          .toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory WeatherDataModel.fromJson(Map<String, dynamic> json) {
    final currentJson = json['current'] as Map<String, dynamic>;
    final forecastJson = json['forecast'] as List<dynamic>;

    return WeatherDataModel(
      current: CurrentWeatherModel.fromJson(currentJson),
      forecast: forecastJson
          .map((f) => WeatherForecastModel.fromJson(f as Map<String, dynamic>))
          .toList(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }
}
