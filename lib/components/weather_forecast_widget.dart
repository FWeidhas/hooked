import 'package:flutter/material.dart';
import '../models/daily_weather.dart';
import 'package:intl/intl.dart';

class WeatherForecastWidget extends StatelessWidget {
  final Map<String, List<DailyWeather>> forecast;
  final String fishingSpotTitle;
  // Constructor that requires forecast data and fishing spot title
  const WeatherForecastWidget({
    super.key,
    required this.forecast,
    required this.fishingSpotTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title section for the weather forecast
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'This is the Weather forecast for the next 7 Days on "$fishingSpotTitle".',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
          ),
        ),
        // ListView to display the weather forecast for each day
        Expanded(
          child: ListView.builder(
            itemCount: forecast.length,
            itemBuilder: (context, index) {
              // Extracting the date and daily weather details
              String date = forecast.keys.elementAt(index);
              List<DailyWeather> dailyForecasts = forecast[date]!;

              // Creating a card for each day's forecast
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    expansionTileTheme: ExpansionTileThemeData(
                      backgroundColor: Colors.transparent,
                      collapsedBackgroundColor: Colors.transparent,
                    ),
                  ),
                  child: ExpansionTile(
                    // Displaying the formatted date as the title
                    title: Text(
                      DateFormat('EEEE, MMMM d')
                          .format(dailyForecasts.first.date),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    children: [
                      // Displaying the weather data for each time slot (6AM, 12PM, 6PM)
                      Container(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: dailyForecasts
                              .map(
                                  (weather) => _buildTimeSlot(context, weather))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Helper function to create a time slot card for each forecasted time
  Widget _buildTimeSlot(BuildContext context, DailyWeather weather) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Text(
              DateFormat('h a').format(weather.date),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Image.network(
              'https://openweathermap.org/img/wn/${weather.icon}@2x.png',
              height: 50,
              width: 50,
            ),
            Text('${weather.tempDay.round()}°C'),
            Text(
              weather.description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.water_drop, size: 14),
                Text('${weather.humidity}%'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.air, size: 14),
                Text('${weather.windSpeed} m/s'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
