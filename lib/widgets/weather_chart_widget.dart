import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/weather_forecast_model.dart';
import '../models/climate_normal_model.dart';
import '../services/climate_data_service.dart';

class WeatherChart extends StatefulWidget {
  final WeatherForecast forecast;
  final List<ClimateNormal> climateNormals;

  const WeatherChart({
    super.key,
    required this.forecast,
    required this.climateNormals,
  });

  @override
  State<WeatherChart> createState() => _WeatherChartState();
}

class _WeatherChartState extends State<WeatherChart> {
  final ClimateDataService _climateService = ClimateDataService();
  bool _showDeviations = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Affichage des écarts:', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(width: 16),
            Switch(
              value: _showDeviations,
              onChanged: (value) {
                setState(() {
                  _showDeviations = value;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 400,
          child: _showDeviations ? _buildDeviationChart() : _buildTemperatureChart(),
        ),
        const SizedBox(height: 16),
        _buildLegend(),
      ],
    );
  }

  Widget _buildTemperatureChart() {
    final maxTemps = <FlSpot>[];
    final minTemps = <FlSpot>[];
    final normalMaxTemps = <FlSpot>[];
    final normalMinTemps = <FlSpot>[];

    for (int i = 0; i < widget.forecast.dailyForecasts.length; i++) {
      final forecast = widget.forecast.dailyForecasts[i];
      maxTemps.add(FlSpot(i.toDouble(), forecast.temperatureMax));
      minTemps.add(FlSpot(i.toDouble(), forecast.temperatureMin));

      final normal = ClimateNormal.findByDayOfYear(
        widget.climateNormals,
        forecast.dayOfYear,
      );
      if (normal != null) {
        normalMaxTemps.add(FlSpot(i.toDouble(), normal.temperatureMax));
        normalMinTemps.add(FlSpot(i.toDouble(), normal.temperatureMin));
      }
    }
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 5,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[300]!,
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.grey[300]!,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < widget.forecast.dailyForecasts.length) {
                  final forecast = widget.forecast.dailyForecasts[index];
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      '${forecast.date.day}/${forecast.date.month}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 5,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}°C',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              },
              reservedSize: 42,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: maxTemps,
            isCurved: true,
            color: Colors.red,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: false),
          ),
          LineChartBarData(
            spots: minTemps,
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: false),
          ),
          LineChartBarData(
            spots: normalMaxTemps,
            isCurved: true,
            color: Colors.red.withOpacity(0.3),
            barWidth: 2,
            isStrokeCapRound: true,
            dashArray: [5, 5],
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
          LineChartBarData(
            spots: normalMinTemps,
            isCurved: true,
            color: Colors.blue.withOpacity(0.3),
            barWidth: 2,
            isStrokeCapRound: true,
            dashArray: [5, 5],
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        ],
        // CJG 🎯 Ajout du tooltip personnalisé
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  '${spot.y.toStringAsFixed(1)}°C',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );

    //CJG
    // return LineChart(
    //   LineChartData(
    //     gridData: FlGridData(
    //       show: true,
    //       drawVerticalLine: true,
    //       horizontalInterval: 5,
    //       verticalInterval: 1,
    //       getDrawingHorizontalLine: (value) {
    //         return FlLine(
    //           color: Colors.grey[300]!,
    //           strokeWidth: 1,
    //         );
    //       },
    //       getDrawingVerticalLine: (value) {
    //         return FlLine(
    //           color: Colors.grey[300]!,
    //           strokeWidth: 1,
    //         );
    //       },
    //     ),
    //     titlesData: FlTitlesData(
    //       show: true,
    //       rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    //       topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    //       bottomTitles: AxisTitles(
    //         sideTitles: SideTitles(
    //           showTitles: true,
    //           reservedSize: 30,
    //           interval: 1,
    //           getTitlesWidget: (value, meta) {
    //             final index = value.toInt();
    //             if (index >= 0 && index < widget.forecast.dailyForecasts.length) {
    //               final forecast = widget.forecast.dailyForecasts[index];
    //               return SideTitleWidget(
    //                 axisSide: meta.axisSide,
    //                 child: Text(
    //                   '${forecast.date.day}/${forecast.date.month}',
    //                   style: const TextStyle(
    //                     color: Colors.grey,
    //                     fontWeight: FontWeight.bold,
    //                     fontSize: 12,
    //                   ),
    //                 ),
    //               );
    //             }
    //             return const Text('');
    //           },
    //         ),
    //       ),
    //       leftTitles: AxisTitles(
    //         sideTitles: SideTitles(
    //           showTitles: true,
    //           interval: 5,
    //           getTitlesWidget: (value, meta) {
    //             return Text(
    //               '${value.toInt()}°C',
    //               style: const TextStyle(
    //                 color: Colors.grey,
    //                 fontWeight: FontWeight.bold,
    //                 fontSize: 12,
    //               ),
    //             );
    //           },
    //           reservedSize: 42,
    //         ),
    //       ),
    //     ),
    //     borderData: FlBorderData(
    //       show: true,
    //       border: Border.all(color: const Color(0xff37434d)),
    //     ),
    //     lineBarsData: [
    //       LineChartBarData(
    //         spots: maxTemps,
    //         isCurved: true,
    //         color: Colors.red,
    //         barWidth: 3,
    //         isStrokeCapRound: true,
    //         dotData: const FlDotData(show: true),
    //         belowBarData: BarAreaData(show: false),
    //       ),
    //       LineChartBarData(
    //         spots: minTemps,
    //         isCurved: true,
    //         color: Colors.blue,
    //         barWidth: 3,
    //         isStrokeCapRound: true,
    //         dotData: const FlDotData(show: true),
    //         belowBarData: BarAreaData(show: false),
    //       ),
    //       LineChartBarData(
    //         spots: normalMaxTemps,
    //         isCurved: true,
    //         color: Colors.red.withOpacity(0.3),
    //         barWidth: 2,
    //         isStrokeCapRound: true,
    //         dashArray: [5, 5],
    //         dotData: const FlDotData(show: false),
    //         belowBarData: BarAreaData(show: false),
    //       ),
    //       LineChartBarData(
    //         spots: normalMinTemps,
    //         isCurved: true,
    //         color: Colors.blue.withOpacity(0.3),
    //         barWidth: 2,
    //         isStrokeCapRound: true,
    //         dashArray: [5, 5],
    //         dotData: const FlDotData(show: false),
    //         belowBarData: BarAreaData(show: false),
    //       ),
    //     ],
    //   ),
    // );
  }

  Widget _buildDeviationChart() {
    final deviations = <FlSpot>[];
    final barGroups = <BarChartGroupData>[];

    for (int i = 0; i < widget.forecast.dailyForecasts.length; i++) {
      final forecast = widget.forecast.dailyForecasts[i];
      final deviation = _climateService.calculateDeviation(
        forecast.temperatureMax,
        forecast.temperatureMin,
        forecast.dayOfYear,
        widget.climateNormals,
      );

      deviations.add(FlSpot(i.toDouble(), deviation.avgDeviation));

      // Créer les barres avec des couleurs basées sur l'écart
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: deviation.avgDeviation,
              color: _getDeviationColor(deviation.avgDeviation),
              width: 20,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    }

    final maxY = deviations.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 1;
    final minY = deviations.map((e) => e.y).reduce((a, b) => a < b ? a : b) - 1;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        minY: minY,
        barTouchData: BarTouchData(
          enabled: false,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final forecast = widget.forecast.dailyForecasts[groupIndex];
              final deviation = _climateService.calculateDeviation(
                forecast.temperatureMax,
                forecast.temperatureMin,
                forecast.dayOfYear,
                widget.climateNormals,
              );
              return BarTooltipItem(
                '${forecast.formattedDate}\n',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: 'Écart: ${deviation.avgDeviationText}',
                    style: const TextStyle(
                      color: Colors.yellow,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < widget.forecast.dailyForecasts.length) {
                  final forecast = widget.forecast.dailyForecasts[index];
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      '${forecast.date.day}/${forecast.date.month}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toStringAsFixed(1)}°C',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              },
              reservedSize: 42,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d)),
        ),
        barGroups: barGroups,
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[300]!,
              strokeWidth: 1,
            );
          },
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Légende',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          if (!_showDeviations) ...[
            _buildLegendItem(Colors.red, 'Température maximum prévue'),
            _buildLegendItem(Colors.blue, 'Température minimum prévue'),
            _buildLegendItem(Colors.red.withOpacity(0.3), 'Normale maximum (pointillés)'),
            _buildLegendItem(Colors.blue.withOpacity(0.3), 'Normale minimum (pointillés)'),
          ] else ...[
            const Text(
              'Écarts à la normale (couleurs):',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildDeviationLegendItem(Colors.red[700]!, '> +2°C'),
                const SizedBox(width: 16),
                _buildDeviationLegendItem(Colors.orange[600]!, '+1 à +2°C'),
                const SizedBox(width: 16),
                _buildDeviationLegendItem(Colors.orange[400]!, '+0.5 à +1°C'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildDeviationLegendItem(Colors.green[600]!, '-0.5 à +0.5°C'),
                const SizedBox(width: 16),
                _buildDeviationLegendItem(Colors.blue[400]!, '-1 à -0.5°C'),
                const SizedBox(width: 16),
                _buildDeviationLegendItem(Colors.blue[600]!, '-2 à -1°C'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildDeviationLegendItem(Colors.blue[800]!, '< -2°C'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 3,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviationLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  // Reprendre la même logique de couleur que dans weather_table_widget.dart
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