import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../config/app_router.dart';
import '../../constants/routes.dart';
import '../../widgets/common/back_button_widget.dart';

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
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
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
                  'Login Required',
                  style: TextStyle(
                    fontSize: isTablet ? 22.0 : 20.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                
                SizedBox(height: isTablet ? 12.0 : 10.0),
                
                // Message
                Text(
                  'Please login to add items to cart or make a purchase.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isTablet ? 16.0 : 14.0,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                
                SizedBox(height: isTablet ? 24.0 : 20.0),
                
                // Buttons
                Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          side: BorderSide(color: AppColors.border, width: 1),
                          padding: EdgeInsets.symmetric(
                            vertical: isTablet ? 14.0 : 12.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: isTablet ? 16.0 : 14.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(width: 12),
                    
                    // Login Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          AppRouter.pushNamed(context, AppRoutes.signin);
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
                        ),
                        child: Text(
                          'Login',
                          style: TextStyle(
                            fontSize: isTablet ? 16.0 : 14.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
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
        leadingWidth: 56,
        titleSpacing: 8,
        title: Text(
          'Flame Details',
          style: TextStyle(
            fontSize: isTablet ? 20.0 : 18.0,
            fontWeight: FontWeight.normal,
          ),
        ),
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
        actions: [
          IconButton(
            icon: Icon(
              Icons.share,
              color: AppColors.white,
              size: isTablet ? 24.0 : 22.0,
            ),
            onPressed: () {
              // Handle share
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image Gallery
            _buildImageGallery(isTablet),

            // Product Information
            Padding(
              padding: EdgeInsets.fromLTRB(
                isTablet ? 24.0 : 16.0,
                isTablet ? 8.0 : 6.0,
                isTablet ? 24.0 : 16.0,
                isTablet ? 24.0 : 16.0,
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
                      color: AppColors.textPrimary,
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
                              color: AppColors.textPrimary,
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

                  // Features and Color
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Features',
                        style: TextStyle(
                          fontSize: isTablet ? 20.0 : 18.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 12.0 : 10.0,
                          vertical: isTablet ? 6.0 : 4.0,
                        ),
                        decoration: BoxDecoration(
                          color: _getColorFromName(widget.product['color']).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _getColorFromName(widget.product['color']),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          widget.product['color'],
                          style: TextStyle(
                            fontSize: isTablet ? 14.0 : 12.0,
                            fontWeight: FontWeight.w600,
                            color: _getColorFromName(widget.product['color']),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: isTablet ? 12.0 : 8.0),

                  _buildWidthFeature(isTablet),
                  _buildShippingFeature(isTablet),
                  _buildProgressiveFeature(isTablet),
                  _buildReadingFeature(isTablet),

                  SizedBox(height: isTablet ? 24.0 : 20.0),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
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
                      SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            _showLoginDialog();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFD93211),
                            side: BorderSide(color: const Color(0xFFD93211), width: 2),
                            padding: EdgeInsets.symmetric(
                              vertical: isTablet ? 16.0 : 14.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Buy Now',
                            style: TextStyle(
                              fontSize: isTablet ? 16.0 : 14.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: isTablet ? 24.0 : 20.0),
                ],
              ),
            ),
          ],
        ),
      ),
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
            child: SingleChildScrollView(
              child: Column(
                children: _productImages.asMap().entries.map((entry) {
                  int index = entry.key;
                  String imagePath = entry.value;
                  bool isSelected = index == _selectedImageIndex;
                  
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
                }).toList(),
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
                        fit: BoxFit.contain,
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

  // Get review count for the product
  int _getReviewCount() {
    // Check if review count is already in product data
    if (widget.product['reviewCount'] != null) {
      final count = int.tryParse(widget.product['reviewCount'].toString());
      if (count != null && count > 0) {
        return count;
      }
    }
    
    // Generate review count based on product name hash for consistent display per product
    // Reviews will be between 5 and 150
    final productName = widget.product['name'] ?? '';
    final hash = productName.hashCode.abs();
    final reviewCount = 5 + (hash % 146); // 5 to 150
    return reviewCount;
  }

  Widget _buildReviewCount(bool isTablet) {
    final reviewCount = _getReviewCount();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.visibility,
          size: isTablet ? 14.0 : 12.0,
          color: Colors.orange,
        ),
        SizedBox(width: 4),
        Text(
          '$reviewCount Reviews',
          style: TextStyle(
            fontSize: isTablet ? 12.0 : 10.0,
            color: AppColors.textSecondary,
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

  // Get width value for the product
  String _getWidthValue() {
    // Check if width is already in product data
    if (widget.product['width'] != null) {
      return widget.product['width'].toString();
    }
    
    // Generate width based on product name hash for consistent display per product
    final productName = widget.product['name'] ?? '';
    final widthOptions = ['Small', 'Medium', 'Large', 'Extra Large'];
    final hash = productName.hashCode.abs();
    final widthIndex = hash % widthOptions.length;
    return widthOptions[widthIndex];
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

  Widget _buildWidthFeature(bool isTablet) {
    final widthValue = _getWidthValue();
    return Padding(
      padding: EdgeInsets.only(bottom: isTablet ? 8.0 : 6.0),
      child: Row(
        children: [
          Icon(
            Icons.wb_sunny,
            color: AppColors.primary,
            size: isTablet ? 20.0 : 18.0,
          ),
          SizedBox(width: 12),
          Text.rich(
            TextSpan(
              text: 'Width: ',
              style: TextStyle(
                fontSize: isTablet ? 16.0 : 14.0,
                color: AppColors.textSecondary,
              ),
              children: [
                TextSpan(
                  text: widthValue,
                  style: TextStyle(
                    fontSize: isTablet ? 16.0 : 14.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Get shipping fee for the product (less than $10.00)
  double _getShippingFee() {
    // Check if shipping fee is already in product data
    if (widget.product['shippingFee'] != null) {
      final fee = double.tryParse(widget.product['shippingFee'].toString());
      if (fee != null && fee < 10.00) {
        return fee;
      }
    }
    
    // Generate shipping fee based on product name hash for consistent display per product
    // Fees will be between $2.00 and $9.99
    final productName = widget.product['name'] ?? '';
    final hash = productName.hashCode.abs();
    // Generate a fee between 2.00 and 9.99
    final baseFee = 2.00 + (hash % 800) / 100.0; // 2.00 to 9.99
    return double.parse(baseFee.toStringAsFixed(2));
  }

  Widget _buildShippingFeature(bool isTablet) {
    final shippingFee = _getShippingFee();
    return Padding(
      padding: EdgeInsets.only(bottom: isTablet ? 8.0 : 6.0),
      child: Row(
        children: [
          Icon(
            Icons.local_shipping,
            color: AppColors.primary,
            size: isTablet ? 20.0 : 18.0,
          ),
          SizedBox(width: 12),
          Text.rich(
            TextSpan(
              text: 'Shipping: ',
              style: TextStyle(
                fontSize: isTablet ? 16.0 : 14.0,
                color: AppColors.textSecondary,
              ),
              children: [
                TextSpan(
                  text: '\$${shippingFee.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: isTablet ? 16.0 : 14.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Get bifocal type for the product
  String _getBifocalType() {
    // Check if bifocal type is already in product data
    if (widget.product['bifocalType'] != null) {
      return widget.product['bifocalType'].toString();
    }
    
    // Generate bifocal type based on product name hash for consistent display per product
    final productName = widget.product['name'] ?? '';
    final bifocalOptions = ['Bifocal', 'Trifocal', 'Progressive', 'Single Vision'];
    final hash = productName.hashCode.abs();
    final bifocalIndex = hash % bifocalOptions.length;
    return bifocalOptions[bifocalIndex];
  }

  Widget _buildProgressiveFeature(bool isTablet) {
    final bifocalType = _getBifocalType();
    return Padding(
      padding: EdgeInsets.only(bottom: isTablet ? 8.0 : 6.0),
      child: Row(
        children: [
          Icon(
            Icons.fitness_center,
            color: AppColors.primary,
            size: isTablet ? 20.0 : 18.0,
          ),
          SizedBox(width: 12),
          Text.rich(
            TextSpan(
              text: 'Progressive: ',
              style: TextStyle(
                fontSize: isTablet ? 16.0 : 14.0,
                color: AppColors.textSecondary,
              ),
              children: [
                TextSpan(
                  text: bifocalType,
                  style: TextStyle(
                    fontSize: isTablet ? 16.0 : 14.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Get reading type for the product
  String _getReadingType() {
    // Check if reading type is already in product data
    if (widget.product['readingType'] != null) {
      return widget.product['readingType'].toString();
    }
    
    // Generate reading type based on product name hash for consistent display per product
    final productName = widget.product['name'] ?? '';
    final readingOptions = ['Single Vision', 'Bifocal', 'Progressive', 'Trifocal', 'Reading'];
    final hash = productName.hashCode.abs();
    final readingIndex = hash % readingOptions.length;
    return readingOptions[readingIndex];
  }

  Widget _buildReadingFeature(bool isTablet) {
    final readingType = _getReadingType();
    return Padding(
      padding: EdgeInsets.only(bottom: isTablet ? 8.0 : 6.0),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: AppColors.primary,
            size: isTablet ? 20.0 : 18.0,
          ),
          SizedBox(width: 12),
          Text.rich(
            TextSpan(
              text: 'Reading: ',
              style: TextStyle(
                fontSize: isTablet ? 16.0 : 14.0,
                color: AppColors.textSecondary,
              ),
              children: [
                TextSpan(
                  text: readingType,
                  style: TextStyle(
                    fontSize: isTablet ? 16.0 : 14.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String feature, IconData icon, bool isTablet) {
    return Padding(
      padding: EdgeInsets.only(bottom: isTablet ? 8.0 : 6.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: isTablet ? 20.0 : 18.0,
          ),
          SizedBox(width: 12),
          Text(
            feature,
            style: TextStyle(
              fontSize: isTablet ? 16.0 : 14.0,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorFromName(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'black':
        return Colors.black;
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      case 'red':
        return Colors.red;
      case 'brown':
        return Colors.brown;
      case 'gray':
        return Colors.grey;
      case 'white':
        return Colors.white;
      case 'purple':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
