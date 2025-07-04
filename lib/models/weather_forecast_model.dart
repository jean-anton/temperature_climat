class WeatherForecast {
  final List<DailyForecast> dailyForecasts;
  final String locationName;
  final String model;

  WeatherForecast({
    required this.dailyForecasts,
    required this.locationName,
    required this.model,
  });

  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    final daily = json['daily'] as Map<String, dynamic>;
    final dates = List<String>.from(daily['time']);
    final tempMax = List<double>.from(daily['temperature_2m_max']);
    final tempMin = List<double>.from(daily['temperature_2m_min']);

    final forecasts = <DailyForecast>[];
    for (int i = 0; i < dates.length; i++) {
      forecasts.add(DailyForecast(
        date: DateTime.parse(dates[i]),
        temperatureMax: tempMax[i],
        temperatureMin: tempMin[i],
      ));
    }

    return WeatherForecast(
      dailyForecasts: forecasts,
      locationName: '',
      model: '',
    );
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
    // const months = [
    //   'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
    //   'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    // ];

    const months = [
      'Jan', 'Fev', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Aou', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    return '${date.day} ${months[date.month - 1]}';
  }

  int get dayOfYear {
    final startOfYear = DateTime(date.year, 1, 1);
    return date.difference(startOfYear).inDays + 1;
  }
}