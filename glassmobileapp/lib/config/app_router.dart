import 'package:flutter/material.dart';
import '../constants/routes.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding/welcome_screen.dart';
import '../screens/onboarding/signin_screen.dart';
import '../screens/onboarding/signup_screen.dart';
import '../screens/onboarding/public_products_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/product/list_screen.dart';
import '../screens/products/product_details_screen.dart';
import '../screens/products/product_register_screen.dart';
import '../screens/product/create_screen.dart';
import '../screens/marketplace/browse_screen.dart';
import '../screens/orders/my_orders_screen.dart';
import '../screens/admin/dashboard_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );
        
      case AppRoutes.welcome:
        return MaterialPageRoute(
          builder: (_) => const WelcomeScreen(),
          settings: settings,
        );
        
      case AppRoutes.signin:
        return MaterialPageRoute(
          builder: (_) => const SignInScreen(),
          settings: settings,
        );
        
      case AppRoutes.signup:
        return MaterialPageRoute(
          builder: (_) => const SignUpScreen(),
          settings: settings,
        );
        
      case AppRoutes.publishProducts:
        return MaterialPageRoute(
          builder: (_) => const PublicProductsScreen(),
          settings: settings,
        );
        
      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
        
      case AppRoutes.register:
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
          settings: settings,
        );
        
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );
        
      case AppRoutes.profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
          settings: settings,
        );
        
      case AppRoutes.productList:
        return MaterialPageRoute(
          builder: (_) => const ProductListScreen(),
          settings: settings,
        );
        
      case AppRoutes.productDetails:
        final args = settings.arguments as Map<String, dynamic>?;
        final product = args?['product'] as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ProductDetailsScreen(product: product ?? {}),
          settings: settings,
        );
        
      case AppRoutes.productRegister:
        return MaterialPageRoute(
          builder: (_) => const ProductRegisterScreen(),
          settings: settings,
        );
        
      case AppRoutes.createProduct:
        return MaterialPageRoute(
          builder: (_) => const CreateProductScreen(),
          settings: settings,
        );
        
      case AppRoutes.marketplace:
        return MaterialPageRoute(
          builder: (_) => const BrowseScreen(),
          settings: settings,
        );
        
      case AppRoutes.orders:
        return MaterialPageRoute(
          builder: (_) => const MyOrdersScreen(),
          settings: settings,
        );
        
      case AppRoutes.adminDashboard:
        return MaterialPageRoute(
          builder: (_) => const AdminDashboardScreen(),
          settings: settings,
        );
        
      // Additional routes that might be needed
      case AppRoutes.search:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Search')),
            body: const Center(child: Text('Search functionality coming soon')),
          ),
          settings: settings,
        );
        
      case AppRoutes.favorites:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Favorites')),
            body: const Center(child: Text('Favorites functionality coming soon')),
          ),
          settings: settings,
        );
        
      case AppRoutes.orderDetails:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Order Details')),
            body: const Center(child: Text('Order details functionality coming soon')),
          ),
          settings: settings,
        );
        
      case AppRoutes.chat:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Chat')),
            body: const Center(child: Text('Chat functionality coming soon')),
          ),
          settings: settings,
        );
        
      case AppRoutes.editProduct:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Edit Product')),
            body: const Center(child: Text('Edit product functionality coming soon')),
          ),
          settings: settings,
        );
        
      // Admin routes
      case AppRoutes.adminUsers:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Admin Users')),
            body: const Center(child: Text('Admin users functionality coming soon')),
          ),
          settings: settings,
        );
        
      case AppRoutes.adminProducts:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Admin Products')),
            body: const Center(child: Text('Admin products functionality coming soon')),
          ),
          settings: settings,
        );
        
      case AppRoutes.adminOrders:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Admin Orders')),
            body: const Center(child: Text('Admin orders functionality coming soon')),
          ),
          settings: settings,
        );
        
      case AppRoutes.adminCommissions:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Admin Commissions')),
            body: const Center(child: Text('Admin commissions functionality coming soon')),
          ),
          settings: settings,
        );
        
      case AppRoutes.adminAnalytics:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Admin Analytics')),
            body: const Center(child: Text('Admin analytics functionality coming soon')),
          ),
          settings: settings,
        );
        
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Page not found',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'The requested page could not be found',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          settings: settings,
        );
    }
  }
  
  // Helper methods for navigation
  static void pushNamed(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }
  
  static void pushReplacementNamed(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }
  
  static void pushNamedAndRemoveUntil(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }
  
  static void pop(BuildContext context, [dynamic result]) {
    Navigator.pop(context, result);
  }
  
  static void popUntil(BuildContext context, String routeName) {
    Navigator.popUntil(context, ModalRoute.withName(routeName));
  }
}
