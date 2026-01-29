import 'package:flutter/material.dart';
import '../models/weather.dart';
import '../services/weather_api.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  Weather? weather;
  bool isLoading = false;
  String? errorMessage;
  final TextEditingController _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cityController.text = 'Bangkok';
    loadWeather('Bangkok');
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  Future<void> loadWeather(String cityName) async {
    // Validate input
    final trimmedCityName = cityName.trim();
    if (trimmedCityName.isEmpty) {
      setState(() {
        errorMessage = 'Please enter a city name';
        weather = null;
      });
      _showErrorSnackBar('Please enter a city name', canRetry: false);
      return;
    }

    // Prevent duplicate requests
    if (isLoading) {
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final fetchedWeather = await WeatherApi.fetchWeatherByCity(trimmedCityName);

      // Check if widget is still mounted before updating state
      if (!mounted) return;

      setState(() {
        weather = fetchedWeather;
        errorMessage = null;
      });
    } catch (e) {
      // Check if widget is still mounted before updating state
      if (!mounted) return;

      final errorText = _formatErrorMessage(e);
      final canRetry = _canRetryError(e);

      setState(() {
        errorMessage = errorText;
        weather = null;
      });

      _showErrorSnackBar(errorText, canRetry: canRetry, retryCity: trimmedCityName);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String _formatErrorMessage(dynamic error) {
    final errorString = error.toString();

    // Remove common prefixes
    String message = errorString
        .replaceAll('Exception: ', '')
        .replaceAll('FormatException: ', '')
        .replaceAll('WeatherApiException: ', '');

    // Add user-friendly context for common errors
    if (message.contains('City not found')) {
      return 'City not found\nPlease check the spelling and try again';
    } else if (message.contains('No internet connection')) {
      return 'No internet connection\nPlease check your network settings';
    } else if (message.contains('timeout') || message.contains('Timeout')) {
      return 'Request timed out\nThe server is not responding';
    } else if (message.contains('SSL') || message.contains('Certificate')) {
      return 'SSL Certificate error\nTry restarting the app';
    } else if (message.contains('Invalid API key')) {
      return 'API configuration error\nPlease contact support';
    } else if (message.contains('rate limit')) {
      return 'Too many requests\nPlease wait a moment and try again';
    } else if (message.contains('Server error')) {
      return 'Weather service unavailable\nPlease try again later';
    }

    // Return the formatted message
    return message.split('\n').first;
  }

  bool _canRetryError(dynamic error) {
    final errorString = error.toString().toLowerCase();

    // Don't retry for validation errors
    if (errorString.contains('city name cannot be empty') ||
        errorString.contains('invalid api key') ||
        errorString.contains('api configuration')) {
      return false;
    }

    // Retry for network and temporary errors
    return errorString.contains('timeout') ||
        errorString.contains('connection') ||
        errorString.contains('network') ||
        errorString.contains('server error') ||
        errorString.contains('try again');
  }

  void _showErrorSnackBar(String message, {bool canRetry = true, String? retryCity}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 6),
        behavior: SnackBarBehavior.floating,
        action: canRetry
            ? SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: () {
                  final cityToRetry = retryCity ?? _cityController.text;
                  if (cityToRetry.isNotEmpty) {
                    loadWeather(cityToRetry);
                  }
                },
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      labelText: 'City Name',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.location_city),
                      suffixIcon: _cityController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _cityController.clear();
                                  errorMessage = null;
                                });
                              },
                            )
                          : null,
                      errorText: errorMessage != null &&
                              _cityController.text.trim().isEmpty
                          ? 'Please enter a city name'
                          : null,
                      helperText: 'e.g., Bangkok, Tokyo, London',
                    ),
                    textCapitalization: TextCapitalization.words,
                    autocorrect: false,
                    enableSuggestions: true,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (value) => loadWeather(value),
                    onChanged: (value) {
                      // Clear error when user starts typing
                      if (errorMessage != null && value.trim().isNotEmpty) {
                        setState(() {
                          errorMessage = null;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.search),
                  onPressed: isLoading ? null : () => loadWeather(_cityController.text),
                  style: IconButton.styleFrom(
                    backgroundColor: isLoading
                        ? Colors.grey
                        : Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                    disabledBackgroundColor: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: isLoading
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text(
                            'Loading weather data...',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : weather == null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  errorMessage != null
                                      ? Icons.error_outline
                                      : Icons.cloud_off,
                                  size: 80,
                                  color: errorMessage != null
                                      ? Colors.red.shade300
                                      : Colors.grey[400],
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  errorMessage ??
                                      'Enter a city name to get weather',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: errorMessage != null
                                        ? Colors.red.shade700
                                        : Colors.grey[600],
                                    fontWeight: errorMessage != null
                                        ? FontWeight.w500
                                        : FontWeight.normal,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (errorMessage != null) ...[
                                  const SizedBox(height: 24),
                                  ElevatedButton.icon(
                                    onPressed: () => loadWeather(_cityController.text),
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Try Again'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          child: Column(
                            children: [
                              Card(
                                elevation: 4,
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        weather!.cityName,
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Image.network(
                                        weather!.iconUrl,
                                        width: 100,
                                        height: 100,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return const Icon(
                                            Icons.wb_sunny,
                                            size: 100,
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        '${weather!.temperature.toStringAsFixed(1)}°C',
                                        style: const TextStyle(
                                          fontSize: 48,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        weather!.description.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Card(
                                elevation: 4,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      _buildWeatherDetail(
                                        Icons.thermostat,
                                        'Feels Like',
                                        '${weather!.feelsLike.toStringAsFixed(1)}°C',
                                      ),
                                      const Divider(),
                                      _buildWeatherDetail(
                                        Icons.water_drop,
                                        'Humidity',
                                        '${weather!.humidity}%',
                                      ),
                                      const Divider(),
                                      _buildWeatherDetail(
                                        Icons.air,
                                        'Wind Speed',
                                        '${weather!.windSpeed.toStringAsFixed(1)} m/s',
                                      ),
                                      const Divider(),
                                      _buildWeatherDetail(
                                        Icons.compress,
                                        'Pressure',
                                        '${weather!.pressure} hPa',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDetail(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
