import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../data/weather_icon_data.dart';
import '../models/climate_normal_model.dart';
import '../models/weather_forecast_model.dart';
import '../models/weather_icon.dart';
import '../services/climate_data_service.dart';

// Data models for chart data. Kept here for simplicity as they are local to this widget.
class _ChartData {
  final int x;
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final double? normalMaxTemp;
  final double? normalMinTemp;
  final double? maxTempDeviation;
  final double? minTempDeviation;
  final String? iconPath;
  final String? weatherDescription;
  final double? precipitationSum;
  final int? precipitationProbability;
  final double? windSpeed;
  final int? cloudCover;
  final int? weatherCode;

  _ChartData({
    required this.x,
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    this.normalMaxTemp,
    this.normalMinTemp,
    this.maxTempDeviation,
    this.minTempDeviation,
    this.iconPath,
    this.weatherDescription,
    this.precipitationSum,
    this.precipitationProbability,
    this.windSpeed,
    this.cloudCover,
    this.weatherCode,
  });
}

class _DeviationChartData {
  final int x;
  final DateTime date;
  final double deviation;
  final String deviationText;
  final String formattedDate;

  _DeviationChartData({
    required this.x,
    required this.date,
    required this.deviation,
    required this.deviationText,
    required this.formattedDate,
  });
}

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

  late List<_ChartData> _chartData;
  late List<_DeviationChartData> _deviationChartData;
  late final Map<String, WeatherIcon> _weatherIconMap;

  @override
  void initState() {
    super.initState();
    _weatherIconMap = {for (var icon in weatherIcons) icon.code: icon};
    _prepareChartData();
  }

  @override
  void didUpdateWidget(WeatherChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.forecast != oldWidget.forecast ||
        widget.climateNormals != oldWidget.climateNormals) {
      _prepareChartData();
    }
  }

  /// Prepares all data needed for the charts.
  void _prepareChartData() {
    _chartData = [];
    _deviationChartData = [];

    for (int i = 0; i < widget.forecast.dailyForecasts.length; i++) {
      final forecast = widget.forecast.dailyForecasts[i];
      final normal = ClimateNormal.findByDayOfYear(
        widget.climateNormals,
        forecast.dayOfYear,
      );

      final weatherIcon = _weatherIconMap[forecast.weatherCode?.toString()];

      double? maxDeviation;
      if (normal?.temperatureMax != null) {
        maxDeviation = forecast.temperatureMax - normal!.temperatureMax;
      }
      double? minDeviation;
      if (normal?.temperatureMin != null) {
        minDeviation = forecast.temperatureMin - normal!.temperatureMin;
      }

      // Prepare data for the temperature chart
      _chartData.add(_ChartData(
        x: i,
        date: forecast.date,
        maxTemp: forecast.temperatureMax,
        minTemp: forecast.temperatureMin,
        normalMaxTemp: normal?.temperatureMax,
        normalMinTemp: normal?.temperatureMin,
        maxTempDeviation: maxDeviation,
        minTempDeviation: minDeviation,
        iconPath: weatherIcon?.iconPath,
        weatherDescription: weatherIcon?.descriptionFr,
        precipitationSum: forecast.precipitationSum,
        precipitationProbability: forecast.precipitationProbabilityMax,
        windSpeed: forecast.windSpeedMax,
        cloudCover: forecast.cloudCoverMean,
        weatherCode: forecast.weatherCode,
      ));

      // Prepare data for the deviation chart
      final deviation = _climateService.calculateDeviation(
        forecast.temperatureMax,
        forecast.temperatureMin,
        forecast.dayOfYear,
        widget.climateNormals,
      );

      _deviationChartData.add(_DeviationChartData(
        x: i,
        date: forecast.date,
        deviation: deviation.avgDeviation,
        deviationText: deviation.avgDeviationText,
        formattedDate: forecast.formattedDate,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Affichage des écarts:',
                style: TextStyle(fontWeight: FontWeight.w500)),
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
        SizedBox(
          height: 400,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _showDeviations
                ? _buildDeviationChart()
                : _buildTemperatureChart(),
          ),
        ),
      ],
    );
  }

  Widget _buildTemperatureChart() {
    return ScrollConfiguration(
      behavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
        },
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          // width: MediaQuery.of(context).size.width * 2, // 2 times the window width
          width: MediaQuery.of(context).size.width < 600 ? MediaQuery.of(context).size.width * 2  : MediaQuery.of(context).size.width, // 2 times the window width
          height: 400, // Set a fixed height for the chart, adjust as needed
          child: SfCartesianChart(
            key: const ValueKey('temp_chart'),
            annotations: <CartesianChartAnnotation>[
              for (final data in _chartData)
                if (data.iconPath != null)
                  CartesianChartAnnotation(
                    widget: SvgPicture.asset(
                      data.iconPath!,
                      width: 30,
                      height: 30,
                    ),
                    coordinateUnit: CoordinateUnit.point,
                    region: AnnotationRegion.chart,
                    x: '${data.date.day}/${data.date.month}',
                    y: data.maxTemp,
                  ),
            ],
            primaryXAxis: CategoryAxis(
              labelStyle: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            primaryYAxis: NumericAxis(
              labelStyle: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              interval: 5,
              labelFormat: '{value}°',
            ),
            legend: Legend(isVisible: false),
            tooltipBehavior: TooltipBehavior(
              enable: true,
              duration: 10000,
              color: Colors.transparent,
              elevation: 0,
              builder: (dynamic data, dynamic point, dynamic series, int pointIndex,
                  int seriesIndex) {
                final chartData = data as _ChartData;
                final isMaxTemp = series.name == 'Température maximum prévue';
                final temp = isMaxTemp ? chartData.maxTemp : chartData.minTemp;
                final tempLabel = isMaxTemp ? 'Max' : 'Min';

                return Container(
                  width: 300,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE d MMMM', 'fr_FR').format(chartData.date),
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const Divider(height: 10, color: Colors.black26),
                      if (chartData.weatherDescription != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: Text(
                            chartData.weatherDescription!,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontStyle: FontStyle.italic,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      _buildTooltipRow(
                          Icons.thermostat, 'Temp. $tempLabel: ${temp.round()}°C'),
                      if (chartData.precipitationSum != null &&
                          chartData.precipitationSum! > 0)
                        _buildTooltipRow(Icons.water_drop,
                            'Précip: ${chartData.precipitationSum?.toStringAsFixed(1)} mm'),
                      if (chartData.precipitationProbability != null)
                        _buildTooltipRow(Icons.umbrella,
                            'Prob. préc: ${chartData.precipitationProbability}%'),
                      if (chartData.windSpeed != null)
                        _buildTooltipRow(
                            Icons.air, 'Vent: ${chartData.windSpeed?.round()} km/h'),
                      if (chartData.cloudCover != null)
                        _buildTooltipRow(
                            Icons.cloud, 'Nébulosité: ${chartData.cloudCover}%'),
                      if (chartData.weatherCode != null)
                        _buildTooltipRow(
                            Icons.tag, 'Code: ${chartData.weatherCode}'),
                    ],
                  ),
                );
              },
            ),
            zoomPanBehavior: ZoomPanBehavior(
              enablePinching: true,
              enablePanning: true,
              enableDoubleTapZooming: true,
            ),
            series: <CartesianSeries>[
              // --- UPDATED: Changed LineSeries to SplineSeries ---
              SplineSeries<_ChartData, String>(
                animationDuration: 100,
                dataSource: _chartData,
                xValueMapper: (_ChartData data, _) =>
                '${data.date.day}/${data.date.month}',
                yValueMapper: (_ChartData data, _) => data.maxTemp,
                name: 'Température maximum prévue',
                color: Colors.red,
                width: 3,
                markerSettings: const MarkerSettings(isVisible: false),
                dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  labelAlignment: ChartDataLabelAlignment.top,
                  builder: (data, point, series, pointIndex, seriesIndex) {
                    final chartData = data as _ChartData;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 30.0),
                      child: _buildTempLabel(
                          chartData.maxTemp, chartData.maxTempDeviation),
                    );
                  },
                ),
              ),
              // --- UPDATED: Changed LineSeries to SplineSeries ---
              SplineSeries<_ChartData, String>(
                animationDuration: 100,
                dataSource: _chartData,
                xValueMapper: (_ChartData data, _) =>
                '${data.date.day}/${data.date.month}',
                yValueMapper: (_ChartData data, _) => data.minTemp,
                name: 'Température minimum prévue',
                color: Colors.blue,
                width: 3,
                markerSettings: const MarkerSettings(isVisible: true),
                dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  labelAlignment: ChartDataLabelAlignment.bottom,
                  builder: (data, point, series, pointIndex, seriesIndex) {
                    final chartData = data as _ChartData;
                    return _buildTempLabel(
                        chartData.minTemp, chartData.minTempDeviation);
                  },
                ),
              ),
              // --- UPDATED: Changed LineSeries to SplineSeries ---
              SplineSeries<_ChartData, String>(
                animationDuration: 100,
                dataSource:
                _chartData.where((data) => data.normalMaxTemp != null).toList(),
                xValueMapper: (_ChartData data, _) =>
                '${data.date.day}/${data.date.month}',
                yValueMapper: (_ChartData data, _) => data.normalMaxTemp,
                name: 'Normale maximum',
                color: Colors.red.withOpacity(0.5),
                width: 3,
                dashArray: const <double>[5, 5],
                markerSettings: const MarkerSettings(isVisible: false),
              ),
              // --- UPDATED: Changed LineSeries to SplineSeries ---
              SplineSeries<_ChartData, String>(
                animationDuration: 500,
                dataSource:
                _chartData.where((data) => data.normalMinTemp != null).toList(),
                xValueMapper: (_ChartData data, _) =>
                '${data.date.day}/${data.date.month}',
                yValueMapper: (_ChartData data, _) => data.normalMinTemp,
                name: 'Normale minimum',
                color: Colors.blue.withOpacity(0.5),
                width: 3,
                dashArray: const <double>[5, 5],
                markerSettings: const MarkerSettings(isVisible: false),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildTooltipRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.black54, size: 14),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.black, fontSize: 17)),
        ],
      ),
    );
  }

  Widget _buildTempLabel(double temp, double? deviation) {
    if (deviation == null) {
      return Text('${temp.round()}°',
          style: const TextStyle(
              color: Colors.black,
              fontSize: 11,
              fontWeight: FontWeight.bold));
    }

    final deviationText = '${deviation > 0 ? '+' : ''}${deviation.round()}°';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('${temp.round()}°',
            style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(
          " $deviationText",
          style: TextStyle(
            color: _getDeviationColor(deviation),
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDeviationChart() {
    return SfCartesianChart(
      key: const ValueKey('deviation_chart'),
      primaryXAxis: CategoryAxis(
        title: AxisTitle(text: 'Date'),
        labelStyle: const TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(text: 'Écart (°C)'),
        labelStyle: const TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        labelFormat: '{value}°C',
      ),
      legend: Legend(isVisible: false),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        color: Colors.blueGrey,
        textStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        builder: (dynamic data, dynamic point, dynamic series, int pointIndex,
            int seriesIndex) {
          final deviationData = data as _DeviationChartData;
          return Container(
            padding: const EdgeInsets.all(10),
            child: Text(
              '${deviationData.formattedDate}\nÉcart : ${deviationData.deviationText}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          );
        },
      ),
      zoomPanBehavior: ZoomPanBehavior(
        enablePinching: true,
        enablePanning: true,
        enableDoubleTapZooming: true,
      ),
      series: <CartesianSeries>[
        ColumnSeries<_DeviationChartData, String>(
          animationDuration: 100,
          dataSource: _deviationChartData,
          xValueMapper: (_DeviationChartData data, _) =>
          '${data.date.day}/${data.date.month}',
          yValueMapper: (_DeviationChartData data, _) => data.deviation,
          pointColorMapper: (_DeviationChartData data, _) =>
              _getDeviationColor(data.deviation),
          name: 'Écart à la normale',
          width: 0.8,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
          dataLabelSettings: const DataLabelSettings(isVisible: false),
        ),
      ],
    );
  }

  Color _getDeviationColor(double deviation) {
    if (deviation > 2) return Colors.red[700]!;
    if (deviation > 1) return Colors.orange[600]!;
    if (deviation > 0.5) return Colors.orange[400]!;
    if (deviation > -0.5) return Colors.green[600]!;
    if (deviation > -1) return Colors.blue[400]!;
    if (deviation > -2) return Colors.blue[600]!;
    return Colors.blue[800]!;
  }
}