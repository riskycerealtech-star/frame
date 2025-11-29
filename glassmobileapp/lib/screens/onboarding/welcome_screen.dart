import 'package:flutter/material.dart';
import '../../config/app_router.dart';
import '../../constants/routes.dart';
import '../../constants/colors.dart';
import '../../constants/app_constants.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _illustrationController;
  late AnimationController _contentController;
  
  late Animation<double> _illustrationAnimation;
  late Animation<double> _contentAnimation;

  @override
  void initState() {
    super.initState();
    
    _illustrationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _illustrationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _illustrationController,
      curve: Curves.elasticOut,
    ));
    
    _contentAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeInOut,
    ));
    
    // Start animations
    _illustrationController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _contentController.forward();
      }
    });
  }

  @override
  void dispose() {
    _illustrationController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final isTablet = screenWidth > 600;
    final isLargeScreen = screenWidth > 900;
    
    // Responsive values
    final horizontalPadding = isTablet ? 48.0 : 24.0;
    final topSpacing = isTablet ? 20.0 : 15.0;
    final titleFontSize = isLargeScreen ? 32.0 : (isTablet ? 30.0 : 28.0);
    final descriptionFontSize = isLargeScreen ? 18.0 : (isTablet ? 17.0 : 16.0);
    final buttonHeight = isTablet ? 60.0 : 56.0;
    final imageSize = isLargeScreen ? 320.0 : (isTablet ? 300.0 : 280.0);
    
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Main content area
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Column(
                    children: [
                      SizedBox(height: topSpacing),
                      
                      // Network Illustration
                      SizedBox(
                        height: isTablet ? screenHeight * 0.4 : screenHeight * 0.35,
                        child: AnimatedBuilder(
                          animation: _illustrationAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _illustrationAnimation.value,
                              child: _buildNetworkIllustration(imageSize),
                            );
                          },
                        ),
                      ),
                      
                      // Content Section
                      Container(
                        padding: EdgeInsets.symmetric(vertical: isTablet ? 20.0 : 16.0),
                        child: AnimatedBuilder(
                          animation: _contentAnimation,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _contentAnimation.value,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Title
                                  Text(
                                    'Discover Your Perfect Shades',
                                    style: TextStyle(
                                      fontSize: titleFontSize,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                      height: 1.2,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  
                                  SizedBox(height: isTablet ? 20.0 : 16.0),
                                  
                                  // Description
                                  Text(
                                    'Your marketplace for buying and selling premium sunglasses. Connect with sellers, discover amazing deals, and find your perfect pair.',
                                    style: TextStyle(
                                      fontSize: descriptionFontSize,
                                      color: AppColors.textSecondary,
                                      height: 1.4,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  
                                  SizedBox(height: isTablet ? 50.0 : 40.0),
                                  
                                  // Get Started Button
                                  SizedBox(
                                    width: double.infinity,
                                    height: buttonHeight,
                                    child: ElevatedButton(
                                  onPressed: () {
                                    AppRouter.pushReplacementNamed(context, AppRoutes.signin);
                                  },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: AppColors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Publish Sunglass',
                                            style: TextStyle(
                                              fontSize: isTablet ? 18.0 : 16.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Icon(
                                            Icons.arrow_forward,
                                            size: isTablet ? 22.0 : 20.0,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  
                                  SizedBox(height: isTablet ? 30.0 : 24.0),
                                  
                                  // Login Link
                                  GestureDetector(
                                onTap: () {
                                  AppRouter.pushReplacementNamed(context, AppRoutes.signin);
                                },
                                    child: RichText(
                                      text: TextSpan(
                                        text: 'Already have an account? ',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: isTablet ? 16.0 : 14.0,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: 'Log In',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.w600,
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Fixed footer at bottom
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: AnimatedBuilder(
                animation: _contentAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _contentAnimation.value,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: isTablet ? 20.0 : 16.0),
                      child: Text(
                        AppConstants.versionText,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: isTablet ? 14.0 : 12.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkIllustration(double imageSize) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: ClipOval(
          child: Container(
            width: imageSize,
            height: imageSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Image.asset(
              'asset/images/welcome.webp',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.people,
                      size: imageSize * 0.3,
                      color: AppColors.primary,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

