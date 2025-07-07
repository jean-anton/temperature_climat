import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'data/weather_icon_data.dart';
import 'models/weather_icon.dart';

void main() {
  runApp(const WeatherIconApp());
}

class WeatherIconApp extends StatelessWidget {
  const WeatherIconApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather Icon Viewer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Using Material 3 provides a more modern look and feel
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const WeatherIconList(),
    );
  }
}

class WeatherIconList extends StatelessWidget {
  const WeatherIconList({super.key});

  @override
  Widget build(BuildContext context) {
    // Getting the theme data once for reuse is slightly more efficient.
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Icons'),
      ),
      body: ListView.builder(
        itemCount: weatherIcons.length,
        itemBuilder: (context, index) {
          final WeatherIcon weather = weatherIcons[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: SvgPicture.asset(
                weather.iconPath,
                width: 48,
                height: 48,
                placeholderBuilder: (context) =>
                const CircularProgressIndicator(),
              ),
              // By placing a Column in the title, we can group the text
              // while making it all selectable.
              title: Padding(
                // Add some padding for better spacing.
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Use SelectableText to allow copying.
                    SelectableText(
                      '${weather.descriptionEn} (${weather.descriptionFr})',
                      style: textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    SelectableText(
                      'Code: ${weather.code}\nPath: ${weather.iconPath}',
                      style: textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}