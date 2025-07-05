class WeatherForecast {
  final List<DailyForecast> dailyForecasts;
  final String? locationName; // Made nullable
  final String? model;        // Made nullable

  WeatherForecast({
    required this.dailyForecasts,
    this.locationName,
    this.model,
  });

  /// Creates a WeatherForecast instance from a JSON map.
  ///
  /// This factory is robust against `null` values in the API response.
  /// It initializes `locationName` and `model` as null, as they are not
  /// present in the JSON. Use the `copyWith` method to add them later.
  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    // Safely access the 'daily' map, returning an empty forecast if it's missing.
    final daily = json['daily'];
    if (daily == null || daily is! Map<String, dynamic>) {
      return WeatherForecast(dailyForecasts: []);
    }

    // Cast to generic lists that can contain nulls or other types.
    final dates = daily['time'] as List?;
    final tempMaxList = daily['temperature_2m_max'] as List?;
    final tempMinList = daily['temperature_2m_min'] as List?;

    // Check if essential data is missing.
    if (dates == null || tempMaxList == null || tempMinList == null) {
      return WeatherForecast(dailyForecasts: []);
    }

    final forecasts = <DailyForecast>[];
    // Ensure we don't go out of bounds if lists have different lengths.
    final int count = [dates.length, tempMaxList.length, tempMinList.length]
        .reduce((a, b) => a < b ? a : b);

    for (int i = 0; i < count; i++) {
      final maxTemp = tempMaxList[i];
      final minTemp = tempMinList[i];

      // --- KEY CHANGE ---
      // Only create a forecast if both temperatures are valid numbers.
      if (maxTemp is num && minTemp is num) {
        forecasts.add(DailyForecast(
          date: DateTime.parse(dates[i] as String),
          temperatureMax: maxTemp.toDouble(),
          temperatureMin: minTemp.toDouble(),
        ));
      }
    }

    return WeatherForecast(
      dailyForecasts: forecasts,
      // locationName and model are intentionally null here.
    );
  }

  /// Creates a copy of this WeatherForecast but with the given fields replaced with the new values.
  WeatherForecast copyWith({
    List<DailyForecast>? dailyForecasts,
    String? locationName,
    String? model,
  }) {
    return WeatherForecast(
      dailyForecasts: dailyForecasts ?? this.dailyForecasts,
      locationName: locationName ?? this.locationName,
      model: model ?? this.model,
    );
  }

  @override
  String toString() {
    final forecastsString = dailyForecasts.map((f) => '  - $f').join('\n');
    return '''
WeatherForecast(
  locationName: '${locationName ?? 'N/A'}',
  model: '${model ?? 'N/A'}',
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

  DailyForecast({
    required this.date,
    required this.temperatureMax,
    required this.temperatureMin,
  });

  String get formattedDate {
    const months = [
      'Jan', 'Fev', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Aou', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  int get dayOfYear {
    final startOfYear = DateTime(date.year, 1, 1);
    return date.difference(startOfYear).inDays + 1;
  }

  @override
  String toString() {
    return 'DailyForecast(date: $formattedDate, max: ${temperatureMax.toStringAsFixed(1)}°C, min: ${temperatureMin.toStringAsFixed(1)}°C)';
  }
}