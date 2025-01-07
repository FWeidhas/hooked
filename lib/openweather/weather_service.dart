import 'dart:convert';
import 'package:hooked/models/daily_weather.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class WeatherService {
  final String apiKey;
  final String baseUrl = 'https://api.openweathermap.org/data/2.5/forecast';

  // Constructor accepting the API key
  const WeatherService(this.apiKey);

  // Method to fetch the weather forecast
  Future<Map<String, List<DailyWeather>>> getWeatherForecast(
      double lat, double lon) async {
    try {
      // Sending a GET request to the weather API with the provided latitude and longitude
      final response = await http.get(Uri.parse(
          '$baseUrl?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=en'));

      if (response.statusCode == 200) {
        // Parsing the JSON response
        final data = json.decode(response.body);
        Map<String, List<DailyWeather>> forecastByDay = {};

        // Looping through the list of forecast data
        for (var item in data['list']) {
          // Extracting the date and converting it from Unix timestamp
          var date = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
          var dateString = DateFormat('yyyy-MM-dd')
              .format(date); // Formatting the date to string

          // Filtering the forecast to only include 6 AM, 12 PM, and 6 PM
          if (date.hour == 6 || date.hour == 12 || date.hour == 18) {
            // If the date is not already in the forecast map, create an empty list
            if (!forecastByDay.containsKey(dateString)) {
              forecastByDay[dateString] = [];
            }

            // Adding a new DailyWeather object to the list for that date
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

          // Limiting the forecast to only 7 days of data
          if (forecastByDay.length >= 7) break;
        }

        // Returning the map containing the forecast grouped by day
        return forecastByDay;
      } else {
        // Throwing an exception if the API request fails
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      // Handling any errors that occur during the request
      throw Exception('Failed to load weather forecast: $e');
    }
  }
}
