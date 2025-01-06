import 'package:flutter/material.dart';
import 'package:hooked/components/themetoggle.dart';
import 'package:hooked/openweather/weather_service.dart';
import '../models/daily_weather.dart';
import '../models/weather_forecast_widget.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FishingSpotWeatherScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String title;

  const FishingSpotWeatherScreen({
    Key? key,
    required this.title,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  _FishingSpotWeatherScreenState createState() =>
      _FishingSpotWeatherScreenState();
}

class _FishingSpotWeatherScreenState extends State<FishingSpotWeatherScreen> {
  final weatherService = WeatherService(dotenv.env['OPEN_WEATHER_API_KEY']!);
  Map<String, List<DailyWeather>>? forecast;

  @override
  void initState() {
    super.initState();
    _loadWeatherData();
  }

  Future<void> _loadWeatherData() async {
    try {
      final weatherForecast = await weatherService.getWeatherForecast(
        widget.latitude,
        widget.longitude,
      );
      if (mounted) {
        setState(() {
          forecast = weatherForecast;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading weather data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).colorScheme.primaryContainer;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Forecast'),
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadWeatherData,
          ),
          ThemeToggleWidget(),
        ],
      ),
      body: SafeArea(
        child: forecast == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading weather data...'),
                  ],
                ),
              )
            : WeatherForecastWidget(
                forecast: forecast!,
                fishingSpotTitle: widget.title,
              ),
      ),
    );
  }
}
