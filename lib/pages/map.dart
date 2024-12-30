import 'package:flutter/material.dart';
import '../drawer.dart';
import '../components/themetoggle.dart';

class Map extends StatelessWidget {
  const Map({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the primary color from the theme
    Color primaryColor = Theme.of(context).colorScheme.primaryContainer;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Page'),
        backgroundColor: primaryColor,
        actions: const [
          ThemeToggleWidget(),
        ],
      ),
      drawer: const CustomDrawer(),
      body: Center(
        child: Text('Welcome to the Map Page!',
            style: Theme.of(context).textTheme.headlineMedium),
      ),
    );
  }
}
