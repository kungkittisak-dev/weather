import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import '../models/weather.dart';

class WeatherApi {
  // Using OpenWeatherMap free API
  // Get your free API key at: https://openweathermap.org/api
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String apiKey = 'bd5e378503939ddaee76f12ad7a97608';
  static const Duration timeout = Duration(seconds: 30);

  static http.Client _createHttpClient() {
    final ioClient = HttpClient();
    ioClient.badCertificateCallback =
        (X509Certificate cert, String host, int port) {
      return true;
    };
    return IOClient(ioClient);
  }

  static final http.Client _httpClient = _createHttpClient();

  static Future<Weather> fetchWeatherByCity(String cityName) async {
    final url = '$baseUrl/weather?q=$cityName&appid=$apiKey&units=metric';

    try {
      final response = await _httpClient.get(Uri.parse(url)).timeout(timeout);

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          final weather = Weather.fromJson(data);
          return weather;
        } on FormatException catch (e) {
          throw Exception('Failed to parse weather data: $e');
        } catch (e) {
          rethrow;
        }
      } else if (response.statusCode == 404) {
        throw Exception('City not found. Please check the city name.');
      } else if (response.statusCode == 401) {
        throw Exception(
            'Invalid API key. Please check your OpenWeatherMap API key.');
      } else {
        throw Exception(
            'Failed to load weather data. Status: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      throw Exception('No internet connection. Please check your network.');
    } on TimeoutException catch (e) {
      throw Exception('Request timeout. Please try again.');
    } on HttpException catch (e) {
      throw Exception('HTTP error occurred: $e');
    } on HandshakeException catch (e) {
      throw Exception(
          'SSL Certificate error. Try restarting the app or simulator.');
    } on TlsException catch (e) {
      throw Exception('SSL/TLS error. Please check your network connection.');
    } catch (e) {
      if (e.toString().contains('CERTIFICATE_VERIFY_FAILED')) {
        throw Exception(
            'SSL Certificate error. Try restarting the app or simulator.');
      }
      rethrow;
    }
  }
}
