class Weather {
  final String cityName;
  final double temperature;
  final String description;
  final String icon;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final int pressure;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.icon,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    try {
      // Validate JSON structure
      if (json.isEmpty) {
        throw const FormatException('Empty weather data received');
      }

      // Parse city name
      final cityName = _parseString(json, 'name', 'City name');

      // Parse main weather data
      final main = _parseMap(json, 'main', 'Main weather data');

      // Parse weather array
      final weatherList = _parseList(json, 'weather', 'Weather information');
      if (weatherList.isEmpty) {
        throw const FormatException('Weather information array is empty');
      }
      final weatherData = weatherList[0] as Map<String, dynamic>;

      // Parse wind data (optional)
      final wind = json['wind'] as Map<String, dynamic>? ?? {};

      // Parse individual fields with error handling
      final temperature = _parseNumber(main, 'temp', 'Temperature');
      final feelsLike = _parseNumber(main, 'feels_like', 'Feels like temperature');
      final humidity = _parseInt(main, 'humidity', 'Humidity');
      final pressure = _parseInt(main, 'pressure', 'Pressure');
      final description = _parseString(weatherData, 'description', 'Weather description');
      final icon = _parseString(weatherData, 'icon', 'Weather icon');
      final windSpeed = wind['speed'] != null
          ? (wind['speed'] as num).toDouble()
          : 0.0;

      return Weather(
        cityName: cityName,
        temperature: temperature,
        description: description,
        icon: icon,
        feelsLike: feelsLike,
        humidity: humidity,
        windSpeed: windSpeed,
        pressure: pressure,
      );
    } on FormatException {
      rethrow;
    } on TypeError catch (e, stackTrace) {
      throw FormatException('Invalid data type in weather response: $e\nStack: $stackTrace');
    } catch (e, stackTrace) {
      throw FormatException('Failed to parse weather data: $e\nStack: $stackTrace');
    }
  }

  static String _parseString(Map<String, dynamic> json, String key, String fieldName) {
    if (!json.containsKey(key) || json[key] == null) {
      throw FormatException('Missing required field: $fieldName ($key)');
    }
    final value = json[key];
    if (value is! String) {
      throw FormatException('$fieldName must be a string, got ${value.runtimeType}');
    }
    if (value.isEmpty) {
      throw FormatException('$fieldName cannot be empty');
    }
    return value;
  }

  static double _parseNumber(Map<String, dynamic> json, String key, String fieldName) {
    if (!json.containsKey(key) || json[key] == null) {
      throw FormatException('Missing required field: $fieldName ($key)');
    }
    final value = json[key];
    if (value is! num) {
      throw FormatException('$fieldName must be a number, got ${value.runtimeType}');
    }
    return value.toDouble();
  }

  static int _parseInt(Map<String, dynamic> json, String key, String fieldName) {
    if (!json.containsKey(key) || json[key] == null) {
      throw FormatException('Missing required field: $fieldName ($key)');
    }
    final value = json[key];
    if (value is! num) {
      throw FormatException('$fieldName must be a number, got ${value.runtimeType}');
    }
    return value.toInt();
  }

  static Map<String, dynamic> _parseMap(Map<String, dynamic> json, String key, String fieldName) {
    if (!json.containsKey(key) || json[key] == null) {
      throw FormatException('Missing required field: $fieldName ($key)');
    }
    final value = json[key];
    if (value is! Map<String, dynamic>) {
      throw FormatException('$fieldName must be an object, got ${value.runtimeType}');
    }
    return value;
  }

  static List<dynamic> _parseList(Map<String, dynamic> json, String key, String fieldName) {
    if (!json.containsKey(key) || json[key] == null) {
      throw FormatException('Missing required field: $fieldName ($key)');
    }
    final value = json[key];
    if (value is! List) {
      throw FormatException('$fieldName must be an array, got ${value.runtimeType}');
    }
    return value;
  }

  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';
}
