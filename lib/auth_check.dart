import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooked/pages/fishing_spots.dart';
import '../pages/login.dart';

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    // Using a StreamBuilder to listen for changes in the user's authentication state
    return StreamBuilder<User?>(
      // The authStateChanges stream emits the authentication state of the current user
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Check the connection state of the Stream
        if (snapshot.connectionState == ConnectionState.active) {
          // If the user is authenticated (snapshot has data), navigate to the FishingSpots page
          if (snapshot.hasData) {
            return FishingSpots();
          }
          // If no user is authenticated (snapshot doesn't have data), show the LoginPage
          return const LoginPage();
        }
        // While waiting for the auth state to load, display a loading spinner
        return const CircularProgressIndicator();
      },
    );
  }
}
