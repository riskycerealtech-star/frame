import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../constants/colors.dart';
import '../../services/ai/sunglasses_validation_service.dart';

enum _FrameSide { front, left, right, top }

extension _FrameSideX on _FrameSide {
  String get label {
    switch (this) {
      case _FrameSide.front:
        return 'Front';
      case _FrameSide.left:
        return 'Left';
      case _FrameSide.right:
        return 'Right';
      case _FrameSide.top:
        return 'Top';
    }
  }
}

class ProductRegisterScreen extends StatefulWidget {
  const ProductRegisterScreen({super.key});

  @override
  State<ProductRegisterScreen> createState() => _ProductRegisterScreenState();
}

class _ProductRegisterScreenState extends State<ProductRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final Map<_FrameSide, File?> _sideImages = {
    for (final side in _FrameSide.values) side: null,
  };
  final Map<_FrameSide, SunglassesValidationResult?> _sideValidation = {
    for (final side in _FrameSide.values) side: null,
  };
  _FrameSide _activeSide = _FrameSide.front;
  final List<_FrameSide> _uploadOrder = const [
    _FrameSide.front, // first: fill big preview
    _FrameSide.top,   // then: start with top
    _FrameSide.left,
    _FrameSide.right,
  ];
  final bool _isLoading = false;
  bool _isValidating = false;
  String? _validationMessage;
  bool _isLowConfidenceRejection = false;
  String _description = '';
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  final TextEditingController _flameNameController = TextEditingController();
  final TextEditingController _flameDesignerController = TextEditingController();
  final TextEditingController _flameBrandController = TextEditingController();
  final TextEditingController _flameColorController = TextEditingController();
  final TextEditingController _flamePriceController = TextEditingController();
  BuildContext? _tabsContext;

  @override
  void dispose() {
    _flameNameController.dispose();
    _flameDesignerController.dispose();
    _flameBrandController.dispose();
    _flameColorController.dispose();
    _flamePriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final isTablet = screenWidth > 600;
    
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 8,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
              ),
        title: const Text(
                'Publish Frame',
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: DefaultTabController(
        length: 2,
        child: Builder(
          builder: (tabCtx) {
            // Capture a context that is *inside* DefaultTabController
            _tabsContext = tabCtx;
            return Column(
              children: [
                Material(
                  color: AppColors.white,
                  child: TabBar(
                    indicatorColor: AppColors.primary,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textSecondary,
                    tabs: const [
                      Tab(text: 'Details'),
                      Tab(text: 'AI Validation'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildDetailsTab(tabCtx, isTablet),
                      _buildAiValidationTab(isTablet),
                    ],
                      ),
                    ),
          ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDetailsTab(BuildContext context, bool isTablet) {
    return Container(
      color: AppColors.white,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
        child: Form(
          key: _formKey,
          autovalidateMode: _autovalidateMode,
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

              // --- Existing form fields + image selection (unchanged UI) ---
              // NOTE: We keep your existing widget tree as-is by reusing it from the current build.
              // For readability, we just call the existing private builder that already exists in this file.
              // Since the original code was inline, we keep it inline below.
              
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
                    controller: _flameNameController,
                    cursorColor: Colors.black,
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return 'Flame name is required';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter flame name',
                      hintStyle: TextStyle(
                        fontSize: isTablet ? 14.0 : 12.0,
                        color: AppColors.textSecondary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.black,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.black,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.black,
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
                      color: Colors.black,
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
                          text: 'Flame Designer ',
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
                    controller: _flameDesignerController,
                    cursorColor: Colors.black,
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return 'Flame designer is required';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter flame designer',
                      hintStyle: TextStyle(
                        fontSize: isTablet ? 14.0 : 12.0,
                        color: AppColors.textSecondary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.black,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.black,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.black,
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
                      color: Colors.black,
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
                          text: 'Flame Bland ',
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
                    controller: _flameBrandController,
                    cursorColor: Colors.black,
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return 'Flame brand is required';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter flame bland',
                      hintStyle: TextStyle(
                        fontSize: isTablet ? 14.0 : 12.0,
                        color: AppColors.textSecondary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.black,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.black,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.black,
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
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: isTablet ? 24.0 : 16.0),
              
              // Flame Color Input Field (replacing price fields)
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
                    controller: _flameColorController,
                    cursorColor: Colors.black,
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return 'Flame color is required';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter flame color',
                      hintStyle: TextStyle(
                        fontSize: isTablet ? 14.0 : 12.0,
                        color: AppColors.textSecondary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.black,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.black,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.black,
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
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: isTablet ? 24.0 : 16.0),
              
              // Price Input Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Flame Price ',
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
                    controller: _flamePriceController,
                    cursorColor: Colors.black,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      final v = (value ?? '').trim();
                      if (v.isEmpty) return 'Price is required';
                      final parsed = double.tryParse(v);
                      if (parsed == null) return 'Enter a valid price';
                      if (parsed <= 0) return 'Price must be greater than 0';
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter price',
                      hintStyle: TextStyle(
                        fontSize: isTablet ? 14.0 : 12.0,
                        color: AppColors.textSecondary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.black,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.black,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.black,
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
                      color: Colors.black,
                    ),
                  ),
                ],
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
              
              SizedBox(height: isTablet ? 18.0 : 14.0),
              Text(
                'Continue to AI Validation to upload and validate your image.',
                            style: TextStyle(
                  fontSize: isTablet ? 13.0 : 12.0,
                              color: AppColors.textSecondary,
                            ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: isTablet ? 16.0 : 12.0),

              // Continue to AI Validation
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final isValid = _formKey.currentState?.validate() ?? false;
                    if (!isValid) {
                      setState(() {
                        _autovalidateMode = AutovalidateMode.always;
                      });
                      return;
                    }

                    final tabController = DefaultTabController.of(context);
                    tabController.animateTo(1);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: isTablet ? 16.0 : 14.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Continue',
                      style: TextStyle(
                      fontSize: isTablet ? 16.0 : 14.0,
                      fontWeight: FontWeight.w600,
                    ),
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

  Widget _buildAiValidationTab(bool isTablet) {
    final canSubmit = _hasAllSideImages;
    final submitColor = canSubmit ? _getSubmitButtonColor() : Colors.grey;
    final uploadedCount = _sideImages.values.where((f) => f != null).length;
    final _FrameSide? firstMissingSide = _uploadOrder
        .cast<_FrameSide?>()
        .firstWhere((s) => s != null && _sideImages[s] == null, orElse: () => null);

    return Container(
      color: AppColors.white,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'AI Validation',
                              style: TextStyle(
                  fontSize: isTablet ? 18.0 : 16.0,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            SizedBox(height: isTablet ? 10.0 : 8.0),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Upload all sides images, then validate and publish.',
                style: TextStyle(
                  fontSize: isTablet ? 14.0 : 12.0,
                  color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    
            SizedBox(height: isTablet ? 16.0 : 12.0),

            // Multi-image side uploader (thumbnail column + big preview)
                      Container(
                        width: double.infinity,
              padding: EdgeInsets.all(isTablet ? 16.0 : 12.0),
                        decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                  color: AppColors.border,
                  width: 1,
                          ),
                        ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                  // Thumbnails column
                  Column(
                    children: [
                      for (final side in _FrameSide.values) ...[
                        _buildSideThumbnail(side, isTablet),
                        if (side != _FrameSide.values.last) const SizedBox(height: 12),
                      ],
                    ],
                  ),
                  SizedBox(width: isTablet ? 16.0 : 12.0),
                  // Main preview
                  Expanded(
                                            child: Column(
                      children: [
                        _buildMainSidePreview(isTablet),
                        SizedBox(height: isTablet ? 10.0 : 8.0),
                        Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                            if (uploadedCount == _FrameSide.values.length) ...[
                              const Icon(Icons.check_circle, color: Colors.green, size: 16),
                              const SizedBox(width: 6),
                            ],
                                                Text(
                              '$uploadedCount/${_FrameSide.values.length} Sides',
                                                  style: TextStyle(
                                                    color: AppColors.textSecondary,
                                fontSize: isTablet ? 13.0 : 12.0,
                                                  ),
                                                ),
                                              ],
                                            ),
                        if (!_hasAllSideImages) ...[
                          SizedBox(height: isTablet ? 8.0 : 6.0),
                                                Text(
                            'Upload all sides before validation',
                                                  style: TextStyle(
                              color: Colors.red,
                              fontSize: isTablet ? 12.0 : 11.0,
                              fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                        ],
                                              ],
                                            ),
                                          ),
                ],
              ),
            ),

            SizedBox(height: isTablet ? 22.0 : 16.0),

            // Action button:
            // - Show "Upload Image" until all sides are uploaded
            // - Show "AI Validation" (and later "Publish") once all sides exist
            SizedBox(
              width: double.infinity,
              child: !canSubmit
                  ? GestureDetector(
                      onTap: (_isLoading || _isValidating)
                          ? null
                          : () {
                              final sideToPick = uploadedCount == 0
                                  ? _FrameSide.front
                                  : (firstMissingSide ?? _activeSide);
                              setState(() => _activeSide = sideToPick);
                              _pickImageForSide(ImageSource.gallery, sideToPick);
                            },
                      onLongPress: (_isLoading || _isValidating)
                          ? null
                          : () {
                              final sideToPick = uploadedCount == 0
                                  ? _FrameSide.front
                                  : (firstMissingSide ?? _activeSide);
                              setState(() => _activeSide = sideToPick);
                              _showImageSourceDialog(sideToPick);
                            },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 32.0 : 24.0,
                          vertical: isTablet ? 18.0 : 16.0,
                        ),
                                  decoration: BoxDecoration(
                          color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                                  ),
                          ],
                        ),
                        child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                            const Icon(Icons.cloud_upload, color: Colors.white, size: 18),
                            const SizedBox(width: 10),
                                        Text(
                              'Upload Image',
                                          style: TextStyle(
                                color: Colors.white,
                                            fontSize: isTablet ? 16.0 : 14.0,
                                            fontWeight: FontWeight.w600,
                              ),
                            ),
                                      ],
                                    ),
                                  ),
                    )
                  : GestureDetector(
                  onTap: (_isLoading || _isValidating) ? null : _submitForm,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 32.0 : 24.0,
                      vertical: isTablet ? 18.0 : 16.0,
                    ),
                    decoration: BoxDecoration(
                          color: submitColor,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                              color: submitColor.withOpacity(0.3),
                          blurRadius: 8,
                              offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _getSubmitButtonContent(isTablet),
                  ),
                ),
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
                            '5%',
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
              
              SizedBox(height: isTablet ? 24.0 : 16.0),
            ],
          ),
        ),
    );
  }

  bool get _hasAllSideImages => _sideImages.values.every((f) => f != null);

  Color _getSideBorderColor(_FrameSide side) {
    if (_isValidating && _activeSide == side) return Colors.orange;
    final r = _sideValidation[side];
    if (r == null) return AppColors.border;
    final accepted = r.isAccepted && r.confidence >= 0.7;
    return accepted ? Colors.green : Colors.red;
  }

  Widget _buildSideThumbnail(_FrameSide side, bool isTablet) {
    final isActive = _activeSide == side;
    final file = _sideImages[side];
    final borderColor = isActive ? Colors.black : AppColors.border;
    final uploadedCount = _sideImages.values.where((f) => f != null).length;

    return GestureDetector(
      onTap: () {
        // First-time rule: fill the big image first (Front), then continue.
        if (uploadedCount == 0 && side != _FrameSide.front) {
          setState(() => _activeSide = _FrameSide.front);
          _pickImageForSide(ImageSource.gallery, _FrameSide.front);
          return;
        }

        setState(() => _activeSide = side);
        if (_sideImages[side] == null) _pickImageForSide(ImageSource.gallery, side);
      },
      onLongPress: () {
        if (uploadedCount == 0 && side != _FrameSide.front) {
          setState(() => _activeSide = _FrameSide.front);
          _showImageSourceDialog(_FrameSide.front);
          return;
        }
        setState(() => _activeSide = side);
        _showImageSourceDialog(side);
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: isTablet ? 78 : 68,
            height: isTablet ? 78 : 68,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: borderColor,
                width: isActive ? 2 : 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: file == null
                  ? Container(
                      color: AppColors.primary.withOpacity(0.06),
                      child: Center(
                        child: Icon(
                          Icons.add,
                          color: AppColors.textSecondary,
                          size: isTablet ? 24 : 22,
                        ),
                      ),
                    )
                  : Image.file(
                      file,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.primary.withOpacity(0.06),
                          child: const Center(child: Icon(Icons.broken_image)),
                        );
                      },
                    ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: -18,
            child: Center(
              child: Text(
                side.label,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: isTablet ? 12 : 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          // Status dot
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: file == null ? Colors.grey.shade400 : _getSideBorderColor(side),
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainSidePreview(bool isTablet) {
    final file = _sideImages[_activeSide];
    final uploadedCount = _sideImages.values.where((f) => f != null).length;
    return Container(
      width: double.infinity,
      height: isTablet ? 320 : 240,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _getSideBorderColor(_activeSide),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: GestureDetector(
          onTap: (_isValidating || _isLoading)
              ? null
              : () {
                  // First-time rule: big preview must be filled first (Front)
                  final sideToPick = uploadedCount == 0 ? _FrameSide.front : _activeSide;
                  setState(() => _activeSide = sideToPick);
                  if (_sideImages[sideToPick] == null) {
                    _pickImageForSide(ImageSource.gallery, sideToPick);
                  }
                },
          child: Stack(
            children: [
            if (file == null)
              Container(
                color: AppColors.primary.withOpacity(0.04),
                child: Center(
                  child: Text(
                    uploadedCount == 0
                        ? 'Tap here to upload your first image (Front)'
                        : 'Tap a side to upload (${_activeSide.label})',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: isTablet ? 14 : 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            else
              Image.file(
                file,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),

            // Overlay for validation status
            if (_isValidating || _validationMessage != null)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.35),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isValidating) ...[
                          const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                        Text(
                          _validationMessage ?? 'Validating...',
                          style: TextStyle(
                            color: _isLowConfidenceRejection ? Colors.red : Colors.white,
                            fontSize: isTablet ? 16.0 : 14.0,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Actions (replace/remove) when there is an image
            if (file != null && !_isValidating)
              Positioned(
                right: 10,
                top: 10,
                child: Row(
                  children: [
                    _previewActionChip(
                      label: 'Replace',
                      onTap: () => _showImageSourceDialog(_activeSide),
                      background: Colors.black.withOpacity(0.55),
                    ),
                    const SizedBox(width: 8),
                    _previewActionChip(
                      label: 'Remove',
                      onTap: () => _removeImage(_activeSide),
                      background: Colors.red.withOpacity(0.75),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _previewActionChip({
    required String label,
    required VoidCallback onTap,
    required Color background,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _removeImage(_FrameSide side) {
    print('🗑️ IMAGE REMOVAL - Removing image for side: ${side.label}');
    
    setState(() {
      _sideImages[side] = null;
      _sideValidation[side] = null;
      _validationMessage = null;
      _isLowConfidenceRejection = false;
      if (_activeSide == side) {
        // keep active side, but preview will show placeholder
      }
    });
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
              cursorColor: Colors.black,
              decoration: InputDecoration(
                hintText: 'Enter description for your flame...',
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Colors.black,
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Colors.black,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Colors.black,
                    width: 2,
                  ),
                ),
                contentPadding: EdgeInsets.all(12),
              ),
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
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

  void _showImageSourceDialog(_FrameSide side) {
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
                  _pickImageForSide(ImageSource.gallery, side);
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
                  _pickImageForSide(ImageSource.camera, side);
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

  Future<void> _pickImageForSide(ImageSource source, _FrameSide side) async {
    try {
      print('📷 PICKING IMAGE - Side: ${side.label} Source: ${source == ImageSource.camera ? "Camera" : "Gallery"}');
      final previouslyUploadedCount = _sideImages.values.where((f) => f != null).length;
      
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
              _sideImages[side] = imageFile;
              _sideValidation[side] = null;
              // If this is the first image (Front), move user to "Top" next.
              if (previouslyUploadedCount == 0 && side == _FrameSide.front && _sideImages[_FrameSide.top] == null) {
                _activeSide = _FrameSide.top;
              } else {
                _activeSide = side;
              }
          _validationMessage = null; // Clear previous validation message
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
        _sideImages[side] = null;
        _sideValidation[side] = null;
        _validationMessage = null;
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
    
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      setState(() {
        _autovalidateMode = AutovalidateMode.always;
      });
      final tabController = _tabsContext != null ? DefaultTabController.maybeOf(_tabsContext!) : null;
      tabController?.animateTo(0);
      return;
    }
    
    if (!_hasAllSideImages) {
      print('❌ SUBMIT ERROR - Missing side images');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please upload all sides images first'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    print('✅ SUBMIT VALIDATION - All side images selected');
    print('✅ COMMISSION - Rate: 5%');
    print('🚀 SUBMIT PROCESS - Starting AI validation...');
    
    // Start AI validation
    await _validateSunglasses();
  }

  Future<void> _validateSunglasses() async {
    if (!_hasAllSideImages) return;

    print('🔍 VALIDATION START - Beginning sunglasses validation process');
    
    setState(() {
      _isValidating = true;
      _validationMessage = 'AI validating images...';
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

      final sides = _FrameSide.values;
      for (int i = 0; i < sides.length; i++) {
        final side = sides[i];
        final imageFile = _sideImages[side];
        if (imageFile == null) continue;

        setState(() {
          _activeSide = side;
          _validationMessage = 'Validating ${side.label} (${i + 1}/${sides.length})...';
          _isLowConfidenceRejection = false;
        });

        print('📁 FILE CHECK - Side: ${side.label} File: ${imageFile.path}');
        print('🤖 AI VALIDATION - Sending request for side: ${side.label}');

      SunglassesValidationResult validationResult;
      try {
        validationResult = await SunglassesValidationService.validateSunglassesFromFile(imageFile);
      } catch (e) {
          print('🔄 FALLBACK - File upload failed for ${side.label}, trying base64: ${e.toString()}');
        final imageBytes = await imageFile.readAsBytes();
        validationResult = await SunglassesValidationService.validateSunglassesFromBytes(imageBytes);
      }
      
        setState(() {
          _sideValidation[side] = validationResult;
        });

        final bool accepted = validationResult.isAccepted && validationResult.confidence >= 0.7;
        if (!accepted) {
          final msg = (validationResult.isAccepted && validationResult.confidence < 0.7)
              ? 'Confidence too low on ${side.label} (${(validationResult.confidence * 100).toInt()}%). Try clearer image.'
              : validationResult.message;
      
      setState(() {
        _isValidating = false;
            _validationMessage = msg;
            _isLowConfidenceRejection = true;
      });

        _showValidationRejection(validationResult);
          return;
        }
      }

      setState(() {
        _isValidating = false;
        _validationMessage = 'All sides validated';
        _isLowConfidenceRejection = false;
      });

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
              _sideValidation[_activeSide] = null;
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
            _sideValidation[_activeSide] = null;
            });
          },
        ),
      ),
    );
  }

  /// Returns the appropriate submit button color based on state
  Color _getSubmitButtonColor() {
    if (_isLoading || _isValidating) {
      return AppColors.darkGreen.withOpacity(0.6);
    } else if (_hasAllSideImages &&
        _sideValidation.values.whereType<SunglassesValidationResult>().length == _FrameSide.values.length &&
        _sideValidation.values.whereType<SunglassesValidationResult>().every((r) => r.isAccepted && r.confidence >= 0.7)) {
      return AppColors.darkGreen;
    } else if (_sideValidation.values.whereType<SunglassesValidationResult>().any((r) => !r.isAccepted || r.confidence < 0.7)) {
      return Colors.grey;
    } else {
      return AppColors.darkGreen;
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
    } else if (_sideValidation.values.whereType<SunglassesValidationResult>().any((r) => !r.isAccepted || r.confidence < 0.7)) {
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
    } else if (_hasAllSideImages &&
        _sideValidation.values.whereType<SunglassesValidationResult>().length == _FrameSide.values.length &&
        _sideValidation.values.whereType<SunglassesValidationResult>().every((r) => r.isAccepted && r.confidence >= 0.7)) {
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
