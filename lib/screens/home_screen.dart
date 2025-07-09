import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import '../services/climate_data_service.dart';
import '../models/weather_forecast_model.dart';
import '../models/climate_normal_model.dart';
import '../widgets/weather_chart_widget.dart';
import '../widgets/weather_table_widget.dart';
import '../widgets/loading_indicator_widget.dart';
import '../widgets/error_display_widget.dart';
import 'package:intl/intl.dart';
// ADD THIS IMPORT: Required for date formatting initialization.
import 'package:intl/date_symbol_data_local.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService _weatherService = WeatherService();
  final ClimateDataService _climateService = ClimateDataService();
  
  // String _selectedLocation = '00460_Berus';
  String _selectedLocation = '04336_Saarbrücken-Ensheim';
  String _selectedModel = 'ecmwf_ifs025';
  WeatherForecast? _forecast;
  List<ClimateNormal> _climateNormals = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _showChart = true;

  final Map<String, String> _locations = {
    '00460_Berus': 'Berus',
    '04336_Saarbrücken-Ensheim': 'Saarbrücken-Ensheim',
  };

  final Map<String, String> _models = {
    'ecmwf_ifs025': 'ECMWF IFS',
    'best_match': 'Best Match',
    'gfs_seamless': 'GFS',
    'meteofrance_seamless': 'ARPEGE',
    'icon_seamless': 'ICON/DWD',
  };

  final Map<String, Map<String, double>> _locationCoordinates = {
    '00460_Berus': {'lat': 49.2656, 'lon': 6.6942},
    '04336_Saarbrücken-Ensheim': {'lat': 49.21, 'lon': 7.11},
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Charger les normales climatiques
      final normals = await _climateService.loadClimateNormals(_selectedLocation);
      await initializeDateFormatting('fr_FR', null);

      // Charger les prévisions météo
      final coords = _locationCoordinates[_selectedLocation]!;
      final WeatherForecast forecast = await _weatherService.getWeatherForecast(
        latitude: coords['lat']!,
        longitude: coords['lon']!,
        model: _selectedModel,
        locationName: _locations[_selectedLocation]!,

      );
      //print("####CJG 566 forecast:\n${forecast.toString()}");

      setState(() {
        _climateNormals = normals;
        _forecast = forecast;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement des données: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _onLocationChanged(String? newLocation) {
    if (newLocation != null && newLocation != _selectedLocation) {
      setState(() {
        _selectedLocation = newLocation;
      });
      _loadData();
    }
  }

  void _onModelChanged(String? newModel) {
    if (newModel != null && newModel != _selectedModel) {
      setState(() {
        _selectedModel = newModel;
      });
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ClimaDéviation WebApp'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_isLoading)
                const LoadingIndicator()
              else if (_errorMessage != null)
                ErrorDisplay(message: _errorMessage!)
              else if (_forecast != null)
                _buildWeatherDisplay(),
              _buildControlPanel(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<String>(
                // Create segments by mapping over your _models map
                segments: _models.entries.map((entry) {
                  return ButtonSegment<String>(
                    value: entry.key,
                    label: Text(entry.value),
                  );
                }).toList(),
                // The button's state is driven by your _selectedModel variable
                selected: {_selectedModel},
                // When a new model is selected, call your existing update logic
                onSelectionChanged: (Set<String> newSelection) {
                  // The _onModelChanged method already handles setState and data loading
                  _onModelChanged(newSelection.first);
                },
              ),
            ),

            const Text(
              'Paramètres',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Location Dropdown
            const Text('Lieu:', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedLocation,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
              ),
              items: _locations.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: _onLocationChanged,
            ),
            const SizedBox(height: 16),
            // Display Toggle (Chart/Table)
            const Text(
                'Affichage:', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment<bool>(
                  value: true,
                  label: Text('Graphique'),
                  icon: Icon(Icons.bar_chart),
                ),
                ButtonSegment<bool>(
                  value: false,
                  label: Text('Tableau'),
                  icon: Icon(Icons.table_chart),
                ),
              ],
              selected: {_showChart},
              onSelectionChanged: (Set<bool> selection) {
                setState(() {
                  _showChart = selection.first;
                });
              },
            ),
            const SizedBox(height: 16),
            // --- NEW: Model Selection SegmentedButton ---
            const Text(
                'Modèle:', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDisplay() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '${_locations[_selectedLocation]}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '  Modèle: ${_models[_selectedModel]}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            // const SizedBox(height: 16),
            if (_showChart)
              // Container()
              WeatherChart(
                forecast: _forecast!,
                climateNormals: _climateNormals,
              )
            else
              WeatherTable(
                forecast: _forecast!,
                climateNormals: _climateNormals,
              ),
          ],
        ),
      ),
    );
  }
}