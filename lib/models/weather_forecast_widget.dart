import 'package:flutter/material.dart';
import 'daily_weather.dart';
import 'package:intl/intl.dart';

class WeatherForecastWidget extends StatelessWidget {
  final Map<String, List<DailyWeather>> forecast;

  const WeatherForecastWidget({Key? key, required this.forecast})
      : super(key: key);

  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: forecast.length,
      itemBuilder: (context, index) {
        String date = forecast.keys.elementAt(index);
        List<DailyWeather> dailyForecasts = forecast[date]!;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ExpansionTile(
            title: Text(
              DateFormat('EEEE, MMMM d').format(dailyForecasts.first.date),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: dailyForecasts
                      .map((weather) => _buildTimeSlot(weather))
                      .toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeSlot(DailyWeather weather) {
    return Expanded(
      child: Container(
        color:
            Colors.blue.shade100, // Setze hier die gewünschte Hintergrundfarbe
        padding: const EdgeInsets.all(
            8), // Optional: Abstand innerhalb des Containers
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
