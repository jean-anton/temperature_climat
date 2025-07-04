class ClimateNormal {
  final String dayName;
  final int dayOfYear;
  final double temperatureMax;
  final double temperatureMin;

  ClimateNormal({
    required this.dayName,
    required this.dayOfYear,
    required this.temperatureMax,
    required this.temperatureMin,
  });

  factory ClimateNormal.fromCsvRow(List<String> row) {
    return ClimateNormal(
      dayName: row[0].trim(),
      dayOfYear: int.parse(row[1].trim()),
      temperatureMax: double.parse(row[2].trim()),
      temperatureMin: double.parse(row[3].trim()),
    );
  }

  static ClimateNormal? findByDayOfYear(List<ClimateNormal> normals, int dayOfYear) {
    try {
      return normals.firstWhere((normal) => normal.dayOfYear == dayOfYear);
    } catch (e) {
      return null;
    }
  }
}

class WeatherDeviation {
  final double maxDeviation;
  final double minDeviation;
  final double avgDeviation;
  final ClimateNormal? normal;

  WeatherDeviation({
    required this.maxDeviation,
    required this.minDeviation,
    required this.avgDeviation,
    this.normal,
  });

  String get maxDeviationText {
    final sign = maxDeviation >= 0 ? '+' : '';
    return '${sign}${maxDeviation.toStringAsFixed(0)}°';
  }

  String get minDeviationText {
    final sign = minDeviation >= 0 ? '+' : '';
    return '${sign}${minDeviation.toStringAsFixed(0)}°';
  }

  String get avgDeviationText {
    final sign = avgDeviation >= 0 ? '+' : '';
    return '${sign}${avgDeviation.toStringAsFixed(1)}°C';
  }

  bool get isWarmerThanNormal => avgDeviation > 0;
  bool get isCoolerThanNormal => avgDeviation < 0;
  bool get isNormalRange => avgDeviation.abs() <= 0.5;
}