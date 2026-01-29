import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import '../models/weather.dart';

class WeatherApiException implements Exception {
  final String message;
  final String? details;
  final int? statusCode;

  WeatherApiException(this.message, {this.details, this.statusCode});

  @override
  String toString() => message;
}

class WeatherApi {
  // Using OpenWeatherMap free API
  // Get your free API key at: https://openweathermap.org/api
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String apiKey = 'bd5e378503939ddaee76f12ad7a97608';
  static const Duration timeout = Duration(seconds: 30);

  static http.Client _createHttpClient() {
    try {
      final ioClient = HttpClient();
      ioClient.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        return true;
      };
      return IOClient(ioClient);
    } catch (e) {
      throw WeatherApiException(
        'Failed to create HTTP client',
        details: e.toString(),
      );
    }
  }

  static final http.Client _httpClient = _createHttpClient();

  static Future<Weather> fetchWeatherByCity(String cityName) async {
    // Validate input
    if (cityName.trim().isEmpty) {
      throw WeatherApiException('City name cannot be empty');
    }

    final sanitizedCityName = cityName.trim();
    final url = '$baseUrl/weather?q=$sanitizedCityName&appid=$apiKey&units=metric';

    try {
      // Make HTTP request
      final response = await _httpClient.get(Uri.parse(url)).timeout(
        timeout,
        onTimeout: () {
          throw TimeoutException(
            'The request took too long to complete',
            timeout,
          );
        },
      );

      // Handle different HTTP status codes
      return _handleResponse(response, sanitizedCityName);
    } on SocketException catch (e) {
      throw WeatherApiException(
        'No internet connection',
        details: 'Please check your network connection and try again.\nError: ${e.message}',
      );
    } on TimeoutException catch (e) {
      throw WeatherApiException(
        'Request timeout',
        details: 'The server took too long to respond. Please try again.\nTimeout: ${e.duration?.inSeconds}s',
      );
    } on HttpException catch (e) {
      throw WeatherApiException(
        'Network error',
        details: 'An HTTP error occurred: ${e.message}',
      );
    } on HandshakeException catch (e) {
      throw WeatherApiException(
        'SSL Certificate error',
        details: 'Try restarting the app or simulator.\nError: ${e.message}',
      );
    } on TlsException catch (e) {
      throw WeatherApiException(
        'SSL/TLS error',
        details: 'Please check your network connection.\nError: ${e.message}',
      );
    } on FormatException catch (e) {
      throw WeatherApiException(
        'Invalid data format',
        details: 'The weather data could not be parsed correctly.\nError: ${e.message}',
      );
    } on WeatherApiException {
      rethrow;
    } catch (e, stackTrace) {
      // Handle unexpected errors
      if (e.toString().contains('CERTIFICATE_VERIFY_FAILED')) {
        throw WeatherApiException(
          'SSL Certificate error',
          details: 'Try restarting the app or simulator.',
        );
      }
      throw WeatherApiException(
        'Unexpected error occurred',
        details: 'Error: $e\nStack trace: $stackTrace',
      );
    }
  }

  static Weather _handleResponse(http.Response response, String cityName) {
    final statusCode = response.statusCode;

    // Success
    if (statusCode == 200) {
      return _parseWeatherData(response.body, cityName);
    }

    // Handle error responses
    String errorMessage;
    String? errorDetails;

    try {
      final errorData = json.decode(response.body);
      errorDetails = errorData['message'] as String?;
    } catch (e) {
      errorDetails = response.body;
    }

    switch (statusCode) {
      case 400:
        errorMessage = 'Invalid request';
        errorDetails ??= 'The city name format is invalid.';
        break;
      case 401:
        errorMessage = 'Invalid API key';
        errorDetails ??= 'Please check your OpenWeatherMap API key configuration.';
        break;
      case 404:
        errorMessage = 'City not found';
        errorDetails ??= 'Please check the city name spelling and try again.';
        break;
      case 429:
        errorMessage = 'Too many requests';
        errorDetails ??= 'API rate limit exceeded. Please try again later.';
        break;
      case 500:
      case 502:
      case 503:
      case 504:
        errorMessage = 'Server error';
        errorDetails ??= 'The weather service is temporarily unavailable. Please try again later.';
        break;
      default:
        errorMessage = 'Failed to load weather data';
        errorDetails ??= 'HTTP status code: $statusCode';
    }

    throw WeatherApiException(
      errorMessage,
      details: errorDetails,
      statusCode: statusCode,
    );
  }

  static Weather _parseWeatherData(String responseBody, String cityName) {
    try {
      // Validate response body
      if (responseBody.isEmpty) {
        throw const FormatException('Empty response body received from server');
      }

      // Parse JSON
      final Map<String, dynamic> data;
      try {
        data = json.decode(responseBody) as Map<String, dynamic>;
      } on FormatException catch (e) {
        throw FormatException('Invalid JSON format: ${e.message}');
      }

      // Validate data is not empty
      if (data.isEmpty) {
        throw const FormatException('Empty weather data received from server');
      }

      // Parse weather object
      final weather = Weather.fromJson(data);

      return weather;
    } on FormatException {
      rethrow;
    } catch (e, stackTrace) {
      throw FormatException(
        'Failed to parse weather data for "$cityName": $e\nStack: $stackTrace'
      );
    }
  }
}
