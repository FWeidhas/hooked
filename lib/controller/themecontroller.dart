import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ThemeController extends GetxController {
  // Use Rx<ThemeMode> to make the theme mode observable
  Rx<ThemeMode> _themeMode = ThemeMode.light.obs;

  ThemeMode get themeMode => _themeMode.value;
  set themeMode(ThemeMode mode) => _themeMode.value = mode;

  // Toggle theme mode
  void toggleTheme() {
    _themeMode.value = (_themeMode.value == ThemeMode.light)
        ? ThemeMode.dark
        : ThemeMode.light;
  }
}
