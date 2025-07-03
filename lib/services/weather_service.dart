import 'dart:convert';
// import 'package:http/http.dart' as http;
import 'package:http/http.dart' as http;
import '../models/weather_forecast_model.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';
  
  Future<WeatherForecast> getWeatherForecast(
    double latitude,
    double longitude,
    String model,
  ) async {
    final url = Uri.parse(_baseUrl).replace(queryParameters: {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'daily': 'temperature_2m_max,temperature_2m_min',
      'timezone': 'Europe/Berlin',
      'forecast_days': '14',
      'models': model,
    });

    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return WeatherForecast.fromJson(jsonData);
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  Future<Map<String, WeatherForecast>> getMultiModelForecast(
    double latitude,
    double longitude,
    List<String> models,
  ) async {
    final forecasts = <String, WeatherForecast>{};
    
    for (final model in models) {
      try {
        final forecast = await getWeatherForecast(latitude, longitude, model);
        forecasts[model] = forecast;
      } catch (e) {
        print('Erreur pour le modèle $model: $e');
      }
    }
    
    return forecasts;
  }
}