import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'util.dart';
import 'theme.dart';
import 'pages/home_page.dart';
import 'pages/map.dart';
import 'controller/themecontroller.dart'; // Import the theme controller

void main() {
  // Initialize GetX and ThemeController
  Get.put(
      ThemeController()); // This will make the ThemeController globally accessible

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current theme mode from the ThemeController
    ThemeController themeController = Get.find();

    TextTheme textTheme = createTextTheme(context, "Roboto", "Roboto");
    MaterialTheme theme = MaterialTheme(textTheme);

    return Obx(() {
      // Rebuild the MaterialApp whenever the theme changes
      return MaterialApp(
        theme: theme.light(),
        darkTheme: theme.dark(),
        themeMode:
            themeController.themeMode, // Bind theme mode to GetX controller
        initialRoute: '/',
        routes: {
          '/': (context) => const HomePage(),
          '/map': (context) => const Map(),
        },
      );
    });
  }
}
