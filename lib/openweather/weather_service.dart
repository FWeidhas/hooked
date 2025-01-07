import 'dart:convert';
import 'package:hooked/models/daily_weather.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class WeatherService {
  final String apiKey;
  final String baseUrl = 'https://api.openweathermap.org/data/2.5/forecast';

  const WeatherService(this.apiKey);

  Future<Map<String, List<DailyWeather>>> getWeatherForecast(
      double lat, double lon) async {
    try {
      final response = await http.get(Uri.parse(
          '$baseUrl?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=en'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        Map<String, List<DailyWeather>> forecastByDay = {};
        for (var item in data['list']) {
          var date = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
          var dateString = DateFormat('yyyy-MM-dd').format(date);

          if (date.hour == 6 || date.hour == 12 || date.hour == 18) {
            if (!forecastByDay.containsKey(dateString)) {
              forecastByDay[dateString] = [];
            }

            forecastByDay[dateString]!.add(DailyWeather(
              date: date,
              tempDay: item['main']['temp'].toDouble(),
              tempMin: item['main']['temp_min'].toDouble(),
              tempMax: item['main']['temp_max'].toDouble(),
              description: item['weather'][0]['description'],
              icon: item['weather'][0]['icon'],
              windSpeed: item['wind']['speed'].toDouble(),
              humidity: item['main']['humidity'],
            ));
          }

          // Limit to 7 days
          if (forecastByDay.length >= 7) break;
        }

        return forecastByDay;
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load weather forecast: $e');
    }
  }
}
