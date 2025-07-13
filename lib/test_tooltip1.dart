import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather Chart App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const WeatherChartPage(),
    );
  }
}

class WeatherChartPage extends StatefulWidget {
  const WeatherChartPage({super.key});

  @override
  State<WeatherChartPage> createState() => _WeatherChartPageState();
}

class _WeatherChartPageState extends State<WeatherChartPage> {
  late List<WeatherData> data;
  late TooltipBehavior _tooltip;

  @override
  void initState() {
    super.initState();
    data = getWeatherData();
    _tooltip = TooltipBehavior(
      enable: true,
      // Make the tooltip container transparent since we provide our own styled container
      color: Colors.transparent,
      elevation: 0,
      builder: (dynamic data, dynamic point, dynamic series, int pointIndex,
          int seriesIndex) {
        final weather = data as WeatherData;
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                weather.iconPath,
                width: 40,
                height: 40,
              ),
              const SizedBox(height: 8),
              Text(
                weather.day,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                '${weather.temperature.toStringAsFixed(1)}°C',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                weather.condition,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Temperature Chart'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.blue.shade100,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Max Daily Temperature',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap on any point to see weather details',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 300,
                          // --- MODIFICATION: Removed the Stack and LayoutBuilder ---
                          // We now use the chart's built-in 'annotations' feature.
                          child: SfCartesianChart(
                            primaryXAxis: const CategoryAxis(
                              labelStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            primaryYAxis: const NumericAxis(
                              minimum: 15,
                              maximum: 35,
                              interval: 5,
                              labelFormat: '{value}°C',
                              labelStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            tooltipBehavior: _tooltip,
                            plotAreaBorderWidth: 0,
                            // --- NEW: Use annotations to place icons on the chart ---
                            annotations: data.map((weather) {
                              return CartesianChartAnnotation(
                                // The widget to display as an annotation
                                widget: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 3,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(3),
                                    child: SvgPicture.asset(weather.iconPath),
                                  ),
                                ),
                                // The data coordinate to place the widget at
                                coordinateUnit: CoordinateUnit.point,
                                x: weather.day,
                                y: weather.temperature,
                              );
                            }).toList(),
                            series: <CartesianSeries<WeatherData, String>>[
                              LineSeries<WeatherData, String>(
                                dataSource: data,
                                xValueMapper: (WeatherData weather, _) =>
                                weather.day,
                                yValueMapper: (WeatherData weather, _) =>
                                weather.temperature,
                                name: 'Temperature',
                                color: Colors.orange.shade600,
                                width: 3,
                                // --- MODIFICATION: Hide the original marker ---
                                // The annotation now serves as the visual marker.
                                // The line series itself remains tappable for tooltips.
                                markerSettings:
                                const MarkerSettings(isVisible: false),
                                dataLabelSettings: DataLabelSettings(
                                  isVisible: true,
                                  labelAlignment: ChartDataLabelAlignment.top,
                                  // --- MODIFICATION: Use a builder for robust positioning ---
                                  builder: (dynamic data, dynamic point,
                                      dynamic series, int pointIndex, int seriesIndex) {
                                    // Add padding to lift the label above our 28px icon annotation.
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 30),
                                      child: Text(
                                        '${(data as WeatherData).temperature.toStringAsFixed(0)}°',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Week Overview',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: data.map((weather) {
                            return Column(
                              children: [
                                SvgPicture.asset(
                                  weather.iconPath,
                                  width: 30,
                                  height: 30,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  weather.day.substring(0, 3),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${weather.temperature.toInt()}°',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade700,
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<WeatherData> getWeatherData() {
    final List<WeatherData> weatherData = [
      WeatherData('Monday', 22.5, 'Partly Cloudy',
          'assets/google_weather_icons/v4/partly_cloudy_day.svg'),
      WeatherData('Tuesday', 28.3, 'Cloudy',
          'assets/google_weather_icons/v4/cloudy.svg'),
      WeatherData('Wednesday', 31.2, 'Sunny',
          'assets/google_weather_icons/v4/clear_day.svg'),
      WeatherData('Thursday', 26.8, 'Partly Cloudy',
          'assets/google_weather_icons/v4/partly_cloudy_day.svg'),
      WeatherData('Friday', 19.1, 'Rainy',
          'assets/google_weather_icons/v4/rain.svg'),
      WeatherData('Saturday', 24.7, 'Cloudy',
          'assets/google_weather_icons/v4/cloudy.svg'),
      WeatherData('Sunday', 29.4, 'Sunny',
          'assets/google_weather_icons/v4/clear_day.svg'),
    ];
    return weatherData;
  }
}

class WeatherData {
  WeatherData(this.day, this.temperature, this.condition, this.iconPath);

  final String day;
  final double temperature;
  final String condition;
  final String iconPath;
}