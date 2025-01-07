import 'package:flutter/material.dart';
import 'package:hooked/components/themetoggle.dart';
import 'package:hooked/openweather/weather_service.dart';
import '../models/daily_weather.dart';
import '../components/weather_forecast_widget.dart';
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
  // Instantiate the WeatherService with the API key from environment variables
  final weatherService = WeatherService(dotenv.env['OPEN_WEATHER_API_KEY']!);
  // Variable to store the fetched weather forecast
  Map<String, List<DailyWeather>>? forecast;

  @override
  void initState() {
    super.initState();
    // Load the weather data when the widget is initialized
    _loadWeatherData();
  }

  // Function to fetch weather data from the weather service
  Future<void> _loadWeatherData() async {
    try {
      // Fetch weather data using latitude and longitude from widget
      final weatherForecast = await weatherService.getWeatherForecast(
        widget.latitude,
        widget.longitude,
      );
      // If widget is still mounted, update the forecast state with the fetched data
      if (mounted) {
        setState(() {
          forecast = weatherForecast;
        });
      }
    } catch (e) {
      // If there is an error, show a snack bar with the error message
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
          // Button to manually refresh the weather data
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
                // Pass the fetched weather forecast to the WeatherForecastWidget
                forecast: forecast!,
                fishingSpotTitle:
                    widget.title, // Pass the title of the fishing spot
              ),
      ),
    );
  }
}
