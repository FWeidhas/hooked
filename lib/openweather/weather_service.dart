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
        final now = DateTime.now();

        // Track the current date we're processing
        String? currentDateString;
        List<DailyWeather> currentDayForecasts = [];

        for (var item in data['list']) {
          var date = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
          var dateString = DateFormat('yyyy-MM-dd').format(date);

          // Skip past dates
          if (date.isBefore(now) && !DateUtils.isSameDay(date, now)) {
            continue;
          }

          // If we're starting a new day
          if (currentDateString != dateString) {
            // Save the previous day's forecasts if we have any
            if (currentDateString != null && currentDayForecasts.isNotEmpty) {
              forecastByDay[currentDateString] = _selectThreeForecasts(
                currentDayForecasts, 
                isToday: DateUtils.isSameDay(currentDayForecasts[0].date, now)
              );
            }

            // Reset for the new day
            currentDateString = dateString;
            currentDayForecasts = [];
          }

          // Add forecast for this time slot
          currentDayForecasts.add(DailyWeather(
            date: date,
            tempDay: item['main']['temp'].toDouble(),
            tempMin: item['main']['temp_min'].toDouble(),
            tempMax: item['main']['temp_max'].toDouble(),
            description: item['weather'][0]['description'],
            icon: item['weather'][0]['icon'],
            windSpeed: item['wind']['speed'].toDouble(),
            humidity: item['main']['humidity'],
          ));

          // If we've collected 7 days worth of forecasts, break
          if (forecastByDay.length >= 6 && currentDateString != dateString) {
            break;
          }
        }

        // Don't forget to add the last day's forecasts
        if (currentDateString != null && currentDayForecasts.isNotEmpty) {
          forecastByDay[currentDateString] = _selectThreeForecasts(
            currentDayForecasts,
            isToday: DateUtils.isSameDay(currentDayForecasts[0].date, now)
          );
        }

        return forecastByDay;
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load weather forecast: $e');
    }
  }

  List<DailyWeather> _selectThreeForecasts(List<DailyWeather> forecasts, {required bool isToday}) {
    if (forecasts.isEmpty) return [];

    // Sort forecasts by time
    forecasts.sort((a, b) => a.date.compareTo(b.date));

    // If we have 3 or fewer forecasts, return them all
    if (forecasts.length <= 3) return forecasts;

    final now = DateTime.now();
    
    // Special handling for today
    if (isToday) {
      return _handleTodayForecasts(forecasts, now);
    }
    
    // For future days, try to get morning (6 AM), afternoon (12 PM), and evening (6 PM)
    return _getPreferredTimeSlots(forecasts);
  }

  List<DailyWeather> _handleTodayForecasts(List<DailyWeather> forecasts, DateTime now) {
    // Define target hours
    final targetHours = [6, 12, 18];
    List<DailyWeather> selectedForecasts = [];
    
    // If it's before 6 AM, try to get all three standard time slots
    if (now.hour < 6) {
      return _getPreferredTimeSlots(forecasts);
    }
    
    // If it's between 6 AM and 12 PM
    else if (now.hour < 12) {
      // Get the next available forecast
      int nextIndex = forecasts.indexWhere((f) => f.date.isAfter(now));
      if (nextIndex != -1) {
        selectedForecasts.add(forecasts[nextIndex]);
        
        // Try to get 12 PM and 6 PM slots
        var noonForecast = _findClosestToHour(forecasts.sublist(nextIndex + 1), 12);
        var eveningForecast = _findClosestToHour(forecasts.sublist(nextIndex + 1), 18);
        
        if (noonForecast != null) selectedForecasts.add(noonForecast);
        if (eveningForecast != null) selectedForecasts.add(eveningForecast);
      }
    }
    
    // If it's past 12 PM
    else {
      // Get the next available forecast
      int nextIndex = forecasts.indexWhere((f) => f.date.isAfter(now));
      if (nextIndex != -1) {
        // Add the next available forecast
        selectedForecasts.add(forecasts[nextIndex]);
        
        // Add two more forecasts spaced 2 hours apart
        for (int i = 0; i < 2; i++) {
          var targetTime = forecasts[nextIndex].date.add(Duration(hours: 2 * (i + 1)));
          var nextForecast = _findClosestToTime(
            forecasts.sublist(nextIndex + 1), 
            targetTime
          );
          if (nextForecast != null) {
            selectedForecasts.add(nextForecast);
          }
        }
      }
    }

    // If we couldn't get enough forecasts with the preferred method,
    // fall back to taking the next available ones
    while (selectedForecasts.length < 3 && forecasts.isNotEmpty) {
      var nextForecast = forecasts.firstWhere(
        (f) => !selectedForecasts.contains(f) && f.date.isAfter(now),
        orElse: () => forecasts.last
      );
      if (!selectedForecasts.contains(nextForecast)) {
        selectedForecasts.add(nextForecast);
      } else {
        break;
      }
    }

    return selectedForecasts;
  }

  List<DailyWeather> _getPreferredTimeSlots(List<DailyWeather> forecasts) {
    List<DailyWeather> selectedForecasts = [];
    final targetHours = [6, 12, 18];
    
    for (int targetHour in targetHours) {
      DailyWeather? closest = _findClosestToHour(forecasts, targetHour);
      if (closest != null && !selectedForecasts.contains(closest)) {
        selectedForecasts.add(closest);
      }
    }

    // If we couldn't get exactly 3 forecasts based on preferred hours,
    // just take the first 3 available ones
    if (selectedForecasts.length < 3) {
      return forecasts.take(3).toList();
    }

    return selectedForecasts;
  }

  DailyWeather? _findClosestToHour(List<DailyWeather> forecasts, int targetHour) {
    DailyWeather? closest;
    int minDiff = 24;

    for (var forecast in forecasts) {
      int diff = (forecast.date.hour - targetHour).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closest = forecast;
      }
    }

    return closest;
  }

  DailyWeather? _findClosestToTime(List<DailyWeather> forecasts, DateTime targetTime) {
    if (forecasts.isEmpty) return null;
    
    return forecasts.reduce((a, b) {
      var aDiff = a.date.difference(targetTime).abs();
      var bDiff = b.date.difference(targetTime).abs();
      return aDiff < bDiff ? a : b;
    });
  }
}

class DateUtils {
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}