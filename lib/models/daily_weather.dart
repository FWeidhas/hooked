class DailyWeather {
  final DateTime date;
  final double tempDay;
  final double tempMin;
  final double tempMax;
  final String description;
  final String icon;
  final double windSpeed;
  final int humidity;

  DailyWeather({
    required this.date,
    required this.tempDay,
    required this.tempMin,
    required this.tempMax,
    required this.description,
    required this.icon,
    required this.windSpeed,
    required this.humidity,
  });

  factory DailyWeather.fromJson(Map<String, dynamic> json) {
    return DailyWeather(
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      tempDay: json['temp']['day'].toDouble(),
      tempMin: json['temp']['min'].toDouble(),
      tempMax: json['temp']['max'].toDouble(),
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
      windSpeed: json['speed'].toDouble(),
      humidity: json['humidity'],
    );
  }
}
