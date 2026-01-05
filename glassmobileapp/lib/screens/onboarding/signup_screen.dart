import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/app_router.dart';
import '../../constants/routes.dart';
import '../../constants/colors.dart';
import '../../constants/api_constants.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with TickerProviderStateMixin {
  late AnimationController _illustrationController;
  late AnimationController _formController;
  
  late Animation<double> _illustrationAnimation;
  late Animation<double> _formAnimation;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _rePasswordController = TextEditingController();
  
  String? _selectedGender;
  
  bool _isPasswordVisible = false;
  bool _isRePasswordVisible = false;
  bool _isLoading = false;
  
  // Dropdown options
  final List<String> _genderOptions = ['Male', 'Female', 'N/A'];

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
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _rePasswordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidName(String name) {
    return name.trim().length >= 2;
  }

  bool _isValidPhone(String phone) {
    // Check if phone starts with + and has at least 10 digits after +
    return RegExp(r'^\+\d{10,}$').hasMatch(phone);
  }

  bool _isValidPassword(String password) {
    return password.length >= 6;
  }

  void _handleSignUp() async {
    print('🔵 [SIGNUP] Signup button clicked');

    // Show field-level validation messages after first submit attempt
    setState(() {
      _autovalidateMode = AutovalidateMode.always;
    });

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      print('❌ [SIGNUP] Form validation failed');
      return;
    }
    
    final email = _emailController.text.trim();
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    // Kept for backend compatibility (backend expects a location field)
    const location = 'UNKNOWN';

    print('🔵 [SIGNUP] Form data collected:');
    print('   - Email: $email');
    print('   - First Name: $firstName');
    print('   - Last Name: $lastName');
    print('   - Phone: $phone');
    print('   - Gender: $_selectedGender');

    print('✅ [SIGNUP] All validations passed');
    print('🔄 [SIGNUP] Setting loading state to true');

    setState(() {
      _isLoading = true;
    });

    try {
      // Prepare request body
      final requestBody = {
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phone,
        'password': password,
        'gender': _selectedGender!,
        'location': location,
      };

      // Make API call
      final url = Uri.parse(ApiUrls.userSignup);
      
      print('🌐 [SIGNUP] Preparing API call...');
      print('   - URL: $url');
      print('   - Method: POST');
      print('   - Request Body: ${jsonEncode(requestBody)}');
      
      final requestStartTime = DateTime.now();
      print('⏱️  [SIGNUP] API call started at: ${requestStartTime.toIso8601String()}');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 30));

      final requestEndTime = DateTime.now();
      final duration = requestEndTime.difference(requestStartTime);
      
      print('⏱️  [SIGNUP] API call completed in: ${duration.inMilliseconds}ms');
      print('📥 [SIGNUP] Response received:');
      print('   - Status Code: ${response.statusCode}');
      print('   - Response Headers: ${response.headers}');
      print('   - Response Body: ${response.body}');

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        print('✅ [SIGNUP] Registration successful!');
        try {
          final responseData = jsonDecode(response.body);
          print('   - User ID: ${responseData['userId']}');
          print('   - Email: ${responseData['email']}');
          print('   - Status: ${responseData['status']}');
          print('   - Phone: ${responseData['phoneNumber']}');
          if (responseData['createdOn'] != null) {
            print('   - Created On: ${responseData['createdOn']}');
          }
          if (responseData['updatedOn'] != null) {
            print('   - Updated On: ${responseData['updatedOn']}');
          }
          
          // Verify data was saved to database
          print('');
          print('🗄️  [SIGNUP] Database Verification:');
          print('   ✅ User data saved to Google Cloud Database');
          print('   ✅ User ID: ${responseData['userId']}');
          print('   ✅ Email: ${responseData['email']} stored in database');
          print('   ✅ Phone: ${responseData['phoneNumber']} stored in database');
          print('   ✅ Timestamp: ${responseData['createdOn'] ?? 'N/A'}');
          print('');
          print('📊 [SIGNUP] Signup Summary:');
          print('   - First Name: $firstName');
          print('   - Last Name: $lastName');
          print('   - Email: $email');
          print('   - Phone: $phone');
          print('   - Gender: $_selectedGender');
          print('   ✅ All data successfully saved to database!');
          
        } catch (e) {
          print('⚠️  [SIGNUP] Could not parse response data: $e');
        }
        _showSnackBar('Registration successful! Data saved to database.', isError: false);
        // Navigate to sign in screen after successful registration
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            print('🔄 [SIGNUP] Navigating to sign in screen');
            AppRouter.pushReplacementNamed(context, AppRoutes.signin);
          }
        });
      } else {
        print('❌ [SIGNUP] Registration failed with status code: ${response.statusCode}');
        
        // Handle specific status codes
        String errorMessage = 'Registration failed. Please try again.';
        
        if (response.statusCode == 404) {
          errorMessage = 'API endpoint not found (404). The signup endpoint may not be deployed.';
          print('   - Error: 404 Not Found - The API endpoint does not exist');
          print('   - Endpoint: ${ApiUrls.userSignup}');
          print('   - Check if the API is deployed and the URL is correct');
          print('   - Try accessing: ${ApiConstants.currentBaseUrl}/docs to see available endpoints');
        } else if (response.statusCode == 400) {
          errorMessage = 'Invalid data. Please check your input.';
        } else if (response.statusCode == 409) {
          errorMessage = 'Email or phone number already exists.';
        } else if (response.statusCode == 500) {
          errorMessage = 'Server error. Please try again later.';
        }
        
        try {
          final errorData = jsonDecode(response.body);
          final detailMessage = errorData['detail'] ?? errorData['message'];
          if (detailMessage != null) {
            errorMessage = detailMessage.toString();
          }
          print('   - Error Detail: $errorMessage');
          print('   - Full Error Response: $errorData');
        } catch (e) {
          print('⚠️  [SIGNUP] Could not parse error response: $e');
          print('   - Raw Response: ${response.body}');
          if (response.statusCode == 404) {
            errorMessage = 'API endpoint not found (404).\nServer: ${ApiConstants.currentBaseUrl}\nEndpoint: ${ApiEndpoints.userSignup}\n\nPlease verify the API is deployed.';
          }
        }
        
        // Show error in snackbar (truncate if too long for mobile)
        final displayMessage = errorMessage.length > 100 
            ? '${errorMessage.substring(0, 100)}...' 
            : errorMessage;
        _showSnackBar(displayMessage);
        
        // Also print full error for debugging
        print('📱 [SIGNUP] Error message shown to user: $displayMessage');
      }
    } catch (e, stackTrace) {
      print('💥 [SIGNUP] Exception occurred:');
      print('   - Error Type: ${e.runtimeType}');
      print('   - Error Message: $e');
      print('   - Stack Trace: $stackTrace');
      
      setState(() {
        _isLoading = false;
      });
      
      if (e is http.ClientException) {
        print('❌ [SIGNUP] Network error: ${e.message}');
        _showSnackBar('Network error: ${e.message}. Check your internet connection.');
      } else if (e is FormatException) {
        print('❌ [SIGNUP] Format error: $e');
        _showSnackBar('Invalid response from server. Please try again.');
      } else if (e.toString().contains('SocketException') || e.toString().contains('Failed host lookup')) {
        print('❌ [SIGNUP] Connection error: $e');
        _showSnackBar('Cannot connect to server. Check your internet connection and API URL.');
      } else if (e.toString().contains('TimeoutException') || e.toString().contains('timeout')) {
        print('❌ [SIGNUP] Timeout error: $e');
        _showSnackBar('Request timed out. Please try again.');
      } else {
        print('❌ [SIGNUP] Unknown error: $e');
        _showSnackBar('An error occurred: ${e.toString()}');
      }
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
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
      appBar: AppBar(
        backgroundColor: AppColors.primary, // mainColorApp (black)
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 8,
        leading: IconButton(
          onPressed: () => AppRouter.pop(context),
          icon: const Icon(Icons.arrow_back),
                      ),
        title: const Text(
          'Sign Up',
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'Times New Roman',
                      ),
                    ),
                  ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Main content area
            Expanded(
              child: SingleChildScrollView(
                  child: Column(
                    children: [
                    // Illustration Section (full-width, attached to background)
                      SizedBox(
                      width: double.infinity,
                      height: isTablet ? screenHeight * 0.22 : screenHeight * 0.18,
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
                      
                      SizedBox(height: isTablet ? 30.0 : 20.0),
                      
                    // Form Section (padded)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: AnimatedBuilder(
                        animation: _formAnimation,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _formAnimation.value,
                            child: Form(
                              key: _formKey,
                              autovalidateMode: _autovalidateMode,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Sign Up Label
                                Text(
                                  'SIGN UP',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                
                                SizedBox(height: 8),
                                
                                // Welcome Title
                                Text(
                                  'Create Your Account',
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
                                  'Please fill in your information to create your account:',
                                  style: TextStyle(
                                    fontSize: isTablet ? 16.0 : 14.0,
                                    color: AppColors.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                                
                                SizedBox(height: isTablet ? 32.0 : 24.0),
                                
                                // First NAME
                                _buildTextField(
                                  controller: _firstNameController,
                                  label: 'First NAME',
                                  hintText: 'First name',
                                  labelFontSize: labelFontSize,
                                  inputFontSize: inputFontSize,
                                  isTablet: isTablet,
                                  validator: (value) {
                                    final v = (value ?? '').trim();
                                    if (v.isEmpty) return 'First name is required';
                                    if (!_isValidName(v)) return 'First name must be at least 2 characters';
                                    return null;
                                  },
                                ),
                                
                                SizedBox(height: isTablet ? 20.0 : 16.0),
                                
                                // Last Name
                                _buildTextField(
                                  controller: _lastNameController,
                                  label: 'Last Name',
                                  hintText: 'Last name',
                                  labelFontSize: labelFontSize,
                                  inputFontSize: inputFontSize,
                                  isTablet: isTablet,
                                  validator: (value) {
                                    final v = (value ?? '').trim();
                                    if (v.isEmpty) return 'Last name is required';
                                    if (!_isValidName(v)) return 'Last name must be at least 2 characters';
                                    return null;
                                  },
                                ),
                                
                                SizedBox(height: isTablet ? 20.0 : 16.0),
                                
                                // Gender
                                _buildDropdownField(
                                  label: 'Gender',
                                  value: _selectedGender,
                                  items: _genderOptions,
                                  onChanged: (String? value) {
                                    setState(() {
                                      _selectedGender = value;
                                    });
                                  },
                                  labelFontSize: labelFontSize,
                                  inputFontSize: inputFontSize,
                                  isTablet: isTablet,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Gender is required';
                                    }
                                    return null;
                                  },
                                ),
                                
                                SizedBox(height: isTablet ? 20.0 : 16.0),
                                
                                // Email
                                _buildTextField(
                                  controller: _emailController,
                                  label: 'Email',
                                  hintText: 'example@email.com',
                                  keyboardType: TextInputType.emailAddress,
                                  labelFontSize: labelFontSize,
                                  inputFontSize: inputFontSize,
                                  isTablet: isTablet,
                                  validator: (value) {
                                    final v = (value ?? '').trim();
                                    if (v.isEmpty) return 'Email is required';
                                    if (!_isValidEmail(v)) return 'Enter a valid email address';
                                    return null;
                                  },
                                ),
                                
                                SizedBox(height: isTablet ? 20.0 : 16.0),

                                // Phone Number
                                _buildTextField(
                                  controller: _phoneController,
                                  label: 'Phone Number',
                                  hintText: '+1234567890',
                                  keyboardType: TextInputType.phone,
                                  labelFontSize: labelFontSize,
                                  inputFontSize: inputFontSize,
                                  isTablet: isTablet,
                                  validator: (value) {
                                    final v = (value ?? '').trim();
                                    if (v.isEmpty) return 'Phone number is required';
                                    if (!_isValidPhone(v)) return 'Use format like +1234567890';
                                    return null;
                                  },
                                ),
                                
                                SizedBox(height: isTablet ? 20.0 : 16.0),
                                
                                // Password Field
                                _buildPasswordField(
                                  controller: _passwordController,
                                  label: 'Password',
                                  hintText: 'Password',
                                  isVisible: _isPasswordVisible,
                                  onToggleVisibility: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                  labelFontSize: labelFontSize,
                                  inputFontSize: inputFontSize,
                                  isTablet: isTablet,
                                  validator: (value) {
                                    final v = (value ?? '').trim();
                                    if (v.isEmpty) return 'Password is required';
                                    if (!_isValidPassword(v)) return 'Password must be at least 6 characters';
                                    return null;
                                  },
                                ),
                                
                                SizedBox(height: isTablet ? 20.0 : 16.0),
                                
                                // Re-Password
                                _buildPasswordField(
                                  controller: _rePasswordController,
                                  label: 'Re-Password',
                                  hintText: 'Re-Password',
                                  isVisible: _isRePasswordVisible,
                                  onToggleVisibility: () {
                                    setState(() {
                                      _isRePasswordVisible = !_isRePasswordVisible;
                                    });
                                  },
                                  labelFontSize: labelFontSize,
                                  inputFontSize: inputFontSize,
                                  isTablet: isTablet,
                                  validator: (value) {
                                    final v = (value ?? '').trim();
                                    if (v.isEmpty) return 'Re-Password is required';
                                    if (v != _passwordController.text.trim()) {
                                      return 'Passwords do not match';
                                    }
                                    return null;
                                  },
                                ),
                                
                                SizedBox(height: isTablet ? 32.0 : 24.0),
                                
                                // Sign Up Button
                                SizedBox(
                                  width: double.infinity,
                                  height: buttonHeight,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _handleSignUp,
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
                                            'Sign up',
                                            style: TextStyle(
                                              fontSize: isTablet ? 18.0 : 16.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                  ),
                                ),
                                
                                SizedBox(height: isTablet ? 24.0 : 20.0),
                                
                                // Sign In Link
                                Center(
                                  child: GestureDetector(
                                    onTap: () {
                                      AppRouter.pushNamed(context, AppRoutes.signin);
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
                                            text: 'Sign in',
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
            
                                SizedBox(height: isTablet ? 16.0 : 12.0),

                                Center(
                      child: Text(
                                    'Version 1.0',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: isTablet ? 14.0 : 12.0,
                          fontWeight: FontWeight.w500,
                        ),
                                  ),
                                ),
                              ],
                      ),
                    ),
                  );
                },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required double labelFontSize,
    required double inputFontSize,
    required bool isTablet,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: '$label ',
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
          controller: controller,
          keyboardType: keyboardType ?? TextInputType.text,
          style: TextStyle(fontSize: inputFontSize),
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
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
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
    required double labelFontSize,
    required double inputFontSize,
    required bool isTablet,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: '$label ',
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
          controller: controller,
          obscureText: !isVisible,
          style: TextStyle(fontSize: inputFontSize),
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
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
              onTap: onToggleVisibility,
              child: Icon(
                isVisible ? Icons.visibility_off : Icons.visibility,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required double labelFontSize,
    required double inputFontSize,
    required bool isTablet,
    bool isRequired = true,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: TextStyle(
              fontSize: labelFontSize,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            children: isRequired
                ? [
                    TextSpan(
                      text: ' *',
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ]
                : null,
          ),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          validator: validator,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: TextStyle(fontSize: inputFontSize),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Select ${label.replaceAll(' (Optional)', '')}',
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
          style: TextStyle(
            fontSize: inputFontSize,
            color: AppColors.textPrimary,
          ),
          icon: Icon(
            Icons.arrow_drop_down,
            color: AppColors.textSecondary,
          ),
          dropdownColor: AppColors.white,
        ),
      ],
    );
  }

  Widget _buildIllustration() {
    return Image.asset(
      'asset/images/Signup.png',
      width: double.infinity,
      height: double.infinity,
              fit: BoxFit.cover,
      alignment: Alignment.topCenter,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                    color: AppColors.primary.withOpacity(0.1),
                  child: const Center(
                    child: Icon(
                      Icons.person_add,
                      size: 80,
                      color: AppColors.primary,
                    ),
                  ),
                );
              },
    );
  }
}

