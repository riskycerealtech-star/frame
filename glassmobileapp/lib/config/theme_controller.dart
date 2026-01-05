import 'package:flutter/material.dart';

/// Global theme controller for simple light/dark/system theme toggling.
///
/// This keeps the implementation lightweight (no extra dependencies),
/// while allowing any screen to toggle the app theme.
/// All screens share the same controller instance for consistent theme state.
final ValueNotifier<ThemeMode> appThemeMode = ValueNotifier<ThemeMode>(ThemeMode.light);

/// Toggle between light, dark, and system theme modes.
/// Cycles through: light -> dark -> system -> light
void toggleAppThemeMode() {
  switch (appThemeMode.value) {
    case ThemeMode.light:
      appThemeMode.value = ThemeMode.dark;
      break;
    case ThemeMode.dark:
      appThemeMode.value = ThemeMode.system;
      break;
    case ThemeMode.system:
      appThemeMode.value = ThemeMode.light;
      break;
  }
}

/// Set theme mode directly
void setAppThemeMode(ThemeMode mode) {
  appThemeMode.value = mode;
}

/// Get current theme mode
ThemeMode getAppThemeMode() {
  return appThemeMode.value;
}

/// Check if current mode is dark (considering system preference)
bool isDarkMode(BuildContext context) {
  final mode = appThemeMode.value;
  if (mode == ThemeMode.system) {
    return MediaQuery.of(context).platformBrightness == Brightness.dark;
  }
  return mode == ThemeMode.dark;
}










