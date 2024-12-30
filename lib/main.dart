import 'package:flutter/material.dart';
import 'util.dart';
import 'theme.dart';
import 'pages/home_page.dart';
import 'pages/map.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  // The current theme mode
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = createTextTheme(context, "Roboto", "Roboto");
    MaterialTheme theme = MaterialTheme(textTheme);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme.light(),
      darkTheme: theme.dark(),
      themeMode: _themeMode,
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(
              toggleTheme: _toggleTheme,
              currentThemeMode: _themeMode,
            ),
        '/map': (context) => Map(
              toggleTheme: _toggleTheme,
              currentThemeMode: _themeMode,
            ),
      },
    );
  }
}


// Example usage of colortheme and texttheme:
// Container(
//   color: Theme.of(context).colorScheme.primary,
//   child: Text('Themed Container', style: Theme.of(context).textTheme.bodyLarge),
// );

