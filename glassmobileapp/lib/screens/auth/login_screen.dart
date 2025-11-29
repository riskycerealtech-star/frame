import 'package:flutter/material.dart';
import '../../config/app_router.dart';
import '../../constants/routes.dart';
import '../../widgets/common/back_button_widget.dart';
import '../../constants/colors.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: Container(
          width: 40,
          height: 40,
          margin: EdgeInsets.only(left: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFD93211),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: BackButtonWidget(
              color: AppColors.white,
              size: 20,
              padding: EdgeInsets.zero,
            ),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.login,
              size: 100,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            const Text(
              'Login Screen',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                AppRouter.pushReplacementNamed(context, AppRoutes.home);
              },
              child: const Text('Go to Home'),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                AppRouter.pushNamed(context, AppRoutes.register);
              },
              child: const Text('Go to Register'),
            ),
          ],
        ),
      ),
    );
  }
}
