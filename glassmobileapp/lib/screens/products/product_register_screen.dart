import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../constants/colors.dart';
import '../../constants/app_constants.dart';
import '../../services/ai/sunglasses_validation_service.dart';
import '../../widgets/common/back_button_widget.dart';

class ProductRegisterScreen extends StatefulWidget {
  const ProductRegisterScreen({super.key});

  @override
  State<ProductRegisterScreen> createState() => _ProductRegisterScreenState();
}

class _ProductRegisterScreenState extends State<ProductRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  String? _selectedImagePath;
  File? _selectedImageFile;
  final bool _isLoading = false;
  bool _isValidating = false;
  String? _validationMessage;
  SunglassesValidationResult? _lastValidationResult;
  bool _isLowConfidenceRejection = false;
  DateTime? _selectedDate;
  String _description = '';
  // Fixed commission of $10.00
  static const double _commissionAmount = 10.00;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final isTablet = screenWidth > 600;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            // Back Button
            Container(
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
            
            SizedBox(width: 12),
            
            // Title Text
            Expanded(
                      child: Text(
                'Publish Flame',
                        style: TextStyle(
                  fontSize: isTablet ? 20.0 : 18.0,
                  color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title
              Text(
                "Upload your custom flames and start selling\nto our global community of eyewear enthusiasts",
                style: TextStyle(
                  fontSize: isTablet ? 14.0 : 12.0,
                  fontFamily: 'YourFontFamily',
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: isTablet ? 24.0 : 16.0),
              
              // City/Town Input Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Flame Name ',
                    style: TextStyle(
                            fontSize: isTablet ? 16.0 : 14.0,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        TextSpan(
                          text: '*',
                    style: TextStyle(
                            fontSize: isTablet ? 16.0 : 14.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            
                  SizedBox(height: isTablet ? 12.0 : 8.0),
                  
                  // Input Field
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Enter flame name',
                      hintStyle: TextStyle(
                        fontSize: isTablet ? 14.0 : 12.0,
                        color: AppColors.textSecondary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: AppColors.border,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
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
                        horizontal: isTablet ? 16.0 : 12.0,
                        vertical: isTablet ? 16.0 : 12.0,
                      ),
                    ),
                    style: TextStyle(
                      fontSize: isTablet ? 14.0 : 12.0,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: isTablet ? 24.0 : 16.0),
              
              // Flame Color Input Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  // Label
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Flame Color ',
                          style: TextStyle(
                            fontSize: isTablet ? 16.0 : 14.0,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        TextSpan(
                          text: '*',
                          style: TextStyle(
                            fontSize: isTablet ? 16.0 : 14.0,
                            fontWeight: FontWeight.w600,
                          color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
                  
                  SizedBox(height: isTablet ? 12.0 : 8.0),
                  
                  // Input Field
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Enter flame color',
                      hintStyle: TextStyle(
                        fontSize: isTablet ? 14.0 : 12.0,
                        color: AppColors.textSecondary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: AppColors.border,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
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
                        horizontal: isTablet ? 16.0 : 12.0,
                        vertical: isTablet ? 16.0 : 12.0,
                      ),
                    ),
                style: TextStyle(
                      fontSize: isTablet ? 14.0 : 12.0,
                  color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              
              SizedBox(height: isTablet ? 24.0 : 16.0),
              
              // Bought Date Input Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Bought Date ',
                          style: TextStyle(
                            fontSize: isTablet ? 16.0 : 14.0,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        TextSpan(
                          text: '*',
                          style: TextStyle(
                            fontSize: isTablet ? 16.0 : 14.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: isTablet ? 12.0 : 8.0),
                  
                  // Input Field
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'dd/mm/yyyy',
                      hintStyle: TextStyle(
                        fontSize: isTablet ? 14.0 : 12.0,
                        color: AppColors.textSecondary,
                      ),
                      suffixIcon: Icon(
                        Icons.calendar_today,
                        color: AppColors.textSecondary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: AppColors.border,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
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
                        horizontal: isTablet ? 16.0 : 12.0,
                        vertical: isTablet ? 16.0 : 12.0,
                      ),
                    ),
                    style: TextStyle(
                      fontSize: isTablet ? 14.0 : 12.0,
                      color: AppColors.textPrimary,
                    ),
                    readOnly: true,
                    controller: TextEditingController(
                      text: _selectedDate != null 
                          ? '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}'
                          : '',
                    ),
                    onTap: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _selectedDate = pickedDate;
                        });
                      }
                    },
                  ),
                ],
              ),
              
              SizedBox(height: isTablet ? 24.0 : 16.0),
              
              // Price Input Fields (Amount and Quantity)
              Row(
                children: [
                  // Amount Field
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Bought Price ',
                                style: TextStyle(
                                  fontSize: isTablet ? 16.0 : 14.0,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              TextSpan(
                                text: '*',
                                style: TextStyle(
                                  fontSize: isTablet ? 16.0 : 14.0,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red,
              ),
            ),
          ],
        ),
      ),
                        SizedBox(height: isTablet ? 12.0 : 8.0),
                        TextFormField(
                          decoration: InputDecoration(
                            hintText: '0.00',
                            hintStyle: TextStyle(
                              fontSize: isTablet ? 14.0 : 12.0,
                              color: AppColors.textSecondary,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppColors.border,
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
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
                              horizontal: isTablet ? 16.0 : 12.0,
                              vertical: isTablet ? 16.0 : 12.0,
                            ),
                          ),
                          style: TextStyle(
                            fontSize: isTablet ? 14.0 : 12.0,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(width: isTablet ? 16.0 : 12.0),
                  
                  // Quantity Field
                  Expanded(
                    flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                          'Price',
                style: TextStyle(
                            fontSize: isTablet ? 16.0 : 14.0,
                            fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                        ),
                        SizedBox(height: isTablet ? 12.0 : 8.0),
                        TextFormField(
                          decoration: InputDecoration(
                            hintText: '1',
                            hintStyle: TextStyle(
                              fontSize: isTablet ? 14.0 : 12.0,
                              color: AppColors.textSecondary,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppColors.border,
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
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
                              horizontal: isTablet ? 16.0 : 12.0,
                              vertical: isTablet ? 16.0 : 12.0,
                            ),
                          ),
                          style: TextStyle(
                            fontSize: isTablet ? 14.0 : 12.0,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: isTablet ? 16.0 : 12.0),
              
              // Commission Status
              Container(
                padding: EdgeInsets.all(isTablet ? 16.0 : 12.0),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.monetization_on,
                      color: AppColors.primary,
                      size: isTablet ? 20.0 : 18.0,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Commission',
                            style: TextStyle(
                              fontSize: isTablet ? 14.0 : 12.0,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '\$${_commissionAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: isTablet ? 12.0 : 10.0,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isTablet ? 16.0 : 12.0),

              // Description Link
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () {
                    _showDescriptionDialog();
                  },
                  child: Text(
                    'Click Description',
                    style: TextStyle(
                      fontSize: isTablet ? 16.0 : 14.0,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: isTablet ? 24.0 : 16.0),
              
              // Image Upload Section
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isTablet ? 24.0 : 20.0),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
                  border: Border.all(
                    color: AppColors.border,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Click to select your ',
                            style: TextStyle(
                              fontSize: isTablet ? 14.0 : 12.0,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          TextSpan(
                            text: 'flame image',
                      style: TextStyle(
                              fontSize: isTablet ? 14.0 : 12.0,
                              color: Colors.red,
                            ),
                          ),
                          TextSpan(
                            text: ' from gallery',
                      style: TextStyle(
                        fontSize: isTablet ? 14.0 : 12.0,
                        color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: isTablet ? 20.0 : 16.0),
                    
                    // Upload/Remove Button
                    GestureDetector(
                      onTap: _selectedImagePath != null ? _removeImage : _selectImage,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 20.0 : 16.0,
                          vertical: isTablet ? 10.0 : 8.0,
                        ),
                        decoration: BoxDecoration(
                          color: _selectedImagePath != null ? Colors.red : AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: (_selectedImagePath != null ? Colors.red : AppColors.primary).withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _selectedImagePath != null ? Icons.delete : Icons.add_photo_alternate,
                              color: Colors.white,
                              size: isTablet ? 20.0 : 18.0,
                            ),
                            SizedBox(width: 8),
                            Text(
                              _selectedImagePath != null ? 'Remove' : 'Select Image',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isTablet ? 16.0 : 14.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Selected Image Preview
                    if (_selectedImagePath != null) ...[
                      SizedBox(height: isTablet ? 20.0 : 16.0),
                      Container(
                        width: double.infinity,
                        height: isTablet ? 200.0 : 150.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _getValidationBorderColor(),
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Stack(
                            children: [
                              _selectedImageFile != null
                                  ? Image.file(
                                      _selectedImageFile!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: AppColors.primary.withOpacity(0.1),
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.error_outline,
                                                  size: 40,
                                                  color: AppColors.primary,
                                                ),
                                                SizedBox(height: 8),
                                                Text(
                                                  'Failed to load image',
                                                  style: TextStyle(
                                                    color: AppColors.textSecondary,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                  : Image.asset(
                                      _selectedImagePath!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: AppColors.primary.withOpacity(0.1),
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.error_outline,
                                                  size: 40,
                                                  color: AppColors.primary,
                                                ),
                                                SizedBox(height: 8),
                                                Text(
                                                  'Image not found',
                                                  style: TextStyle(
                                                    color: AppColors.textSecondary,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                              // Validation status overlay
                              if (_isValidating || _validationMessage != null)
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        if (_isValidating) ...[
                                          CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            strokeWidth: 2.0,
                                          ),
                                          SizedBox(height: 12),
                                        ],
                                        Text(
                                          _validationMessage ?? 'Validating...',
                                          style: TextStyle(
                                            color: _lastValidationResult != null && _lastValidationResult!.isAccepted 
                                                ? Color(0xFF1E884A)
                                                : _isLowConfidenceRejection 
                                                    ? Colors.red
                                                    : Colors.white,
                                            fontSize: isTablet ? 16.0 : 14.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        if (_lastValidationResult != null) ...[
                                          SizedBox(height: 8),
                                          Text(
                                            'AI Detected: ${(_lastValidationResult!.confidence * 100).toInt()}%',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: isTablet ? 14.0 : 12.0,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              SizedBox(height: isTablet ? 32.0 : 24.0),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: (_isLoading || _isValidating) ? null : _submitForm,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 32.0 : 24.0,
                      vertical: isTablet ? 18.0 : 16.0,
                    ),
                    decoration: BoxDecoration(
                      color: _getSubmitButtonColor(),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: _getSubmitButtonColor().withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _getSubmitButtonContent(isTablet),
                  ),
                ),
              ),
              
              
              SizedBox(height: isTablet ? 24.0 : 16.0),
            ],
          ),
        ),
      ),
    );
  }

  void _selectImage() {
    print('📷 IMAGE SELECTION - User clicked select image button');
    
    _showImageSourceDialog();
  }

  void _removeImage() {
    print('🗑️ IMAGE REMOVAL - User clicked remove image button');
    
    setState(() {
      _selectedImageFile = null;
      _selectedImagePath = null;
      _validationMessage = null;
      _lastValidationResult = null;
      _isLowConfidenceRejection = false;
    });
    
    print('🧹 STATE CLEARED - Image and validation results removed');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Image removed successfully'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }


  void _showDescriptionDialog() {
    final TextEditingController descriptionController = TextEditingController(text: _description);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Add Description',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 200,
            child: TextFormField(
              controller: descriptionController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                hintText: 'Enter description for your flame...',
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: AppColors.border,
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
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
                contentPadding: EdgeInsets.all(12),
              ),
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _description = descriptionController.text;
                });
                Navigator.pop(context);
              },
              child: Text(
                'Save',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Select Image Source',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Gallery Option
              ListTile(
                leading: Icon(Icons.photo_library, color: AppColors.primary),
                title: Text(
                  'Choose from Gallery',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              // Camera Option
              ListTile(
                leading: Icon(Icons.camera_alt, color: AppColors.primary),
                title: Text(
                  'Take a Photo',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                  Navigator.pop(context);
                },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      print('📷 PICKING IMAGE - Source: ${source == ImageSource.camera ? "Camera" : "Gallery"}');
      
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 90,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image != null) {
        print('✅ IMAGE PICKED - Path: ${image.path}');
        
        // Validate image file exists and is readable
        final imageFile = File(image.path);
        if (await imageFile.exists()) {
          final fileSize = await imageFile.length();
          print('📁 FILE INFO - Size: $fileSize bytes');
          
          if (fileSize > 0) {
        setState(() {
              _selectedImageFile = imageFile;
          _selectedImagePath = image.path;
          _validationMessage = null; // Clear previous validation message
          _lastValidationResult = null; // Clear previous validation result
          _isLowConfidenceRejection = false;
        });
        
        print('🧹 STATE CLEARED - Previous validation results cleared');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image selected successfully'),
            backgroundColor: AppColors.primary,
            duration: Duration(seconds: 2),
          ),
        );
          } else {
            throw Exception('Selected image file is empty');
          }
        } else {
          throw Exception('Selected image file does not exist');
        }
      } else {
        print('❌ IMAGE PICKING CANCELLED - User cancelled image selection');
      }
    } catch (e) {
      print('💥 IMAGE PICKING ERROR - ${e.toString()}');
      
      setState(() {
        _selectedImageFile = null;
        _selectedImagePath = null;
        _validationMessage = null;
        _lastValidationResult = null;
        _isLowConfidenceRejection = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to select image: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _submitForm() async {
    print('🔵 SUBMIT BUTTON CLICKED - Starting form submission');
    
    if (_selectedImagePath == null) {
      print('❌ SUBMIT ERROR - No image selected');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select an image first'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    print('✅ SUBMIT VALIDATION - Image path: $_selectedImagePath');
    print('✅ COMMISSION - Fixed: \$${_commissionAmount.toStringAsFixed(2)}');
    print('🚀 SUBMIT PROCESS - Starting AI validation...');
    
    // Start AI validation
    await _validateSunglasses();
  }

  Future<void> _validateSunglasses() async {
    if (_selectedImagePath == null) return;

    print('🔍 VALIDATION START - Beginning sunglasses validation process');
    
    setState(() {
      _isValidating = true;
      _validationMessage = 'AI validating image...';
    });

    try {
      print('🌐 API CHECK - Checking if backend API is available...');
      
      // Check if API is available
      final isApiAvailable = await SunglassesValidationService.isApiAvailable();
      print('🌐 API STATUS - Available: $isApiAvailable');
      
      if (!isApiAvailable) {
        print('❌ API ERROR - Backend API not available');
        throw SunglassesValidationException(
          'AI validation service is not available. Please check your connection.',
          type: ValidationErrorType.networkError,
        );
      }

      print('📁 FILE CHECK - Using selected image file: $_selectedImagePath');
      
      // Use the selected image file
      final imageFile = _selectedImageFile ?? File(_selectedImagePath!);
      
      print('🤖 AI VALIDATION - Sending request to sunglasses validation API...');
      
      // Try file upload first, fallback to base64 if it fails
      SunglassesValidationResult validationResult;
      try {
        validationResult = await SunglassesValidationService.validateSunglassesFromFile(imageFile);
      } catch (e) {
        print('🔄 FALLBACK - File upload failed, trying base64 encoding: ${e.toString()}');
        // Fallback to base64 encoding
        final imageBytes = await imageFile.readAsBytes();
        validationResult = await SunglassesValidationService.validateSunglassesFromBytes(imageBytes);
      }
      
      print('📊 VALIDATION RESULT - Received response from API');
      print('   - Status: ${validationResult.isAccepted ? "ACCEPTED" : "REJECTED"}');
      print('   - Confidence: ${(validationResult.confidence * 100).toStringAsFixed(1)}%');
      print('   - Message: ${validationResult.message}');
      print('   - Details: ${validationResult.details}');
      
      // Override isAccepted if confidence is below 70%
      final bool isActuallyAccepted = validationResult.isAccepted && validationResult.confidence >= 0.7;
      
      if (!isActuallyAccepted && validationResult.isAccepted) {
        print('⚠️ CONFIDENCE CHECK - Validation accepted but confidence below 70%, overriding to rejected');
      }
      
      setState(() {
        _lastValidationResult = validationResult;
        _isValidating = false;

      if (isActuallyAccepted) {
          print('✅ VALIDATION SUCCESS - Sunglasses detected with confidence >= 70%, staying on current screen');
          _validationMessage = 'Flame image validated';
          _isLowConfidenceRejection = false;
      } else {
          print('❌ VALIDATION FAILED - Confidence below 70% or no sunglasses detected, showing rejection message');
          if (validationResult.isAccepted && validationResult.confidence < 0.7) {
            _validationMessage = 'Confidence too low (${(validationResult.confidence * 100).toInt()}%). Please try a clearer image.';
            _isLowConfidenceRejection = true;
          } else {
            _validationMessage = validationResult.message;
            _isLowConfidenceRejection = false;
          }
        }
      });

      if (!isActuallyAccepted) {
        // No sunglasses detected or confidence too low - show rejection (not error)
        _showValidationRejection(validationResult);
      }

    } catch (e) {
      print('💥 VALIDATION ERROR - Exception occurred during validation');
      print('   - Error Type: ${e.runtimeType}');
      print('   - Error Message: ${e.toString()}');
      
      setState(() {
        _isValidating = false;
        _isLowConfidenceRejection = false;
      });

      if (e is SunglassesValidationException) {
        print('🔧 HANDLING - SunglassesValidationException caught');
        print('   - Error Type: ${e.type}');
        print('   - User Message: ${e.type.userMessage}');
        _showValidationError(e);
      } else {
        print('🔧 HANDLING - Unknown exception, wrapping in SunglassesValidationException');
        _showValidationError(
          SunglassesValidationException(
            'Unexpected error during validation: ${e.toString()}',
            type: ValidationErrorType.unknown,
          ),
        );
      }
    }
  }


  void _showValidationRejection(SunglassesValidationResult result) {
    print('❌ VALIDATION REJECTION - Showing rejection to user');
    print('   - Message: ${result.message}');
    print('   - Details: ${result.details}');
    print('   - Confidence: ${(result.confidence * 100).toInt()}%');
    
    // Get the appropriate message (already set in setState above)
    String messageToShow = _validationMessage ?? result.message;

    // Show rejection snackbar (not error)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(messageToShow),
        backgroundColor: Colors.orange, // Orange for rejection, not red for error
        duration: Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Try Again',
          textColor: Colors.white,
          onPressed: () {
            print('🔄 TRY AGAIN CLICKED - User requested retry, clearing validation state');
            setState(() {
              _validationMessage = null;
              _lastValidationResult = null;
              _isLowConfidenceRejection = false;
            });
          },
        ),
      ),
    );
  }

  void _showValidationError(dynamic error) {
    print('❌ VALIDATION ERROR - Showing error to user');
    print('   - Error Type: ${error.runtimeType}');
    
    String message;
    Color backgroundColor = Colors.red;

    if (error is SunglassesValidationResult) {
      print('   - Validation Result Error: ${error.errorMessage}');
      message = error.errorMessage;
    } else if (error is SunglassesValidationException) {
      print('   - Exception Error: ${error.type.userMessage}');
      message = error.type.userMessage;
    } else {
      print('   - Unknown Error: Validation failed');
      message = 'Validation failed. Please try again.';
    }

    print('📱 UI UPDATE - Setting validation message and showing snackbar');
    
    setState(() {
      _validationMessage = message;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () {
            print('🔄 RETRY CLICKED - User requested retry, clearing validation state');
            setState(() {
            _validationMessage = null;
            _lastValidationResult = null;
            });
          },
        ),
      ),
    );
  }

  /// Returns the appropriate border color based on validation status
  Color _getValidationBorderColor() {
    if (_isValidating) {
      return Colors.orange;
    } else if (_lastValidationResult != null) {
      return _lastValidationResult!.isAccepted ? Colors.green : Colors.red;
    } else {
      return AppColors.border;
    }
  }

  /// Returns the appropriate submit button color based on state
  Color _getSubmitButtonColor() {
    if (_isLoading || _isValidating) {
      return AppColors.primary.withOpacity(0.6);
    } else if (_lastValidationResult != null && _lastValidationResult!.isAccepted && _lastValidationResult!.confidence >= 0.7) {
      return Color(0xFF1E884A);
    } else if (_lastValidationResult != null && (!_lastValidationResult!.isAccepted || _lastValidationResult!.confidence < 0.7)) {
      return Colors.grey;
    } else {
      return AppColors.primary;
    }
  }


  /// Returns the appropriate submit button content based on state
  Widget _getSubmitButtonContent(bool isTablet) {
    // Check validation states
    if (_isValidating) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: isTablet ? 20.0 : 18.0,
            height: isTablet ? 20.0 : 18.0,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          SizedBox(width: 12),
          Text(
            'Validating...',
            style: TextStyle(
              color: Colors.white,
              fontSize: isTablet ? 16.0 : 14.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    } else if (_isLoading) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: isTablet ? 20.0 : 18.0,
            height: isTablet ? 20.0 : 18.0,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          SizedBox(width: 12),
          Text(
            'Processing...',
            style: TextStyle(
              color: Colors.white,
              fontSize: isTablet ? 16.0 : 14.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    } else if (_lastValidationResult != null && !_lastValidationResult!.isAccepted) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.white,
            size: isTablet ? 20.0 : 18.0,
          ),
          SizedBox(width: 8),
          Text(
            'Validation Failed',
            style: TextStyle(
              color: Colors.white,
              fontSize: isTablet ? 16.0 : 14.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    } else if (_lastValidationResult != null && _lastValidationResult!.isAccepted && _lastValidationResult!.confidence >= 0.7) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Publish',
            style: TextStyle(
              color: Colors.white,
              fontSize: isTablet ? 16.0 : 14.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 8),
          Icon(
            Icons.check,
            color: Colors.white,
            size: isTablet ? 20.0 : 18.0,
          ),
        ],
      );
    } else {
      // Default state when commission is selected but no validation yet
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'AI Validation',
            style: TextStyle(
              color: Colors.white,
              fontSize: isTablet ? 16.0 : 14.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }
  }
}
