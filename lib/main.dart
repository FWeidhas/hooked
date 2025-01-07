import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hooked/auth_check.dart';
import 'package:hooked/auth_guard.dart';
import 'package:hooked/pages/fishing_spot_weather_screen.dart';
import 'package:hooked/pages/login.dart';
import 'package:hooked/pages/registration.dart';
import 'firebase_options.dart';
import 'util.dart';
import 'theme.dart';
import 'pages/map.dart';
import 'pages/fishing_spots.dart';
import 'pages/fish.dart';
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
        home: const AuthCheck(),
        routes: {
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegistrationPage(),
          '/map': (context) => const AuthGuard(child: FishingMap()),
          '/fishing_spots': (context) => AuthGuard(child: FishingSpots()),
          '/fishes': (context) => AuthGuard(child: FishPage()),
          '/weather': (context) {
            final args = ModalRoute.of(context)!.settings.arguments
                as Map<String, dynamic>;
            return FishingSpotWeatherScreen(
              latitude: args['latitude'],
              longitude: args['longitude'],
              title: args['title'],
            );
          },
        },
      );
    });
  }
}
