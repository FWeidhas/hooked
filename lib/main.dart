import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'util.dart';
import 'theme.dart';
import 'pages/home_page.dart';
import 'pages/map.dart';
import 'pages/fishing_spots.dart';
import 'controller/themecontroller.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Get.put(ThemeController());

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
        title: 'Hooked',
        theme: theme.light(),
        darkTheme: theme.dark(),
        debugShowCheckedModeBanner: false,
        themeMode:
            themeController.themeMode, // Bind theme mode to GetX controller
        initialRoute: '/',
        routes: {
          '/': (context) => const HomePage(),
          '/map': (context) => const Map(),
          '/fishing_spots': (context) => FishingSpots(),
        },
      );
    });
  }
}
