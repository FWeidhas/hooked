import 'package:flutter/material.dart';
import 'util.dart';
import 'theme.dart';

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

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = createTextTheme(context, "Roboto", "Roboto");
    MaterialTheme theme = MaterialTheme(textTheme);

    return MaterialApp(
      theme: theme.light(),
      darkTheme: theme.dark(),
      themeMode: _themeMode,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Theme Switcher'),
          actions: [
            Row(
              children: [
                const Icon(Icons.light_mode),
                Switch(
                  value: _themeMode == ThemeMode.dark,
                  onChanged: (value) {
                    setState(() {
                      _themeMode = value ? ThemeMode.dark : ThemeMode.light;
                    });
                  },
                ),
                const Icon(Icons.dark_mode),
              ],
            ),
          ],
        ),
        body: const Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}


// Example usage:
// Container(
//   color: Theme.of(context).colorScheme.primary,
//   child: Text('Themed Container', style: Theme.of(context).textTheme.bodyLarge),
// );

