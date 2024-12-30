import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import GetX
import '../drawer.dart';
import '../controller/themecontroller.dart'; // Import the ThemeController

class Map extends StatelessWidget {
  const Map({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the ThemeController instance using Get.find()
    ThemeController themeController = Get.find();

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
              themeController
                  .toggleTheme(); // Trigger theme toggle (light mode)
            },
          ),
          Obx(() {
            return Switch(
              value: themeController.themeMode ==
                  ThemeMode.dark, // Set switch based on current theme
              onChanged: (value) {
                themeController
                    .toggleTheme(); // Call toggleTheme when the switch is toggled
              },
            );
          }),
          IconButton(
            icon: const Icon(Icons.dark_mode),
            onPressed: () {
              themeController.toggleTheme(); // Trigger theme toggle (dark mode)
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
