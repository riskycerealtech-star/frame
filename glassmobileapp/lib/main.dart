import 'package:flutter/material.dart';
import 'config/app_router.dart';
import 'constants/routes.dart';
import 'config/theme_controller.dart';
import 'config/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeMode,
      builder: (context, mode, _) {
    return MaterialApp(
      title: 'Glass Root - Sunglass Marketplace',
      debugShowCheckedModeBanner: false,
          themeMode: mode,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.generateRoute,
        );
      },
    );
  }
}

// Removed old demo code - splash screen is now the entry point
