import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import '../services/climate_data_service.dart';
import '../models/weather_forecast_model.dart';
import '../models/climate_normal_model.dart';
import '../widgets/weather_chart_widget.dart';
import '../widgets/weather_table_widget.dart';
import '../widgets/loading_indicator_widget.dart';
import '../widgets/error_display_widget.dart';

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
  String _selectedModel = 'best_match';
  WeatherForecast? _forecast;
  List<ClimateNormal> _climateNormals = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _showChart = false;

  final Map<String, String> _locations = {
    '00460_Berus': 'Berus',
    '04336_Saarbrücken-Ensheim': 'Saarbrücken-Ensheim',
  };

  final Map<String, String> _models = {
    'best_match': 'Best Match',
    'meteofrance_seamless': 'ARPEGE (Météo-France)',
    'icon_seamless': 'ICON/DWD',
    'gfs_seamless': 'GFS',
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
      
      // Charger les prévisions météo
      final coords = _locationCoordinates[_selectedLocation]!;
      final forecast = await _weatherService.getWeatherForecast(
        coords['lat']!,
        coords['lon']!,
        _selectedModel,
      );

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
          padding: const EdgeInsets.all(2.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildControlPanel(),
              const SizedBox(height: 24),
              if (_isLoading)
                const LoadingIndicator()
              else if (_errorMessage != null)
                ErrorDisplay(message: _errorMessage!)
              else if (_forecast != null)
                _buildWeatherDisplay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Paramètres',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Lieu:', style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedLocation,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: _locations.entries.map((entry) {
                          return DropdownMenuItem<String>(
                            value: entry.key,
                            child: Text(entry.value),
                          );
                        }).toList(),
                        onChanged: _onLocationChanged,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Modèle:', style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedModel,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: _models.entries.map((entry) {
                          return DropdownMenuItem<String>(
                            value: entry.key,
                            child: Text(entry.value),
                          );
                        }).toList(),
                        onChanged: _onModelChanged,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Affichage:', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(width: 16),
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
              ],
            ),
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
            Text(
              'Prévisions météo - ${_locations[_selectedLocation]}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Modèle: ${_models[_selectedModel]}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
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