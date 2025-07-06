import 'package:intl/intl.dart';
// ADD THIS IMPORT: Required for date formatting initialization.
import 'package:intl/date_symbol_data_local.dart';
import '../services/weather_service.dart';

class WeatherForecast {
  final String locationName;
  final String model;
  final List<DailyForecast> dailyForecasts;
  final double latitude;
  final double longitude;
  final String timezone;

  WeatherForecast({
    required this.locationName,
    required this.model,
    required this.dailyForecasts,
    required this.latitude,
    required this.longitude,
    required this.timezone,
  });

  /// Creates a WeatherForecast instance from a JSON map.
  ///
  /// This factory is robust against `null` or missing values in the API response.
  /// It initializes `locationName` and `model` with empty strings, as they are not
  /// present in the JSON. Use the `copyWith` method to add them later.
  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    final dailyData = json['daily'] as Map<String, dynamic>? ?? {};

    // Extract all data lists from the API response.
    final timeList = dailyData['time'] as List?;
    final maxTempList = dailyData['temperature_2m_max'] as List?;
    final minTempList = dailyData['temperature_2m_min'] as List?;
    final precipitationSumList = dailyData['precipitation_sum'] as List?;
    final precipitationHoursList = dailyData['precipitation_hours'] as List?;
    final snowfallSumList = dailyData['snowfall_sum'] as List?;
    final precipitationProbabilityMaxList =
    dailyData['precipitation_probability_max'] as List?;
    final weatherCodeList = dailyData['weathercode'] as List?;
    final cloudCoverMeanList = dailyData['cloudcover_mean'] as List?;
    final windSpeedMaxList = dailyData['windspeed_10m_max'] as List?;
    final windGustsMaxList = dailyData['windgusts_10m_max'] as List?;

    // If essential time data is missing, we cannot proceed.
    if (timeList == null) {
      return WeatherForecast(
        locationName: '',
        model: '',
        dailyForecasts: [],
        latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
        timezone: json['timezone'] as String? ?? '',
      );
    }

    final forecasts = <DailyForecast>[];
    for (int i = 0; i < timeList.length; i++) {
      // --- FIX: Check if the core data for this day is valid ---
      // If temperature_2m_max is null, the model doesn't provide data for this day.
      // We skip this iteration to avoid creating an empty DailyForecast object.
      if (maxTempList?[i] == null) {
        continue;
      }

      // Safely create a DailyForecast object for each day.
      forecasts.add(DailyForecast(
        date: DateTime.parse(timeList[i] as String),
        temperatureMax: (maxTempList?[i] as num?)?.toDouble() ?? 0.0,
        temperatureMin: (minTempList?[i] as num?)?.toDouble() ?? 0.0,
        precipitationSum: (precipitationSumList?[i] as num?)?.toDouble(),
        precipitationHours: (precipitationHoursList?[i] as num?)?.toDouble(),
        snowfallSum: (snowfallSumList?[i] as num?)?.toDouble(),
        precipitationProbabilityMax:
        (precipitationProbabilityMaxList?[i] as num?)?.toInt(),
        weatherCode: (weatherCodeList?[i] as num?)?.toInt(),
        cloudCoverMean: (cloudCoverMeanList?[i] as num?)?.toInt(),
        windSpeedMax: (windSpeedMaxList?[i] as num?)?.toDouble(),
        windGustsMax: (windGustsMaxList?[i] as num?)?.toDouble(),
      ));
    }

    return WeatherForecast(
      locationName: '', // To be set via copyWith
      model: '', // To be set via copyWith
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timezone: json['timezone'] as String,
      dailyForecasts: forecasts,
    );
  }

  /// Creates a copy of this WeatherForecast but with the given fields replaced with the new values.
  WeatherForecast copyWith({
    String? locationName,
    String? model,
  }) {
    return WeatherForecast(
      locationName: locationName ?? this.locationName,
      model: model ?? this.model,
      dailyForecasts: dailyForecasts,
      latitude: latitude,
      longitude: longitude,
      timezone: timezone,
    );
  }

  @override
  String toString() {
    final forecastsString = dailyForecasts.map((f) => '  - $f').join('\n');
    return '''
WeatherForecast(
  locationName: '$locationName', model: '$model',
  latitude: $latitude, longitude: $longitude,
  dailyForecasts: [
$forecastsString
  ]
)''';
  }
}

class DailyForecast {
  final DateTime date;
  final double temperatureMax;
  final double temperatureMin;
  // NEW: Added fields for extended weather data
  final double? precipitationSum;
  final double? precipitationHours;
  final double? snowfallSum;
  final int? precipitationProbabilityMax;
  final int? weatherCode;
  final int? cloudCoverMean;
  final double? windSpeedMax;
  final double? windGustsMax;

  DailyForecast({
    required this.date,
    required this.temperatureMax,
    required this.temperatureMin,
    // New fields
    this.precipitationSum,
    this.precipitationHours,
    this.snowfallSum,
    this.precipitationProbabilityMax,
    this.weatherCode,
    this.cloudCoverMean,
    this.windSpeedMax,
    this.windGustsMax,
  });

  // Convenience getters for use in UI
  int get dayOfYear => int.parse(DateFormat('D').format(date));
  String get formattedDate => DateFormat('EEEE d MMMM', 'fr_FR').format(date);

  @override
  String toString() {
    // IMPROVEMENT: Handle null values gracefully for a cleaner printout.
    final precipText =
    precipitationSum != null ? '${precipitationSum}mm' : 'N/A';
    final windText =
    windSpeedMax != null ? '${windSpeedMax?.toStringAsFixed(1)}km/h' : 'N/A';
    final codeText = weatherCode != null ? '$weatherCode' : 'N/A';

    return 'DailyForecast(date: $formattedDate, max: ${temperatureMax.toStringAsFixed(1)}°C, min: ${temperatureMin.toStringAsFixed(1)}°C, precip: $precipText, wind: $windText, code: $codeText)';
  }
}

/// A self-contained main function to test the model and service together.
/// You can run this file directly from your IDE to verify the logic.
void main() async {
  // FIX: Initialize date formatting for the 'fr_FR' locale.
  // This must be done before any locale-specific date formatting is used.
  await initializeDateFormatting('fr_FR', null);

  // Setup
  final weatherService = WeatherService();
  const locationName = 'Saarbrücken-Ensheim';
  // Use a model that doesn't provide a full 16-day forecast to test the fix.
  // const selectedModel = 'meteofrance_seamless';
  const selectedModel = 'best_match';
  const lat = 49.21;
  const lon = 7.11;

  print(
      "--- Testing WeatherService -> WeatherForecast model parsing for '$locationName' ---");

  try {
    // 1. Fetch the forecast using the service.
    final WeatherForecast forecast = await weatherService.getWeatherForecast(
      latitude: lat,
      longitude: lon,
      model: selectedModel,
      locationName: locationName,
    );

    // 2. Print the final, populated object to verify all data was parsed correctly.
    print("#### Forecast Result:\n${forecast.toString()}");
    print("\nTotal forecast days found: ${forecast.dailyForecasts.length}");

    // 3. Verify a few specific fields from the new data.
    if (forecast.dailyForecasts.isNotEmpty) {
      print("\n--- Verification of first day's data ---");
      final firstDay = forecast.dailyForecasts.first;
      print("Max Temp: ${firstDay.temperatureMax}°C");
      print("Precipitation Sum: ${firstDay.precipitationSum} mm");
      print("Weather Code: ${firstDay.weatherCode}");
      print("Max Wind Speed: ${firstDay.windSpeedMax} km/h");
    }
  } catch (e) {
    print("An error occurred during the test: $e");
  }
}