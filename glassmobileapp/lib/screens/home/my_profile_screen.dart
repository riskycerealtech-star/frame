import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/app_router.dart';
import '../../constants/colors.dart';
import '../../constants/routes.dart';
import '../../widgets/common/bottom_navigation_bar_widget.dart';
import '../../widgets/common/commission_dialog.dart';
import '../../widgets/common/app_bar_action_icons.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  // Bottom navigation
  int _currentBottomNavIndex = 4;
  static const int _notificationCount = 14;
  static const int _cartCount = 2;

  // Commission dialog state (same as HomeScreen)
  final bool _isFirstRowOccupied = false;

  // Editable profile fields (same as signup)
  // Defaults are set here (not `late`) so hot-reload can't crash with
  // LateInitializationError before initState runs.
  String _firstName = 'Drew';
  String _lastName = 'Johnson';
  String _gender = 'Male';
  String _genderDraft = 'Male';
  String _email = 'drew@example.com';
  String _phoneNumber = '+1234567890';
  String _location = 'New York, USA';
  String _password = '';
  String _rePassword = '';

  String? _editingKey;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _rePasswordController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();
  File? _avatarFile;

  @override
  void initState() {
    super.initState();
    // Seed controllers from current values.
    _genderDraft = _gender;
    _firstNameController.text = _firstName;
    _lastNameController.text = _lastName;
    _emailController.text = _email;
    _phoneController.text = _phoneNumber;
    _locationController.text = _location;
    _passwordController.text = _password;
    _rePasswordController.text = _rePassword;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _passwordController.dispose();
    _rePasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatarImage(ImageSource source) async {
    try {
      final XFile? picked = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
      );

      if (!mounted || picked == null) return;

      setState(() {
        _avatarFile = File(picked.path);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not pick image: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showAvatarSourceDialog() {
    final isTablet = MediaQuery.of(context).size.width > 600;
    showDialog(
      context: context,
      useRootNavigator: true,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 16.0 : 14.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Update Photo',
                  style: TextStyle(
                    fontSize: isTablet ? 18.0 : 16.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: isTablet ? 12.0 : 10.0),
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined, color: Colors.blue),
                  title: const Text('Camera'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickAvatarImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined, color: Colors.blue),
                  title: const Text('Gallery'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickAvatarImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCommissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CommissionDialog(
          onCommissionSelected: (tier) {
            Navigator.of(context).pop();
            Future.delayed(const Duration(milliseconds: 100), () {
              AppRouter.pushNamed(
                context,
                AppRoutes.productRegister,
                arguments: {'commissionTier': tier, 'isFirstRowOccupied': _isFirstRowOccupied},
              );
            });
          },
          isFirstRowOccupied: _isFirstRowOccupied,
        );
      },
    );
  }

  void _showUpdateSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Update Successful!'),
        backgroundColor: AppColors.darkGreen,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appBarBg = isDark ? AppColors.primary : AppColors.white;
    final appBarFg = isDark ? AppColors.white : Colors.black;

    final fullName = '$_firstName $_lastName';

    return Scaffold(
      appBar: AppBar(
        shape: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white : Colors.black,
            width: 1,
          ),
        ),
        backgroundColor: appBarBg,
        foregroundColor: appBarFg,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 8,
        leading: IconButton(
          onPressed: () => AppRouter.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text(
          'My Profile',
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Edit tapped'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: Text(
              'Edit',
              style: TextStyle(
                color: appBarFg,
                fontSize: isTablet ? 16.0 : 14.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          AppBarActionIcons(
            notificationCount: _notificationCount,
            cartCount: _cartCount,
            isTablet: isTablet,
            iconColor: appBarFg,
            showCart: false,
            onNotificationTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notifications'),
                  duration: Duration(seconds: 2),
                  backgroundColor: Colors.red,
                ),
              );
            },
            onCartTap: () => AppRouter.pushNamed(context, AppRoutes.cart),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
        children: [
          // Centered avatar header (not inside a card)
          Center(
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: isTablet ? 44 : 38,
                      backgroundColor: AppColors.primary.withOpacity(0.12),
                      backgroundImage: _avatarFile != null
                          ? FileImage(_avatarFile!)
                          : const AssetImage('asset/images/n.jpeg'),
                      onBackgroundImageError: (_, __) {},
                      child: _avatarFile == null
                          ? Text(
                              fullName.isNotEmpty ? fullName.characters.first.toUpperCase() : 'U',
                              style: TextStyle(
                                fontSize: isTablet ? 26 : 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      right: -6,
                      bottom: -6,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _AvatarActionButton(
                            backgroundColor: Colors.redAccent,
                            icon: Icons.delete_outline,
                            onTap: () {
                              setState(() {
                                _avatarFile = null;
                              });
                            },
                            isTablet: isTablet,
                          ),
                          SizedBox(height: isTablet ? 10 : 8),
                          _AvatarActionButton(
                            backgroundColor: Colors.blueAccent,
                            icon: Icons.photo_camera_outlined,
                            onTap: () {
                              // Schedule to next microtask to avoid the tap event
                              // immediately dismissing the dialog on some devices.
                              Future.microtask(_showAvatarSourceDialog);
                            },
                            isTablet: isTablet,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: isTablet ? 20.0 : 16.0),

          // Logout button (below avatar)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                AppRouter.pushReplacementNamed(context, AppRoutes.signin);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFD93211),
                side: const BorderSide(color: Color(0xFFD93211), width: 2),
                padding: EdgeInsets.symmetric(
                  vertical: isTablet ? 12.0 : 10.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Logout',
                style: TextStyle(
                  fontSize: isTablet ? 16.0 : 14.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          SizedBox(height: isTablet ? 20.0 : 16.0),

          // Profile fields (same as signup inputs)
          _EditableTextTile(
            icon: Icons.badge_outlined,
            label: 'First NAME',
            value: _firstName,
            isTablet: isTablet,
            isEditing: _editingKey == 'firstName',
            controller: _firstNameController,
            keyboardType: TextInputType.name,
            onEdit: () {
              setState(() {
                _editingKey = 'firstName';
                _firstNameController.text = _firstName;
              });
            },
            onSave: () {
              setState(() {
                _firstName = _firstNameController.text.trim();
                _editingKey = null;
              });
              _showUpdateSuccess();
            },
          ),
          _EditableTextTile(
            icon: Icons.badge_outlined,
            label: 'Last Name',
            value: _lastName,
            isTablet: isTablet,
            isEditing: _editingKey == 'lastName',
            controller: _lastNameController,
            keyboardType: TextInputType.name,
            onEdit: () {
              setState(() {
                _editingKey = 'lastName';
                _lastNameController.text = _lastName;
              });
            },
            onSave: () {
              setState(() {
                _lastName = _lastNameController.text.trim();
                _editingKey = null;
              });
              _showUpdateSuccess();
            },
          ),
          _EditableGenderTile(
            icon: Icons.person_outline,
            label: 'Gender',
            value: _gender,
            draftValue: _genderDraft,
            isTablet: isTablet,
            isEditing: _editingKey == 'gender',
            onEdit: () {
              setState(() {
                _editingKey = 'gender';
                _genderDraft = _gender;
              });
            },
            onChanged: (v) {
              setState(() {
                _genderDraft = v;
              });
            },
            onSave: () {
              setState(() {
                _gender = _genderDraft;
                _editingKey = null;
              });
              _showUpdateSuccess();
            },
          ),
          _EditableTextTile(
            icon: Icons.email_outlined,
            label: 'Email',
            value: _email,
            isTablet: isTablet,
            isEditing: _editingKey == 'email',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            onEdit: () {
              setState(() {
                _editingKey = 'email';
                _emailController.text = _email;
              });
            },
            onSave: () {
              setState(() {
                _email = _emailController.text.trim();
                _editingKey = null;
              });
              _showUpdateSuccess();
            },
          ),
          _EditableTextTile(
            icon: Icons.phone_outlined,
            label: 'Phone Number',
            value: _phoneNumber,
            isTablet: isTablet,
            isEditing: _editingKey == 'phoneNumber',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            onEdit: () {
              setState(() {
                _editingKey = 'phoneNumber';
                _phoneController.text = _phoneNumber;
              });
            },
            onSave: () {
              setState(() {
                _phoneNumber = _phoneController.text.trim();
                _editingKey = null;
              });
              _showUpdateSuccess();
            },
          ),
          _EditableTextTile(
            icon: Icons.location_on_outlined,
            label: 'Location',
            value: _location,
            isTablet: isTablet,
            isEditing: _editingKey == 'location',
            controller: _locationController,
            keyboardType: TextInputType.streetAddress,
            onEdit: () {
              setState(() {
                _editingKey = 'location';
                _locationController.text = _location;
              });
            },
            onSave: () {
              setState(() {
                _location = _locationController.text.trim();
                _editingKey = null;
              });
              _showUpdateSuccess();
            },
          ),
          _EditableTextTile(
            icon: Icons.lock_outline,
            label: 'Password',
            value: _password,
            isTablet: isTablet,
            isEditing: _editingKey == 'password',
            controller: _passwordController,
            keyboardType: TextInputType.visiblePassword,
            obscureText: true,
            onEdit: () {
              setState(() {
                _editingKey = 'password';
                _passwordController.text = _password;
              });
            },
            onSave: () {
              setState(() {
                _password = _passwordController.text;
                _editingKey = null;
              });
              _showUpdateSuccess();
            },
          ),
          _EditableTextTile(
            icon: Icons.lock_outline,
            label: 'Re-Password',
            value: _rePassword,
            isTablet: isTablet,
            isEditing: _editingKey == 'rePassword',
            controller: _rePasswordController,
            keyboardType: TextInputType.visiblePassword,
            obscureText: true,
            onEdit: () {
              setState(() {
                _editingKey = 'rePassword';
                _rePasswordController.text = _rePassword;
              });
            },
            onSave: () {
              setState(() {
                _rePassword = _rePasswordController.text;
                _editingKey = null;
              });
              _showUpdateSuccess();
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        currentIndex: _currentBottomNavIndex,
        cartBadgeCount: _cartCount,
        onTap: (index) {
          setState(() {
            _currentBottomNavIndex = index;
          });

          // Same behavior as HomeScreen
          switch (index) {
            case 0:
              AppRouter.pushReplacementNamed(context, AppRoutes.home);
              break;
            case 1:
              AppRouter.pushNamed(context, AppRoutes.myMarket);
              break;
            case 2:
              AppRouter.pushNamed(context, AppRoutes.cart);
              break;
            case 3:
              _showCommissionDialog();
              break;
            case 4:
              // Already on profile
              break;
          }
        },
      ),
    );
  }
}

class _EditableTextTile extends StatelessWidget {
  const _EditableTextTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.isTablet,
    required this.isEditing,
    required this.controller,
    required this.onEdit,
    required this.onSave,
    this.keyboardType,
    this.obscureText = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isTablet;
  final bool isEditing;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final VoidCallback onEdit;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final displayValue = obscureText ? (value.isEmpty ? '' : '••••••••') : value;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: ListTile(
        leading: isEditing ? null : Icon(icon, color: AppColors.primary),
        title: Text(
          label,
          style: TextStyle(
            fontSize: isTablet ? 14.0 : 13.0,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: isEditing
            ? TextField(
                controller: controller,
                keyboardType: keyboardType,
                obscureText: obscureText,
                style: TextStyle(
                  fontSize: isTablet ? 14.0 : 13.0,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: isTablet ? 10 : 8,
                  ),
                  border: const OutlineInputBorder(),
                ),
              )
            : Text(
                displayValue,
                style: TextStyle(
                  fontSize: isTablet ? 16.0 : 14.0,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
        trailing: isEditing
            ? TextButton(
                onPressed: onSave,
                child: Text(
                  'Save',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w700,
                    fontSize: isTablet ? 14.0 : 13.0,
                  ),
                ),
              )
            : IconButton(
                onPressed: onEdit,
                icon: Icon(
                  Icons.edit,
                  color: Colors.blue,
                  size: isTablet ? 20.0 : 18.0,
                ),
                tooltip: 'Edit',
              ),
      ),
    );
  }
}

class _EditableGenderTile extends StatelessWidget {
  const _EditableGenderTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.draftValue,
    required this.isTablet,
    required this.isEditing,
    required this.onEdit,
    required this.onChanged,
    required this.onSave,
  });

  final IconData icon;
  final String label;
  final String value;
  final String draftValue;
  final bool isTablet;
  final bool isEditing;
  final VoidCallback onEdit;
  final ValueChanged<String> onChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: ListTile(
        leading: isEditing ? null : Icon(icon, color: AppColors.primary),
        title: Text(
          label,
          style: TextStyle(
            fontSize: isTablet ? 14.0 : 13.0,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: isEditing
            ? DropdownButtonFormField<String>(
                value: draftValue.isEmpty ? null : draftValue,
                items: const ['Male', 'Female', 'N/A']
                    .map(
                      (g) => DropdownMenuItem<String>(
                        value: g,
                        child: Text(g),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) onChanged(v);
                },
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: isTablet ? 10 : 8,
                  ),
                  border: const OutlineInputBorder(),
                ),
              )
            : Text(
                value,
                style: TextStyle(
                  fontSize: isTablet ? 16.0 : 14.0,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
        trailing: isEditing
            ? TextButton(
                onPressed: onSave,
                child: Text(
                  'Save',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w700,
                    fontSize: isTablet ? 14.0 : 13.0,
                  ),
                ),
              )
            : IconButton(
                onPressed: onEdit,
                icon: Icon(
                  Icons.edit,
                  color: Colors.blue,
                  size: isTablet ? 20.0 : 18.0,
                ),
                tooltip: 'Edit',
              ),
      ),
    );
  }
}

class _AvatarActionButton extends StatelessWidget {
  const _AvatarActionButton({
    required this.backgroundColor,
    required this.icon,
    required this.onTap,
    required this.isTablet,
  });

  final Color backgroundColor;
  final IconData icon;
  final VoidCallback onTap;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final size = isTablet ? 32.0 : 28.0;
    final iconSize = isTablet ? 16.0 : 15.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size / 2),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: iconSize,
          ),
        ),
      ),
    );
  }
}







