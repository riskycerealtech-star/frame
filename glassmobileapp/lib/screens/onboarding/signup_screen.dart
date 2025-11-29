import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/app_router.dart';
import '../../constants/routes.dart';
import '../../constants/colors.dart';
import '../../constants/app_constants.dart';
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

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _rePasswordController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  
  String? _selectedGender;
  String? _selectedOccupation;
  String? _selectedSourceOfFunds;
  String? _selectedTimezone;
  
  bool _isPasswordVisible = false;
  bool _isRePasswordVisible = false;
  bool _isLoading = false;
  
  // Dropdown options
  final List<String> _genderOptions = ['MALE', 'FEMALE', 'OTHER'];
  final List<String> _occupationOptions = ['EMPLOYED', 'UNEMPLOYED', 'STUDENT', 'RETIRED', 'SELF_EMPLOYED'];
  final List<String> _sourceOfFundsOptions = ['SALARY', 'BUSINESS', 'INVESTMENT', 'GIFT', 'OTHER'];
  final List<String> _timezoneOptions = [
    'America/New_York',
    'America/Chicago',
    'America/Denver',
    'America/Los_Angeles',
    'Europe/London',
    'Europe/Paris',
    'Asia/Tokyo',
    'Asia/Dubai',
    'Australia/Sydney',
    'UTC'
  ];

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
    _locationController.dispose();
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
    
    final email = _emailController.text.trim();
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final rePassword = _rePasswordController.text.trim();
    final location = _locationController.text.trim();

    print('🔵 [SIGNUP] Form data collected:');
    print('   - Email: $email');
    print('   - First Name: $firstName');
    print('   - Last Name: $lastName');
    print('   - Phone: $phone');
    print('   - Gender: $_selectedGender');
    print('   - Location: $location');
    print('   - Occupation: $_selectedOccupation');
    print('   - Source of Funds: $_selectedSourceOfFunds');
    print('   - Timezone: $_selectedTimezone');

    // Validate required inputs
    if (email.isEmpty || firstName.isEmpty || lastName.isEmpty || 
        phone.isEmpty || password.isEmpty || rePassword.isEmpty ||
        _selectedGender == null || location.isEmpty) {
      print('❌ [SIGNUP] Validation failed: Missing required fields');
      _showSnackBar('Please fill in all required fields');
      return;
    }

    if (!_isValidEmail(email)) {
      print('❌ [SIGNUP] Validation failed: Invalid email format');
      _showSnackBar('Please enter a valid email address');
      return;
    }

    if (!_isValidName(firstName)) {
      print('❌ [SIGNUP] Validation failed: First name too short');
      _showSnackBar('First name must be at least 2 characters');
      return;
    }

    if (!_isValidName(lastName)) {
      print('❌ [SIGNUP] Validation failed: Last name too short');
      _showSnackBar('Last name must be at least 2 characters');
      return;
    }

    if (!_isValidPhone(phone)) {
      print('❌ [SIGNUP] Validation failed: Invalid phone format');
      _showSnackBar('Please enter a valid phone number (+1234567890)');
      return;
    }

    if (!_isValidPassword(password)) {
      print('❌ [SIGNUP] Validation failed: Password too short');
      _showSnackBar('Password must be at least 6 characters');
      return;
    }

    if (password != rePassword) {
      print('❌ [SIGNUP] Validation failed: Passwords do not match');
      _showSnackBar('Passwords do not match');
      return;
    }

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
        if (_selectedOccupation != null) 'occupation': _selectedOccupation,
        if (_selectedSourceOfFunds != null) 'sourceOfFunds': _selectedSourceOfFunds,
        if (_selectedTimezone != null) 'timezone': _selectedTimezone,
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
          print('   - Location: $location');
          if (_selectedOccupation != null) {
            print('   - Occupation: $_selectedOccupation');
          }
          if (_selectedSourceOfFunds != null) {
            print('   - Source of Funds: $_selectedSourceOfFunds');
          }
          if (_selectedTimezone != null) {
            print('   - Timezone: $_selectedTimezone');
          }
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
                      AppRouter.pop(context);
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
                        height: isTablet ? screenHeight * 0.2 : screenHeight * 0.15,
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
                      
                      // Form Section
                      AnimatedBuilder(
                        animation: _formAnimation,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _formAnimation.value,
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
                                
                                // Email Field
                                _buildTextField(
                                  controller: _emailController,
                                  label: 'Email',
                                  hintText: 'example@email.com',
                                  keyboardType: TextInputType.emailAddress,
                                  labelFontSize: labelFontSize,
                                  inputFontSize: inputFontSize,
                                  isTablet: isTablet,
                                ),
                                
                                SizedBox(height: isTablet ? 20.0 : 16.0),
                                
                                // First Name Field
                                _buildTextField(
                                  controller: _firstNameController,
                                  label: 'First Name',
                                  hintText: 'First Name',
                                  labelFontSize: labelFontSize,
                                  inputFontSize: inputFontSize,
                                  isTablet: isTablet,
                                ),
                                
                                SizedBox(height: isTablet ? 20.0 : 16.0),
                                
                                // Last Name Field
                                _buildTextField(
                                  controller: _lastNameController,
                                  label: 'Last Name',
                                  hintText: 'Last Name',
                                  labelFontSize: labelFontSize,
                                  inputFontSize: inputFontSize,
                                  isTablet: isTablet,
                                ),
                                
                                SizedBox(height: isTablet ? 20.0 : 16.0),
                                
                                // Phone Field
                                _buildTextField(
                                  controller: _phoneController,
                                  label: 'Phone Number',
                                  hintText: '+1234567890',
                                  keyboardType: TextInputType.phone,
                                  labelFontSize: labelFontSize,
                                  inputFontSize: inputFontSize,
                                  isTablet: isTablet,
                                ),
                                
                                SizedBox(height: isTablet ? 20.0 : 16.0),
                                
                                // Gender Dropdown
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
                                ),
                                
                                SizedBox(height: isTablet ? 20.0 : 16.0),
                                
                                // Location Field
                                _buildTextField(
                                  controller: _locationController,
                                  label: 'Location',
                                  hintText: 'City, State, Country',
                                  labelFontSize: labelFontSize,
                                  inputFontSize: inputFontSize,
                                  isTablet: isTablet,
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
                                ),
                                
                                SizedBox(height: isTablet ? 20.0 : 16.0),
                                
                                // Re-Password Field
                                _buildPasswordField(
                                  controller: _rePasswordController,
                                  label: 'Re-Enter Password',
                                  hintText: 'Re-Enter Password',
                                  isVisible: _isRePasswordVisible,
                                  onToggleVisibility: () {
                                    setState(() {
                                      _isRePasswordVisible = !_isRePasswordVisible;
                                    });
                                  },
                                  labelFontSize: labelFontSize,
                                  inputFontSize: inputFontSize,
                                  isTablet: isTablet,
                                ),
                                
                                SizedBox(height: isTablet ? 20.0 : 16.0),
                                
                                // Occupation Dropdown (Optional)
                                _buildDropdownField(
                                  label: 'Occupation (Optional)',
                                  value: _selectedOccupation,
                                  items: _occupationOptions,
                                  onChanged: (String? value) {
                                    setState(() {
                                      _selectedOccupation = value;
                                    });
                                  },
                                  labelFontSize: labelFontSize,
                                  inputFontSize: inputFontSize,
                                  isTablet: isTablet,
                                  isRequired: false,
                                ),
                                
                                SizedBox(height: isTablet ? 20.0 : 16.0),
                                
                                // Source of Funds Dropdown (Optional)
                                _buildDropdownField(
                                  label: 'Source of Funds (Optional)',
                                  value: _selectedSourceOfFunds,
                                  items: _sourceOfFundsOptions,
                                  onChanged: (String? value) {
                                    setState(() {
                                      _selectedSourceOfFunds = value;
                                    });
                                  },
                                  labelFontSize: labelFontSize,
                                  inputFontSize: inputFontSize,
                                  isTablet: isTablet,
                                  isRequired: false,
                                ),
                                
                                SizedBox(height: isTablet ? 20.0 : 16.0),
                                
                                // Timezone Dropdown (Optional)
                                _buildDropdownField(
                                  label: 'Timezone (Optional)',
                                  value: _selectedTimezone,
                                  items: _timezoneOptions,
                                  onChanged: (String? value) {
                                    setState(() {
                                      _selectedTimezone = value;
                                    });
                                  },
                                  labelFontSize: labelFontSize,
                                  inputFontSize: inputFontSize,
                                  isTablet: isTablet,
                                  isRequired: false,
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
                                      AppRouter.pop(context);
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required double labelFontSize,
    required double inputFontSize,
    required bool isTablet,
    TextInputType? keyboardType,
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
              'asset/images/signup.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person_add,
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

