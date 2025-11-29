import 'package:flutter/material.dart';
import '../../config/app_router.dart';
import '../../constants/routes.dart';
import '../../constants/colors.dart';
import '../../constants/app_constants.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with TickerProviderStateMixin {
  late AnimationController _illustrationController;
  late AnimationController _formController;
  
  late Animation<double> _illustrationAnimation;
  late Animation<double> _formAnimation;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    _illustrationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _formController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _illustrationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _illustrationController,
      curve: Curves.elasticOut,
    ));
    
    _formAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: Curves.easeInOut,
    ));
    
    // Start animations
    _illustrationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _formController.forward();
      }
    });
  }

  @override
  void dispose() {
    _illustrationController.dispose();
    _formController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    // Check if phone starts with + and has exactly 10 digits after +
    return RegExp(r'^\+\d{10}$').hasMatch(phone);
  }

  bool _isValidPassword(String password) {
    return password.length >= 6;
  }

  void _handleSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Validate inputs
    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Please fill in all fields');
      return;
    }

    if (!_isValidEmail(email) && !_isValidPhone(email)) {
      _showSnackBar('Please enter a valid email or phone number (+1234567890)');
      return;
    }

    if (!_isValidPassword(password)) {
      _showSnackBar('Password must be at least 6 characters');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API call delay
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });

    // Navigate to home screen
    AppRouter.pushReplacementNamed(context, AppRoutes.home);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
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
    final titleFontSize = isLargeScreen ? 28.0 : (isTablet ? 26.0 : 24.0);
    final labelFontSize = isTablet ? 16.0 : 14.0;
    final inputFontSize = isTablet ? 16.0 : 14.0;
    final buttonHeight = isTablet ? 60.0 : 56.0;
    
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      AppRouter.pushReplacementNamed(context, AppRoutes.welcome);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD93211),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Main content area
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Column(
                    children: [
                      // Illustration Section
                      SizedBox(
                        height: isTablet ? screenHeight * 0.25 : screenHeight * 0.2,
                        child: AnimatedBuilder(
                          animation: _illustrationAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _illustrationAnimation.value,
                              child: _buildIllustration(),
                            );
                          },
                        ),
                      ),
                      
                      SizedBox(height: isTablet ? 40.0 : 30.0),
                      
                      // Form Section
                      AnimatedBuilder(
                        animation: _formAnimation,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _formAnimation.value,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Sign In Label
                                Text(
                                  'SIGN IN',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                
                                SizedBox(height: 8),
                                
                                // Welcome Back Title
                                Text(
                                  'Great to See You!',
                                  style: TextStyle(
                                    fontSize: titleFontSize,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                    height: 1.2,
                                  ),
                                ),
                                
                                SizedBox(height: 12),
                                
                                // Description
                                Text(
                                  'We are excited to see you again! Please enter your email/phone number and Password to sign in:',
                                  style: TextStyle(
                                    fontSize: isTablet ? 16.0 : 14.0,
                                    color: AppColors.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                                
                                SizedBox(height: isTablet ? 40.0 : 32.0),
                                
                                // Email Field
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        text: 'Email Address ',
                                        style: TextStyle(
                                          fontSize: labelFontSize,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: '*',
                                            style: TextStyle(
                                              color: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    TextFormField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      style: TextStyle(fontSize: inputFontSize),
                                      decoration: InputDecoration(
                                        hintText: 'Email Address',
                                        hintStyle: TextStyle(
                                          color: AppColors.textSecondary.withOpacity(0.6),
                                          fontSize: inputFontSize,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                            color: AppColors.border,
                                            width: 1,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                            color: AppColors.primary,
                                            width: 2,
                                          ),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: isTablet ? 16 : 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                
                                SizedBox(height: isTablet ? 24.0 : 20.0),
                                
                                // Password Field
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        text: 'Password ',
                                        style: TextStyle(
                                          fontSize: labelFontSize,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: '*',
                                            style: TextStyle(
                                              color: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: !_isPasswordVisible,
                                      style: TextStyle(fontSize: inputFontSize),
                                      decoration: InputDecoration(
                                        hintText: 'Password',
                                        hintStyle: TextStyle(
                                          color: AppColors.textSecondary.withOpacity(0.6),
                                          fontSize: inputFontSize,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                            color: AppColors.border,
                                            width: 1,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                            color: AppColors.primary,
                                            width: 2,
                                          ),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: isTablet ? 16 : 12,
                                        ),
                                        suffixIcon: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _isPasswordVisible = !_isPasswordVisible;
                                            });
                                          },
                                          child: Icon(
                                            _isPasswordVisible
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            color: AppColors.textSecondary,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                
                                SizedBox(height: isTablet ? 40.0 : 32.0),
                                
                                // Sign In Button
                                SizedBox(
                                  width: double.infinity,
                                  height: buttonHeight,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _handleSignIn,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: AppColors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: _isLoading
                                        ? SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                AppColors.white,
                                              ),
                                            ),
                                          )
                                        : Text(
                                            'Sign in',
                                            style: TextStyle(
                                              fontSize: isTablet ? 18.0 : 16.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                  ),
                                ),
                                
                                SizedBox(height: isTablet ? 30.0 : 24.0),
                                
                                // Register Link
                                Center(
                                  child: GestureDetector(
                                    onTap: () {
                                      AppRouter.pushNamed(context, AppRoutes.signup);
                                    },
                                    child: RichText(
                                      text: TextSpan(
                                        text: 'You have no account? ',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: isTablet ? 16.0 : 14.0,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: 'Sign up',
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
                                ),
                              ],
                            ),
                          );
                        },
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
                animation: _formAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _formAnimation.value,
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

  Widget _buildIllustration() {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: ClipOval(
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Image.asset(
              'asset/images/login.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.login,
                      size: 80,
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

