import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/climate_normal_model.dart';

class ClimateDataService {
  // static const Map<String, String> _assetPaths = {
  //   '00460_Berus': 'assets/data/fichier_moyenne_jour_00460_Berus_1961_1990_gemini_pro25.csv',
  //   '04336_Saarbrücken-Ensheim': 'assets/data/fichier_moyenne_jour_04336_Saarbrücken-Ensheim_1961_1990_gemini_pro25.csv',
  // };
  static const Map<String, String> _assetPaths = {
    '00460_Berus': 'assets/data/climatologie_berus_00460.csv',
    '04336_Saarbrücken-Ensheim': 'assets/data/climatologie_sarrebruck_04336.csv',
  };

  Future<List<ClimateNormal>> loadClimateNormals(String locationKey) async {
    final assetPath = _assetPaths[locationKey];
    if (assetPath == null) {
      throw Exception('Fichier de données climatiques non trouvé pour $locationKey');
    }

    try {
      final csvString = await rootBundle.loadString(assetPath);
      return _parseCsvData(csvString);
    } catch (e) {
      throw Exception('Erreur lors du chargement des données climatiques: $e');
    }
  }

  List<ClimateNormal> _parseCsvData(String csvData) {
    final lines = const LineSplitter().convert(csvData);
    final normals = <ClimateNormal>[];

    for (int i = 1; i < lines.length; i++) { // Skip header
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      try {
        final parts = line.split(';');
        if (parts.length >= 4) {
          normals.add(ClimateNormal.fromCsvRow(parts));
        }
      } catch (e) {
        print('Erreur lors du parsing de la ligne $i: $e');
      }
    }

    return normals;
  }

  WeatherDeviation calculateDeviation(
    double forecastMax,
    double forecastMin,
    int dayOfYear,
    List<ClimateNormal> normals,
  ) {
    final normal = ClimateNormal.findByDayOfYear(normals, dayOfYear);
    
    if (normal == null) {
      return WeatherDeviation(
        maxDeviation: 0,
        minDeviation: 0,
        avgDeviation: 0,
        normal: null,
      );
    }

    final maxDev = forecastMax - normal.temperatureMax;
    final minDev = forecastMin - normal.temperatureMin;
    final avgDev = (maxDev + minDev) / 2;

    return WeatherDeviation(
      maxDeviation: maxDev,
      minDeviation: minDev,
      avgDeviation: avgDev,
      normal: normal,
    );
  }
}