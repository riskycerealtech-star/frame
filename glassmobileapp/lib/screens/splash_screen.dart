import 'package:flutter/material.dart';
import 'dart:async';
import '../config/app_router.dart';
import '../constants/routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    // Navigate to next screen after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        // Navigate to public products screen after splash
        AppRouter.pushReplacementNamed(context, AppRoutes.publishProducts);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Center(
        child: Container(
          width: isTablet ? 220.0 : 180.0,
          height: isTablet ? 220.0 : 180.0,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 25,
                spreadRadius: 5,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16.0),
          child: Image.asset(
            'asset/images/officiallogo.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }
}