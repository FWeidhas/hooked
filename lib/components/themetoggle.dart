import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/themecontroller.dart'; // Import the ThemeController

class ThemeToggleWidget extends StatelessWidget {
  const ThemeToggleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the ThemeController
    ThemeController themeController = Get.find();

    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.light_mode),
          onPressed: () {
            themeController.toggleTheme(); // Toggle the theme (light mode)
          },
        ),
        Obx(() {
          return Switch(
            value: themeController.themeMode ==
                ThemeMode.dark, // Check if dark mode is active
            onChanged: (value) {
              themeController
                  .toggleTheme(); // Call toggleTheme when the switch is toggled
            },
          );
        }),
        IconButton(
          icon: const Icon(Icons.dark_mode),
          onPressed: () {
            themeController.toggleTheme(); // Toggle the theme (dark mode)
          },
        ),
      ],
    );
  }
}
