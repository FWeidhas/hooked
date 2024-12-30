import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../drawer.dart';
import '../controller/themecontroller.dart'; // Import ThemeController

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the ThemeController instance using Get.find()
    ThemeController themeController = Get.find();

    // Access the primary color from the theme
    Color primaryColor = Theme.of(context).colorScheme.primaryContainer;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        backgroundColor:
            primaryColor, // Set the AppBar background color to primary
        actions: [
          // Switch widget to toggle between light and dark mode
          IconButton(
            icon: const Icon(Icons.light_mode),
            onPressed: () {
              themeController
                  .toggleTheme(); // Toggle theme using GetX controller
            },
          ),
          Switch(
            value: themeController.themeMode ==
                ThemeMode.dark, // Check the current theme mode
            onChanged: (value) {
              themeController
                  .toggleTheme(); // Call toggleTheme when the switch is toggled
            },
          ),
          IconButton(
            icon: const Icon(Icons.dark_mode),
            onPressed: () {
              themeController
                  .toggleTheme(); // Toggle theme using GetX controller
            },
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: const Center(
        child: Text('Welcome to the Home Page!'),
      ),
    );
  }
}
