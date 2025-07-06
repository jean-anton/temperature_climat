// lib/services/weather_service.dart

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../models/weather_forecast_model.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  // IMPROVEMENT: Define the daily parameters as a constant for clarity and reusability.
  static const String _dailyParameters =
      'temperature_2m_max,temperature_2m_min,precipitation_sum,precipitation_hours,snowfall_sum,precipitation_probability_max,weathercode,cloudcover_mean,windspeed_10m_max,windgusts_10m_max';

  /// Fetches a weather forecast for a single model.
  Future<WeatherForecast> getWeatherForecast({
    required double latitude,
    required double longitude,
    required String model,
    required String locationName, // IMPROVEMENT: Pass location name for context
  }) async {
    final url = Uri.parse(_baseUrl).replace(queryParameters: {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'daily': _dailyParameters, // UPDATED: Use the constant for daily parameters
      'timezone': 'auto',
      'forecast_days': '16',
      'models': model,
    });

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        // The fromJson factory creates the base object.
        // copyWith adds the context (model name, location name) that isn't in the API response.
        final forecast = WeatherForecast.fromJson(jsonData).copyWith(
          locationName: locationName,
          model: model,
        );
        return forecast;
      } else {
        throw Exception(
            'API Error for model $model: ${response.statusCode} ${response.reasonPhrase}');
      }
    } on TimeoutException {
      throw Exception('Request for model $model timed out.');
    } catch (e) {
      // Re-throw with more specific context for easier debugging.
      throw Exception('Failed to get weather for model $model: $e');
    }
  }

  /// Fetches forecasts from multiple models in PARALLEL for much faster execution.
  Future<Map<String, WeatherForecast>> getMultiModelForecast({
    required double latitude,
    required double longitude,
    required String locationName, // IMPROVEMENT: Pass location name for context
    required List<String> models,
  }) async {
    // 1. Create a list of all the future API calls to be made.
    final futures = models.map((model) {
      return getWeatherForecast(
        latitude: latitude,
        longitude: longitude,
        model: model,
        locationName: locationName, // Pass down the location name
      )
      // If a single model fails, we don't want to crash the entire operation.
          .catchError((e) {
        log('Failed to fetch forecast for model $model',
            error: e, name: 'WeatherService');
        return null; // Return null on failure so Future.wait doesn't fail completely.
      });
    }).toList();

    // 2. Wait for all the API calls to complete concurrently.
    final results = await Future.wait(futures);

    // 3. Process the results into the final map.
    final forecasts = <String, WeatherForecast>{};
    for (int i = 0; i < models.length; i++) {
      final forecast = results[i];
      if (forecast != null) {
        // Use the model name from the original list to key the map.
        forecasts[models[i]] = forecast;
      }
    }

    return forecasts;
  }
}