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
import 'pages/friend_request_page.dart';
import 'pages/create_trip_page.dart';
import 'pages/trips_list_page.dart';
import 'controller/themecontroller.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase erfolgreich initialisiert.");
  } catch (e) {
    print("Fehler bei der Firebase-Initialisierung: $e");
  }

  await dotenv.load(fileName: "assets/.env");

  Get.put(ThemeController());

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

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
          '/friends': (context) {
            final currentUser = FirebaseAuth.instance.currentUser;

            if (currentUser == null) {
              return Scaffold(
                appBar: AppBar(title: const Text('Freundesanfragen')),
                body: const Center(child: Text('Du bist nicht eingeloggt.')),
              );
            }

            return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Scaffold(
                    appBar: AppBar(title: const Text('Freundesanfragen')),
                    body: const Center(child: CircularProgressIndicator()),
                  );
                }

                if (!snapshot.hasData || snapshot.data == null || !snapshot.data!.exists) {
                  return Scaffold(
                    appBar: AppBar(title: const Text('Freundesanfragen')),
                    body: const Center(child: Text('Keine Benutzerdaten gefunden.')),
                  );
                }

                final userDoc = snapshot.data!;
                final userData = userDoc.data() as Map<String, dynamic>;

                final friendRequests =
                    userData.containsKey('friendRequests')
                        ? List<String>.from(userData['friendRequests'] ?? [])
                        : <String>[];

                return FriendRequestsPage(friendRequests: friendRequests);
              },
            );
          },
          '/trips': (context) => CreateTripPage(),
          '/trips_list': (context) => const TripsListPage(),
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