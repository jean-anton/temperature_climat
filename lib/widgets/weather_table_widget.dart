import 'package:flutter/material.dart';
import '../models/weather_forecast_model.dart';
import '../models/climate_normal_model.dart';
import '../services/climate_data_service.dart';

class WeatherTable extends StatelessWidget {
  final WeatherForecast forecast;
  final List<ClimateNormal> climateNormals;

  const WeatherTable({
    super.key,
    required this.forecast,
    required this.climateNormals,
  });

  @override
  Widget build(BuildContext context) {
    final climateService = ClimateDataService();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 16,
        headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
        columns: const [
          DataColumn(
            label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('Temp Max', style: TextStyle(fontWeight: FontWeight.bold)),
            numeric: true,
          ),
          DataColumn(
            label: Text('Écart Max', style: TextStyle(fontWeight: FontWeight.bold)),
            numeric: true,
          ),

          DataColumn(
            label: Text('Temp Min', style: TextStyle(fontWeight: FontWeight.bold)),
            numeric: true,
          ),
          DataColumn(
            label: Text('Écart Min', style: TextStyle(fontWeight: FontWeight.bold)),
            numeric: true,
          ),
          DataColumn(
            label: Text('Normale Max', style: TextStyle(fontWeight: FontWeight.bold)),
            numeric: true,
          ),
          DataColumn(
            label: Text('Normale Min', style: TextStyle(fontWeight: FontWeight.bold)),
            numeric: true,
          ),

          DataColumn(
            label: Text('Écart Moyen', style: TextStyle(fontWeight: FontWeight.bold)),
            numeric: true,
          ),
        ],
        rows: forecast.dailyForecasts.map((dailyForecast) {
          final deviation = climateService.calculateDeviation(
            dailyForecast.temperatureMax,
            dailyForecast.temperatureMin,
            dailyForecast.dayOfYear,
            climateNormals,
          );

          return DataRow(
            cells: [
              DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dailyForecast.formattedDate,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      _getDayOfWeek(dailyForecast.date),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              DataCell(
                Text(
                  '${dailyForecast.temperatureMax.toStringAsFixed(1)}°C',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getDeviationColor(deviation.maxDeviation),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    deviation.maxDeviationText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),

              DataCell(
                Text(
                  '${dailyForecast.temperatureMin.toStringAsFixed(1)}°C',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getDeviationColor(deviation.minDeviation),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    deviation.minDeviationText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),

              DataCell(
                Text(
                  deviation.normal != null
                      ? '${deviation.normal!.temperatureMax.toStringAsFixed(1)}°C'
                      : 'N/A',
                  style: TextStyle(
                    color: Colors.red.withOpacity(0.7),
                  ),
                ),
              ),
              DataCell(
                Text(
                  deviation.normal != null
                      ? '${deviation.normal!.temperatureMin.toStringAsFixed(1)}°C'
                      : 'N/A',
                  style: TextStyle(
                    color: Colors.blue.withOpacity(0.7),
                  ),
                ),
              ),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getDeviationColor(deviation.avgDeviation),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    deviation.avgDeviationText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  String _getDayOfWeek(DateTime date) {
    const days = [
      'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'
    ];
    return days[date.weekday - 1];
  }

  Color _getDeviationColor(double deviation) {
    if (deviation > 2) {
      return Colors.red[700]!;
    } else if (deviation > 1) {
      return Colors.orange[600]!;
    } else if (deviation > 0.5) {
      return Colors.orange[400]!;
    } else if (deviation > -0.5) {
      return Colors.green[600]!;
    } else if (deviation > -1) {
      return Colors.blue[400]!;
    } else if (deviation > -2) {
      return Colors.blue[600]!;
    } else {
      return Colors.blue[800]!;
    }
  }
}