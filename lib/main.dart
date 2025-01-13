// main.dart
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
import 'pages/create_trip_page.dart';
import 'pages/trips_list_page.dart';
import 'controller/themecontroller.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooked/pages/friend_page.dart';
import 'package:hooked/pages/add_friend_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase successfully initialized.");
  } catch (e) {
    print("Error initializing Firebase: $e");
  }

  await dotenv.load(fileName: "assets/.env");

  Get.put(ThemeController());

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeController themeController = Get.find();

    TextTheme textTheme = createTextTheme(context, "Roboto", "Roboto");
    MaterialTheme theme = MaterialTheme(textTheme);

    return Obx(() {
      return MaterialApp(
        title: 'Hooked',
        theme: theme.light(),
        darkTheme: theme.dark(),
        debugShowCheckedModeBanner: false,
        themeMode: themeController.themeMode,
        home: const AuthCheck(),
        routes: {
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegistrationPage(),
          '/map': (context) => const AuthGuard(child: FishingMap()),
          '/fishing_spots': (context) => AuthGuard(child: FishingSpots()),
          '/fish': (context) => AuthGuard(child: FishPage()),
          '/trips': (context) => CreateTripPage(),
          '/trips_list': (context) => const TripsListPage(),
          '/friends': (context) => const AuthGuard(child: FriendsPage()),
          '/add_friend': (context) => const AuthGuard(child: AddFriendPage()),
          '/weather': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
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
