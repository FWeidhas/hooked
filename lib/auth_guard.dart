import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooked/pages/login.dart';

class AuthGuard extends StatelessWidget {
  // The 'child' widget that is passed to this widget.
  // This is the widget that will be shown if the user is authenticated.
  final Widget child;

  const AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Get the current authenticated user using FirebaseAuth
    final user = FirebaseAuth.instance.currentUser;

    // If no user is logged in (i.e., the user is null), navigate to the LoginPage
    if (user == null) {
      return const LoginPage();
    }

    // If a user is logged in, show the child widget (the protected page)
    return child;
  }
}
