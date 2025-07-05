import 'dart:async';
import 'dart:convert';
import 'dart:developer'; // Using dart:developer for better logging
import 'package:http/http.dart' as http;
import '../models/weather_forecast_model.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  /// Fetches a weather forecast for a single model.
  Future<WeatherForecast> getWeatherForecast(
      double latitude,
      double longitude,
      String model,
      ) async {
    final url = Uri.parse(_baseUrl).replace(queryParameters: {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'daily': 'temperature_2m_max,temperature_2m_min',
      'timezone': 'auto', // 'auto' is generally more robust
      'forecast_days': '16',
      'models': model,
    });
    //print("###CJG url: $url");
    try {
      // Added a timeout for resilience against stalled requests.
      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        // Create the object from JSON, then use `copyWith` to add the context.
        // This is a robust pattern that keeps your model clean.
        final forecast = WeatherForecast.fromJson(jsonData).copyWith(
          locationName: 'Your Location', // You should pass the location name here
          model: model,
        );

        // Use the 'log' function for better debug output that avoids truncation.
        // log(forecast.toString(), name: 'WeatherService Forecast [$model]');

        return forecast;
      } else {
        // Provide a more informative error message.
        throw Exception(
            'API Error for model $model: ${response.statusCode} ${response.reasonPhrase}');
      }
    } on TimeoutException {
      throw Exception('Request for model $model timed out.');
    } catch (e) {
      // Re-throw with context for easier debugging.
      throw Exception('Failed to get weather for model $model: $e');
    }
  }

  /// Fetches forecasts from multiple models in PARALLEL for much faster execution.
  Future<Map<String, WeatherForecast>> getMultiModelForecast(
      double latitude,
      double longitude,
      List<String> models,
      ) async {
    // 1. Create a list of all the future API calls to be made.
    final futures = models.map((model) {
      return getWeatherForecast(latitude, longitude, model)
      // If a single model fails, we don't want to crash the entire operation.
      // We catch the error and return a specific result (e.g., null).
          .catchError((e) {
        log('Failed to fetch forecast for model $model', error: e, name: 'WeatherService');
        return null;
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