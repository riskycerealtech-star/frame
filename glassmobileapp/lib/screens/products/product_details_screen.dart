import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../constants/colors.dart';
import '../../config/app_router.dart';
import '../../constants/routes.dart';
import '../../config/theme_controller.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  bool _isExpanded = false;
  int _selectedImageIndex = 0;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  String _shareLink() {
    final name = (widget.product['name'] ?? 'Frame').toString();
    final fromData = widget.product['shareUrl']?.toString();
    if (fromData != null && fromData.trim().isNotEmpty) return fromData.trim();
    return 'https://frame.com/product?name=${Uri.encodeComponent(name)}';
  }

  Future<void> _shareToAnyApp() async {
    final link = _shareLink();
    await Share.share(link, subject: 'Frame Details');
  }

  void _showShareDialog() {
    final isTablet = MediaQuery.of(context).size.width > 600;

    showDialog<void>(
      context: context,
      builder: (context) {
        Widget shareItem({
          required IconData icon,
          required String label,
          required Color color,
        }) {
          final labelColor = Colors.white.withOpacity(0.75);
          return InkWell(
            onTap: () async {
              Navigator.of(context).pop();
              await _shareToAnyApp();
            },
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: isTablet ? 52 : 48,
                    height: isTablet ? 52 : 48,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border, width: 1),
                    ),
                    child: Center(
                      child: FaIcon(
                        icon,
                        color: color,
                        size: isTablet ? 26 : 24,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: isTablet ? 12 : 11,
                      color: labelColor,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        }

        return Dialog(
          backgroundColor: const Color(0xFF30363D),
          insetPadding: EdgeInsets.symmetric(horizontal: isTablet ? 18 : 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: EdgeInsets.fromLTRB(isTablet ? 18 : 14, isTablet ? 16 : 14, isTablet ? 18 : 14, isTablet ? 14 : 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Share with a friend',
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      color: Colors.white70,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: isTablet ? 110 : 104,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        shareItem(
                          icon: FontAwesomeIcons.whatsapp,
                          label: 'WhatsApp',
                          color: const Color(0xFF25D366),
                        ),
                        shareItem(
                          icon: FontAwesomeIcons.facebookMessenger,
                          label: 'Messenger',
                          color: const Color(0xFF0084FF),
                        ),
                        shareItem(
                          icon: FontAwesomeIcons.instagram,
                          label: 'Instagram',
                          color: const Color(0xFFE1306C),
                        ),
                        shareItem(
                          icon: FontAwesomeIcons.tiktok,
                          label: 'TikTok',
                          color: const Color(0xFF000000),
                        ),
                        shareItem(
                          icon: FontAwesomeIcons.snapchat,
                          label: 'Snapchat',
                          color: const Color(0xFFFFFC00),
                        ),
                        shareItem(
                          icon: FontAwesomeIcons.envelope,
                          label: 'Gmail',
                          color: const Color(0xFFEA4335),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  // Get list of product images (supporting both single image and multiple images)
  // For testing: Always display 4 thumbnails
  List<String> get _productImages {
    List<String> images = [];
    
    if (widget.product['images'] != null && widget.product['images'] is List) {
      images = List<String>.from(widget.product['images']);
    } else if (widget.product['image'] != null) {
      // If only single image, duplicate it to create 4 thumbnails for testing
      String singleImage = widget.product['image'];
      images = [singleImage, singleImage, singleImage, singleImage];
    }
    
    // Ensure we have at least 4 images for testing (duplicate the last one if needed)
    if (images.isNotEmpty && images.length < 4) {
      String lastImage = images.last;
      while (images.length < 4) {
        images.add(lastImage);
      }
    }
    
    return images;
  }

  // Get truncated product name (max 24 characters including spaces)
  String _getTruncatedProductName() {
    final productName = widget.product['name']?.toString() ?? '';
    if (productName.length <= 24) {
      return productName;
    }
    return '${productName.substring(0, 24)}...';
  }

  // Show login dialog
  void _showLoginDialog() {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    bool isLoginHovering = false;
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: appThemeMode,
          builder: (context, mode, _) {
            final isDarkDialog = mode == ThemeMode.dark || 
                                (mode == ThemeMode.system && 
                                 MediaQuery.of(context).platformBrightness == Brightness.dark);
            return StatefulBuilder(
              builder: (context, setModalState) {
                return Dialog(
                  backgroundColor: isDarkDialog ? AppColors.darkGrey : AppColors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: EdgeInsets.all(isTablet ? 24.0 : 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                // Icon
                Container(
                  width: isTablet ? 80.0 : 70.0,
                  height: isTablet ? 80.0 : 70.0,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_outline,
                    size: isTablet ? 40.0 : 35.0,
                    color: AppColors.primary,
                  ),
                ),
                
                SizedBox(height: isTablet ? 20.0 : 16.0),
                
                // Title
                Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: isTablet ? 22.0 : 20.0,
                    fontWeight: FontWeight.bold,
                    color: isDarkDialog ? AppColors.white : AppColors.textPrimary,
                  ),
                ),
                
                SizedBox(height: isTablet ? 12.0 : 10.0),
                
                // Message
                Text(
                  'Choose an option to continue your purchase.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isTablet ? 16.0 : 14.0,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                
                SizedBox(height: isTablet ? 24.0 : 20.0),
                
                // Options (2 rows, centered)
                SizedBox(
                  width: double.infinity,
                  child: Column(
                  children: [
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                            AppRouter.pushNamed(
                              context,
                              AppRoutes.buyFrame,
                              arguments: {'product': widget.product},
                            );
                        },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue,
                            side: const BorderSide(color: Colors.blue, width: 2),
                          padding: EdgeInsets.symmetric(
                            vertical: isTablet ? 14.0 : 12.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                            'Check out as Guest',
                          style: TextStyle(
                            fontSize: isTablet ? 16.0 : 14.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                      SizedBox(height: isTablet ? 12.0 : 10.0),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                            AppRouter.pushNamed(context, AppRoutes.signup);
                        },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: isTablet ? 14.0 : 12.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                            elevation: 0,
                        ),
                        child: Text(
                            'Create Account',
                          style: TextStyle(
                            fontSize: isTablet ? 16.0 : 14.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                      SizedBox(height: isTablet ? 10.0 : 8.0),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          AppRouter.pushNamed(context, AppRoutes.signin);
                        },
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: isTablet ? 14.0 : 13.0,
                              decoration: TextDecoration.none,
                            ),
                            children: [
                              TextSpan(
                                text: 'Already have an account? ',
                                style: const TextStyle(color: Colors.black),
                              ),
                              WidgetSpan(
                                alignment: PlaceholderAlignment.baseline,
                                baseline: TextBaseline.alphabetic,
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  onEnter: (_) => setModalState(() => isLoginHovering = true),
                                  onExit: (_) => setModalState(() => isLoginHovering = false),
                                  child: Text(
                                    'Login',
                                    style: TextStyle(
                                      color: Colors.red,
                                      decoration: isLoginHovering ? TextDecoration.underline : TextDecoration.none,
                                      decorationColor: Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: isTablet ? 14.0 : 13.0,
                          ),
                        ),
                      ),
                  ],
                  ),
                ),
              ],
            ),
          ),
            );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final isTablet = screenWidth > 600;
    // Match _buildImageGallery's effective height (main image + outer padding).
    // This prevents the header from overflowing and covering the scroll content.
    final headerHeight = isTablet ? (400.0 + 32.0) : (320.0 + 24.0);

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeMode,
      builder: (context, mode, _) {
        // Determine if dark mode based on theme mode
        final isDark = mode == ThemeMode.dark || 
                      (mode == ThemeMode.system && 
                       MediaQuery.of(context).platformBrightness == Brightness.dark);
        
        return Scaffold(
          backgroundColor: isDark ? AppColors.darkGrey : AppColors.white,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showLoginDialog,
        backgroundColor: isDark ? AppColors.darkGrey : AppColors.white,
        foregroundColor: const Color(0xFFD93211),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: Color(0xFFD93211),
            width: 2,
          ),
        ),
        label: const Text('Buy Now'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.primary : AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 8,
        title: Text(
          'Frame Details',
          style: TextStyle(
            fontSize: isTablet ? 20.0 : 18.0,
            fontWeight: FontWeight.normal,
          ),
        ),
        leading: IconButton(
          onPressed: () => AppRouter.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.share,
              color: AppColors.white,
              size: isTablet ? 24.0 : 22.0,
            ),
            onPressed: () {
              _showShareDialog();
            },
          ),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _FixedHeaderDelegate(
              height: headerHeight,
              child: Material(
                color: isDark ? AppColors.darkGrey : AppColors.white,
                elevation: 0,
                clipBehavior: Clip.hardEdge,
                child: _buildImageGallery(isTablet),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: isDark ? AppColors.darkGrey : AppColors.white,
              child: Padding(
              padding: EdgeInsets.fromLTRB(
                isTablet ? 24.0 : 16.0,
                isTablet ? 8.0 : 6.0,
                isTablet ? 24.0 : 16.0,
                  // extra bottom padding so FAB doesn't cover content
                  (isTablet ? 24.0 : 16.0) + 90.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    _getTruncatedProductName(),
                    style: TextStyle(
                      fontSize: isTablet ? 28.0 : 24.0,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.white : AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: isTablet ? 24.0 : 20.0),

                  // Product Description and Price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description title and Price in same row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Description',
                            style: TextStyle(
                              fontSize: isTablet ? 20.0 : 18.0,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.white : AppColors.textPrimary,
                            ),
                          ),
                          _buildPriceDisplay(isTablet),
                        ],
                      ),
                      SizedBox(height: isTablet ? 12.0 : 8.0),
                      // Full width description
                      _buildExpandableDescription(isTablet),
                    ],
                  ),

                  SizedBox(height: isTablet ? 24.0 : 20.0),

                  // (Features section removed)

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _showLoginDialog();
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
                          ),
                          child: Text(
                            'Add to Cart',
                            style: TextStyle(
                              fontSize: isTablet ? 16.0 : 14.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: isTablet ? 16.0 : 12.0),

                  // Static comments (UI only)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Comments',
                      style: TextStyle(
                        fontSize: isTablet ? 16.0 : 14.0,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  SizedBox(height: isTablet ? 10.0 : 8.0),
                  ..._buildStaticComments(isTablet, isDark),
                  SizedBox(height: isTablet ? 16.0 : 12.0),

                  // Comment box + button (UI only)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Comment',
                      style: TextStyle(
                        fontSize: isTablet ? 16.0 : 14.0,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  SizedBox(height: isTablet ? 10.0 : 8.0),
                  TextField(
                    controller: _commentController,
                    maxLines: 4,
                    cursorColor: isDark ? AppColors.white : Colors.black,
                    decoration: InputDecoration(
                      hintText: 'Write your comment...',
                      hintStyle: TextStyle(
                        color: AppColors.textSecondary.withOpacity(0.7),
                      ),
                      fillColor: isDark ? AppColors.darkGrey : AppColors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: isDark ? AppColors.white : Colors.black, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: isDark ? AppColors.white : Colors.black, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: isDark ? AppColors.white : Colors.black, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    style: TextStyle(color: isDark ? AppColors.white : Colors.black),
                  ),
                  SizedBox(height: isTablet ? 12.0 : 10.0),
                  SizedBox(
                    width: double.infinity,
                    height: isTablet ? 52.0 : 48.0,
                    child: ElevatedButton(
                      onPressed: () {
                        final text = _commentController.text.trim();
                        if (text.isEmpty) return;
                        _commentController.clear();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Comment submitted'),
                            backgroundColor: AppColors.primary,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkGreen,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: Text(
                        'Post Comment',
                        style: TextStyle(
                          fontSize: isTablet ? 15.0 : 14.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: isTablet ? 24.0 : 20.0),
                ],
              ),
            ),
        ),
          ),
        ],
      ),
        );
      },
    );
  }

  Widget _buildImageGallery(bool isTablet) {
    if (_productImages.isEmpty) {
      return SizedBox(
        width: double.infinity,
        height: isTablet ? 320 : 280,
        child: Container(
          color: AppColors.primary.withOpacity(0.1),
          child: Center(
            child: Icon(
              Icons.image,
              size: 80,
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(isTablet ? 16.0 : 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail Images (Left Side) - Always show if there are images
          Container(
            width: isTablet ? 80.0 : 70.0,
            margin: EdgeInsets.only(right: isTablet ? 16.0 : 12.0),
            child: SizedBox(
              height: isTablet ? 400 : 320,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _productImages.length,
                itemBuilder: (context, index) {
                  final imagePath = _productImages[index];
                  final isSelected = index == _selectedImageIndex;
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedImageIndex = index;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: isTablet ? 12.0 : 10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                          width: isSelected ? 2.5 : 1.0,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: Image.asset(
                          imagePath,
                          width: double.infinity,
                          height: isTablet ? 80.0 : 70.0,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: double.infinity,
                              height: isTablet ? 80.0 : 70.0,
                              color: AppColors.primary.withOpacity(0.1),
                              child: Icon(
                                Icons.image,
                                size: 30,
                                color: AppColors.primary,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Main Image Display Area
          Expanded(
            child: Container(
              height: isTablet ? 400 : 320,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.border,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(11),
                        topRight: Radius.circular(11),
                      ),
                      child: Image.asset(
                        _productImages[_selectedImageIndex],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.primary.withOpacity(0.1),
                            child: Center(
                              child: Icon(
                                Icons.image,
                                size: 80,
                                color: AppColors.primary,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Small text below the image
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 8.0 : 6.0,
                      vertical: isTablet ? 6.0 : 4.0,
                    ),
                    child: _buildReviewCount(isTablet),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _getStarRating() {
    // Use rating from product data if present; otherwise derive a stable mock.
    final fromData = widget.product['rating'];
    final parsed = fromData is num ? fromData.toDouble() : double.tryParse((fromData ?? '').toString());
    if (parsed != null && parsed > 0) return parsed.clamp(0.0, 5.0);

    final productName = (widget.product['name'] ?? '').toString();
    final hash = productName.hashCode.abs();
    final rating = 3.6 + ((hash % 15) * 0.1); // 3.6 .. 5.0
    return rating > 5.0 ? 5.0 : rating;
  }

  Widget _buildReviewCount(bool isTablet) {
    final rating = _getStarRating();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star,
          size: isTablet ? 16.0 : 14.0,
          color: Colors.amber.shade700,
        ),
        SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: isTablet ? 12.0 : 11.0,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildExpandableDescription(bool isTablet) {
    const String fullDescription = 'Premium quality sunglasses with frame. Perfect for outdoor activities, driving, and fashion. Features UV protection and comfortable fit.';
    const String shortDescription = 'Premium quality sunglasses with frame. Perfect for outdoor activities...';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isExpanded ? fullDescription : shortDescription,
          style: TextStyle(
            fontSize: isTablet ? 16.0 : 14.0,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Text(
            _isExpanded ? 'Read less' : 'Read more',
            style: TextStyle(
              fontSize: isTablet ? 14.0 : 12.0,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildStaticComments(bool isTablet, bool isDark) {
    final comments = <Map<String, dynamic>>[
      {
        'name': 'Deodate',
        'stars': 5,
        'text': 'Great quality and very comfortable. Looks exactly like the photos.',
        'date': '2 days ago',
      },
      {
        'name': 'Drew',
        'stars': 4,
        'text': 'Nice frame, fast delivery. Packaging could be better but overall good.',
        'date': '1 week ago',
      },
      {
        'name': 'Mugenzi',
        'stars': 5,
        'text': 'Perfect fit! I will definitely buy again.',
        'date': '3 weeks ago',
      },
      {
        'name': 'Andrew',
        'stars': 4,
        'text': 'Good value for the price. The frame feels solid and the lenses are clear.',
        'date': '1 month ago',
      },
    ];

    Widget starsRow(int stars) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (i) {
          final filled = i < stars;
          return Icon(
            filled ? Icons.star : Icons.star_border,
            size: isTablet ? 14 : 13,
            color: filled ? Colors.amber.shade700 : AppColors.border,
          );
        }),
      );
    }

    return comments.map((c) {
      final name = (c['name'] ?? '').toString();
      final text = (c['text'] ?? '').toString();
      final date = (c['date'] ?? '').toString();
      final stars = (c['stars'] as int?) ?? 5;

      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.all(isTablet ? 12 : 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkGrey : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? AppColors.border : AppColors.border, width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: isTablet ? 18 : 16,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                name.isEmpty ? '?' : name[0].toUpperCase(),
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: isTablet ? 14 : 13,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            color: isDark ? AppColors.white : AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: isTablet ? 13.5 : 12.5,
                          ),
                        ),
                      ),
                      Text(
                        date,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: isTablet ? 12 : 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  starsRow(stars),
                  const SizedBox(height: 6),
                  Text(
                    text,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: isTablet ? 13 : 12,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  // Get reduced price for display (original price before discount)
  double _getReducedPrice() {
    final currentPrice = (widget.product['price'] as num?)?.toDouble() ?? 0.0;
    
    // Check if reduced price is already in product data
    if (widget.product['originalPrice'] != null || widget.product['reducedPrice'] != null) {
      final originalPrice = double.tryParse(
        (widget.product['originalPrice'] ?? widget.product['reducedPrice']).toString()
      );
      if (originalPrice != null && originalPrice > currentPrice) {
        return originalPrice;
      }
    }
    
    // Generate reduced price (20-40% higher than current price)
    final productName = widget.product['name'] ?? '';
    final hash = productName.hashCode.abs();
    final discountPercent = 20.0 + (hash % 21); // 20% to 40% discount
    final reducedPrice = currentPrice / (1 - discountPercent / 100);
    return double.parse(reducedPrice.toStringAsFixed(2));
  }

  Widget _buildPriceDisplay(bool isTablet) {
    final currentPrice = (widget.product['price'] as num?)?.toDouble() ?? 0.0;
    final reducedPrice = _getReducedPrice();
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        // Reduced price with strikethrough
        Text(
          '\$${reducedPrice.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isTablet ? 24.0 : 20.0,
            fontWeight: FontWeight.normal,
            color: Colors.grey,
            decoration: TextDecoration.lineThrough,
            decorationColor: Colors.grey,
          ),
        ),
        SizedBox(width: 8),
        // Current price
        Text(
          '\$${currentPrice.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isTablet ? 32.0 : 28.0,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  // (Features section removed)
}

class _FixedHeaderDelegate extends SliverPersistentHeaderDelegate {
  _FixedHeaderDelegate({
    required this.height,
    required this.child,
  });

  final double height;
  final Widget child;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(covariant _FixedHeaderDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}
