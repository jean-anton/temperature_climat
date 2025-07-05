import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../models/weather_forecast_model.dart';
import '../models/climate_normal_model.dart';
import '../services/climate_data_service.dart';

// Data models for chart data. Kept here for simplicity as they are local to this widget.
class _ChartData {
  final int x;
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final double? normalMaxTemp;
  final double? normalMinTemp;
  // ADDED: Store individual deviations for direct use in labels.
  final double? maxTempDeviation;
  final double? minTempDeviation;

  _ChartData({
    required this.x,
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    this.normalMaxTemp,
    this.normalMinTemp,
    this.maxTempDeviation,
    this.minTempDeviation,
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

  // State variables to hold pre-calculated chart data.
  // This is more performant as data is not recalculated on every build.
  late List<_ChartData> _chartData;
  late List<_DeviationChartData> _deviationChartData;

  @override
  void initState() {
    super.initState();
    _prepareChartData();
  }

  @override
  void didUpdateWidget(WeatherChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the input forecast changes, recalculate the chart data.
    if (widget.forecast != oldWidget.forecast ||
        widget.climateNormals != oldWidget.climateNormals) {
      _prepareChartData();
    }
  }

  /// Prepares all data needed for the charts.
  /// This is called once, preventing recalculation on every widget build.
  void _prepareChartData() {
    _chartData = [];
    _deviationChartData = [];

    for (int i = 0; i < widget.forecast.dailyForecasts.length; i++) {
      final forecast = widget.forecast.dailyForecasts[i];
      final normal = ClimateNormal.findByDayOfYear(
        widget.climateNormals,
        forecast.dayOfYear,
      );

      // --- IMPROVEMENT: Calculate individual deviations for labels ---
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
        // Store the calculated deviations
        maxTempDeviation: maxDeviation,
        minTempDeviation: minDeviation,
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
        // const SizedBox(height: 16),
        SizedBox(
          height: 400,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _showDeviations
                ? _buildDeviationChart()
                : _buildTemperatureChart(),
          ),
        ),
        // const SizedBox(height: 16),
        // _buildLegend(),
      ],
    );
  }

  Widget _buildTemperatureChart() {
    return SfCartesianChart(
      key: const ValueKey('temp_chart'), // Key for AnimatedSwitcher
      primaryXAxis: CategoryAxis(
        // title: AxisTitle(text: 'Date'),
        labelStyle: const TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
      primaryYAxis: NumericAxis(
        // title: AxisTitle(text: 'Température (°C)'),
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
        color: Colors.blueGrey,
        textStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      zoomPanBehavior: ZoomPanBehavior(
        enablePinching: true,
        enablePanning: true,
        enableDoubleTapZooming: true,
      ),
      series: <CartesianSeries>[
        // Actual temperatures
        LineSeries<_ChartData, String>(
          animationDuration: 100,
          dataSource: _chartData,
          xValueMapper: (_ChartData data, _) =>
          '${data.date.day}/${data.date.month}',
          yValueMapper: (_ChartData data, _) => data.maxTemp,
          name: 'Température maximum prévue',
          color: Colors.red,
          width: 3,
          markerSettings: const MarkerSettings(isVisible: true),
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            labelAlignment: ChartDataLabelAlignment.top,
            // --- IMPROVEMENT: Use a builder to create a two-line label ---
            builder: (data, point, series, pointIndex, seriesIndex) {
              final chartData = data as _ChartData;
              return _buildTempLabel(
                  chartData.maxTemp, chartData.maxTempDeviation);
            },
          ),
        ),
        LineSeries<_ChartData, String>(
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
            // --- IMPROVEMENT: Use a builder to create a two-line label ---
            builder: (data, point, series, pointIndex, seriesIndex) {
              final chartData = data as _ChartData;
              return _buildTempLabel(
                  chartData.minTemp, chartData.minTempDeviation);
            },
          ),
        ),
        // Climate normals
        LineSeries<_ChartData, String>(
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
        LineSeries<_ChartData, String>(
          animationDuration: 500, // Key for AnimatedSwitcher
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
    );
  }

  /// --- NEW HELPER WIDGET for creating the temperature + deviation label ---
  Widget _buildTempLabel(double temp, double? deviation) {
    // If no deviation data is available, just show the temperature.
    if (deviation == null) {
      return Text('${temp.round()}°',
          style: const TextStyle(
              color: Colors.black,
              fontSize: 11,
              fontWeight: FontWeight.bold));
    }

    // Format the deviation string with a '+' for positive values.
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
          " ${deviationText}",
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
          animationDuration: 100, // Key for AnimatedSwitcher

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
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _showDeviations
                ? _buildDeviationLegendContent()
                : _buildTemperatureLegendContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTemperatureLegendContent() {
    return Column(
      key: const ValueKey('temp_legend'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLegendItem(Colors.red, 'Température maximum prévue'),
        _buildLegendItem(Colors.blue, 'Température minimum prévue'),
        _buildLegendItem(
            Colors.red.withOpacity(0.5), 'Normale maximum (pointillés)'),
        _buildLegendItem(
            Colors.blue.withOpacity(0.5), 'Normale minimum (pointillés)'),
      ],
    );
  }

  Widget _buildDeviationLegendContent() {
    return Column(
      key: const ValueKey('dev_legend'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Écarts à la normale (couleurs):',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16.0,
          runSpacing: 8.0,
          children: [
            _buildDeviationLegendItem(Colors.red[700]!, '> +2°C'),
            _buildDeviationLegendItem(Colors.orange[600]!, '+1 à +2°C'),
            _buildDeviationLegendItem(Colors.orange[400]!, '+0.5 à +1°C'),
            _buildDeviationLegendItem(Colors.green[600]!, '-0.5 à +0.5°C'),
            _buildDeviationLegendItem(Colors.blue[400]!, '-1 à -0.5°C'),
            _buildDeviationLegendItem(Colors.blue[600]!, '-2 à -1°C'),
            _buildDeviationLegendItem(Colors.blue[800]!, '< -2°C'),
          ],
        ),
      ],
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
            color: color,
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 13)),
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
        Text(label, style: const TextStyle(fontSize: 12)),
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