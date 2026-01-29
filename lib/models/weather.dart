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
      if (json['name'] == null) {
        throw Exception('Missing required field: name');
      }
      if (json['main'] == null) {
        throw Exception('Missing required field: main');
      }
      if (json['weather'] == null || (json['weather'] as List).isEmpty) {
        throw Exception('Missing required field: weather');
      }

      final cityName = json['name'] as String;
      final main = json['main'];
      final weather = (json['weather'] as List)[0];
      final wind = json['wind'] ?? {};

      final temperature = (main['temp'] as num).toDouble();
      final feelsLike = (main['feels_like'] as num).toDouble();
      final humidity = main['humidity'] as int;
      final pressure = main['pressure'] as int;
      final description = weather['description'] as String;
      final icon = weather['icon'] as String;
      final windSpeed = (wind['speed'] as num?)?.toDouble() ?? 0.0;

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
    } catch (e) {
      rethrow;
    }
  }

  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';
}
