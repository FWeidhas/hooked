import 'package:flutter/material.dart';
import '../drawer.dart';

class Map extends StatelessWidget {
  final VoidCallback toggleTheme; // Function to toggle theme
  final ThemeMode currentThemeMode; // Current theme mode

  const Map({
    super.key,
    required this.toggleTheme,
    required this.currentThemeMode,
  });

  @override
  Widget build(BuildContext context) {
    // Access the primary color from the theme
    Color primaryColor = Theme.of(context).colorScheme.primaryContainer;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Page'),
        backgroundColor:
            primaryColor, // Set the AppBar background color to primary
        actions: [
          // Add the Light/Dark mode switch here
          IconButton(
            icon: const Icon(Icons.light_mode),
            onPressed: () {
              toggleTheme(); // Trigger theme toggle (light mode)
            },
          ),
          Switch(
            value: currentThemeMode ==
                ThemeMode.dark, // Set switch based on current theme
            onChanged: (value) {
              toggleTheme(); // Call toggleTheme when the switch is toggled
            },
          ),
          IconButton(
            icon: const Icon(Icons.dark_mode),
            onPressed: () {
              toggleTheme(); // Trigger theme toggle (dark mode)
            },
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: const Center(
        child: Text('Welcome to the Map Page!'),
      ),
    );
  }
}
