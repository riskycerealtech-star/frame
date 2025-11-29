import 'package:flutter/material.dart';
import 'dart:async';
import '../../config/app_router.dart';
import '../../constants/routes.dart';
import '../../constants/colors.dart';
import '../../constants/app_constants.dart';
import '../../widgets/common/bottom_navigation_bar_widget.dart';
import '../../widgets/common/commission_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;
  Timer? _autoScrollTimer;
  String _selectedColor = 'All'; // Track selected color filter
  bool _isSearchVisible = false; // Track search input visibility
  bool _isLoading = false; // Track loading state
  int _visibleItems = 4; // Track visible items (2 rows x 2 columns)
  bool _isPriceRangeVisible = false; // Track price range search visibility
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  
  // Bottom navigation
  int _currentBottomNavIndex = 0;
  
  // Commission dialog state
  final bool _isFirstRowOccupied = false;

  // List of hero images with product info and colors
  final List<Map<String, dynamic>> _heroImages = [
    {'image': 'asset/images/a.jpg', 'name': 'Classic Aviator', 'price': 45, 'color': 'Black'},
    {'image': 'asset/images/ab.jpg', 'name': 'Sport Sunglasses', 'price': 35, 'color': 'Green'},
    {'image': 'asset/images/B.webp', 'name': 'Vintage Round', 'price': 55, 'color': 'Blue'},
    {'image': 'asset/images/c.webp', 'name': 'Modern Square', 'price': 40, 'color': 'Red'},
    {'image': 'asset/images/d.jpeg', 'name': 'Luxury Designer', 'price': 120, 'color': 'Brown'},
    {'image': 'asset/images/d.jpg', 'name': 'Casual Shades', 'price': 25, 'color': 'Gray'},
    {'image': 'asset/images/f.webp', 'name': 'Polarized Pro', 'price': 65, 'color': 'White'},
    {'image': 'asset/images/gt.webp', 'name': 'Gradient Style', 'price': 50, 'color': 'Purple'},
    {'image': 'asset/images/hy.jpg', 'name': 'High Fashion', 'price': 85, 'color': 'Black'},
    {'image': 'asset/images/j.jpg', 'name': 'Urban Explorer', 'price': 30, 'color': 'Green'},
    {'image': 'asset/images/kj.jpg', 'name': 'Retro Classic', 'price': 45, 'color': 'Blue'},
    {'image': 'asset/images/kj.png', 'name': 'Minimalist', 'price': 35, 'color': 'Red'},
    {'image': 'asset/images/m.jpg', 'name': 'Premium Metal', 'price': 75, 'color': 'Brown'},
    {'image': 'asset/images/mn.jpg', 'name': 'Trendy Frame', 'price': 40, 'color': 'Gray'},
    {'image': 'asset/images/n.jpeg', 'name': 'Elegant Style', 'price': 60, 'color': 'White'},
    {'image': 'asset/images/one.webp', 'name': 'Unique Design', 'price': 55, 'color': 'Purple'},
    {'image': 'asset/images/p.jpeg', 'name': 'Professional', 'price': 70, 'color': 'Black'},
    {'image': 'asset/images/po.jpg', 'name': 'Fashion Forward', 'price': 50, 'color': 'Green'},
    {'image': 'asset/images/vb.webp', 'name': 'Vintage Blue', 'price': 45, 'color': 'Blue'},
    {'image': 'asset/images/x.jpeg', 'name': 'Exclusive Model', 'price': 90, 'color': 'Red'},
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        int nextIndex = (_currentImageIndex + 1) % _heroImages.length;
        _pageController.animateToPage(
          nextIndex,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
  }

  void _scrollToPrevious() {
    if (_pageController.hasClients) {
      int previousIndex = (_currentImageIndex - 1 + _heroImages.length) % _heroImages.length;
      _pageController.animateToPage(
        previousIndex,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _scrollToNext() {
    if (_pageController.hasClients) {
      int nextIndex = (_currentImageIndex + 1) % _heroImages.length;
      _pageController.animateToPage(
        nextIndex,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Get filtered products based on selected color
  List<Map<String, dynamic>> _getFilteredProducts() {
    if (_selectedColor == 'All') {
      return _heroImages;
    }
    return _heroImages.where((product) => product['color'] == _selectedColor).toList();
  }

  // Handle color filter selection with loading animation
  void _onColorFilterSelected(String colorName) async {
    setState(() {
      _isLoading = true;
    });
    
    // Simulate loading delay
    await Future.delayed(Duration(milliseconds: 800));
    
    setState(() {
      _selectedColor = colorName;
      _isLoading = false;
      _visibleItems = 4; // Reset to 2 rows when filtering
    });
  }

  // Load more items
  void _loadMoreItems() {
    setState(() {
      _visibleItems += 2; // Add 1 more row (2 items)
    });
  }

  // Toggle search input visibility
  void _toggleSearchVisibility() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (_isSearchVisible) {
        _isPriceRangeVisible = false; // Hide price range when text search is shown
      }
    });
  }

  // Toggle price range search visibility
  void _togglePriceRangeVisibility() {
    setState(() {
      _isPriceRangeVisible = !_isPriceRangeVisible;
      if (_isPriceRangeVisible) {
        _isSearchVisible = false; // Hide text search when price range is shown
      }
    });
  }

  // Handle price range search
  void _handlePriceRangeSearch() {
    final minPrice = _minPriceController.text.trim();
    final maxPrice = _maxPriceController.text.trim();
    
    if (minPrice.isEmpty || maxPrice.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter both minimum and maximum prices'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    final min = int.tryParse(minPrice);
    final max = int.tryParse(maxPrice);
    
    if (min == null || max == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter valid numbers'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    if (min > max) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Minimum price cannot be greater than maximum price'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    // Here you would implement the actual price filtering logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Searching for products between \$$min and \$$max'),
        backgroundColor: AppColors.primary,
        duration: Duration(seconds: 2),
      ),
    );
  }

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
            // Profile Picture
            GestureDetector(
              onTap: () {
              AppRouter.pushNamed(context, AppRoutes.profile);
            },
              child: CircleAvatar(
                radius: isTablet ? 20.0 : 18.0,
                backgroundColor: AppColors.white,
                child: CircleAvatar(
                  radius: isTablet ? 18.0 : 16.0,
                  backgroundImage: AssetImage('asset/images/n.jpeg'),
                  onBackgroundImageError: (exception, stackTrace) {
                    // Fallback to initials if image fails
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                    child: Center(
                      child: Text(
                        'E',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: isTablet ? 16.0 : 14.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            SizedBox(width: 12),
            
            // Greeting Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Good morning,',
                    style: TextStyle(
                      fontSize: isTablet ? 14.0 : 12.0,
                      color: AppColors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    'Drew',
                    style: TextStyle(
                      fontSize: isTablet ? 18.0 : 16.0,
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
          ),
        ],
      ),
            ),
            
            
            // Notification Icon
            GestureDetector(
              onTap: () {
                // Handle notification tap
              },
              child: Container(
                padding: EdgeInsets.all(8),
                child: Stack(
                  children: [
                    Icon(
                      Icons.notifications_outlined,
                      size: isTablet ? 24.0 : 22.0,
                      color: AppColors.white,
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Image Carousel
            SizedBox(
              width: double.infinity,
              height: isTablet ? 300 : 250,
              child: Stack(
                children: [
                  // PageView for images
                  PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemCount: _heroImages.length,
                    itemBuilder: (context, index) {
                      final imageData = _heroImages[index];
                      return Stack(
                        children: [
                          // Image
                          Image.asset(
                            imageData['image'],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: AppColors.primary.withOpacity(0.1),
                                child: Center(
                                  child: Icon(
                                    Icons.image,
                                    size: 60,
                                    color: AppColors.primary,
                                  ),
                                ),
                              );
                            },
                          ),
                          
                          // Text Overlay
                          Positioned(
                            bottom: 20,
                            left: 20,
                            right: 20,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  imageData['name'],
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: isTablet ? 18.0 : 16.0,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        color: Colors.white,
                                        blurRadius: 2,
                                        offset: Offset(1, 1),
                                      ),
                                    ],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '\$${imageData['price']} USD',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: isTablet ? 16.0 : 14.0,
                                    fontWeight: FontWeight.w600,
                                    shadows: [
                                      Shadow(
                                        color: Colors.white,
                                        blurRadius: 2,
                                        offset: Offset(1, 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  
                  // Left Navigation Button
                  Positioned(
                    left: 16,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          _stopAutoScroll();
                          _scrollToPrevious();
                          _startAutoScroll();
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.chevron_left,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Right Navigation Button
                  Positioned(
                    right: 16,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          _stopAutoScroll();
                          _scrollToNext();
                          _startAutoScroll();
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Page Indicators
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _heroImages.length,
                        (index) => Container(
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentImageIndex == index
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Divider
            Container(
              height: 2,
              color: Colors.black,
              width: double.infinity,
            ),
            
            // Search Input (Conditional)
            if (_isSearchVisible)
              Padding(
                padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
                    border: Border.all(
                      color: Colors.grey,
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
                  child: TextField(
                    style: TextStyle(
                      fontSize: isTablet ? 16.0 : 14.0,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search sunglasses...',
                      hintStyle: TextStyle(
                        color: AppColors.textSecondary.withOpacity(0.6),
                        fontSize: isTablet ? 16.0 : 14.0,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColors.textSecondary,
                        size: isTablet ? 24.0 : 22.0,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          Icons.close,
                          color: AppColors.textSecondary,
                          size: isTablet ? 24.0 : 22.0,
                        ),
                        onPressed: () {
                          _toggleSearchVisibility();
                        },
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 20.0 : 16.0,
                        vertical: isTablet ? 18.0 : 14.0,
                      ),
                    ),
                    onChanged: (value) {
                      // Handle search input
                    },
                    onSubmitted: (value) {
                      // Handle search submission
                    },
                  ),
                ),
              ),
            
            // Fixed Color Filter Buttons
            Container(
              color: AppColors.white,
              padding: EdgeInsets.only(
                left: isTablet ? 24.0 : 16.0,
                right: isTablet ? 24.0 : 16.0,
                top: _isSearchVisible ? 0 : 5.0,
                bottom: 0,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildColorButton('All', AppColors.primary, isTablet, isSelected: _selectedColor == 'All'),
                    SizedBox(width: 12),
                    _buildSearchButton(isTablet),
                    SizedBox(width: 12),
                    _buildColorButton('Black', Colors.black, isTablet, isSelected: _selectedColor == 'Black'),
                    SizedBox(width: 12),
                    _buildColorButton('Green', Colors.green, isTablet, isSelected: _selectedColor == 'Green'),
                    SizedBox(width: 12),
                    _buildColorButton('Blue', Colors.blue, isTablet, isSelected: _selectedColor == 'Blue'),
                    SizedBox(width: 12),
                    _buildColorButton('Red', Colors.red, isTablet, isSelected: _selectedColor == 'Red'),
                    SizedBox(width: 12),
                    _buildColorButton('Brown', Colors.brown, isTablet, isSelected: _selectedColor == 'Brown'),
                    SizedBox(width: 12),
                    _buildColorButton('Gray', Colors.grey, isTablet, isSelected: _selectedColor == 'Gray'),
                    SizedBox(width: 12),
                    _buildColorButton('White', Colors.white, isTablet, isSelected: _selectedColor == 'White'),
                    SizedBox(width: 12),
                    _buildColorButton('Purple', Colors.purple, isTablet, isSelected: _selectedColor == 'Purple'),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: isTablet ? 24.0 : 16.0),
            
            // Product Count Display
            if (_selectedColor != 'All')
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isTablet ? 24.0 : 16.0),
                child: _buildProductCount(isTablet),
              ),
            
            // Search by Range Price Button (when All is selected and search is hidden)
            if (_selectedColor == 'All' && !_isSearchVisible && !_isPriceRangeVisible)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isTablet ? 24.0 : 16.0),
                child: _buildPriceRangeButton(isTablet),
              ),
            
            // Price Range Search Inputs (when price range is visible)
            if (_isPriceRangeVisible)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isTablet ? 24.0 : 16.0),
                child: _buildPriceRangeInputs(isTablet),
              ),
            
            SizedBox(height: isTablet ? 16.0 : 12.0),
            
            // Product Cards Grid
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isTablet ? 24.0 : 16.0),
              child: _buildProductGrid(isTablet),
            ),
            
            SizedBox(height: isTablet ? 24.0 : 16.0),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        currentIndex: _currentBottomNavIndex,
        onTap: (index) {
          setState(() {
            _currentBottomNavIndex = index;
          });
          
          // Handle custom navigation for Add button
          if (index == 3) { // Add button index
            _showCommissionDialog();
          }
        },
      ),
    );
  }

  void _showCommissionDialog() {
    print('🔵 COMMISSION DIALOG - Opening commission dialog');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CommissionDialog(
          onCommissionSelected: (tier) {
            print('✅ COMMISSION SELECTED - Tier: $tier');
            print('🚀 NAVIGATING - To product register screen');
            // Close dialog first, then navigate
            Navigator.of(context).pop();
            // Small delay to ensure dialog closes completely
            Future.delayed(Duration(milliseconds: 100), () {
              // Navigate to product register screen with commission tier
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

  Widget _buildSearchButton(bool isTablet) {
    return GestureDetector(
      onTap: () {
        _toggleSearchVisibility();
      },
      child: Container(
        width: isTablet ? 50.0 : 45.0,
        height: isTablet ? 40.0 : 36.0,
        decoration: BoxDecoration(
          color: _isSearchVisible ? Colors.red : Colors.green.shade700,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          _isSearchVisible ? Icons.close : Icons.search,
          color: Colors.white,
          size: isTablet ? 20.0 : 18.0,
        ),
      ),
    );
  }

  Widget _buildColorButton(String colorName, Color color, bool isTablet, {bool isSelected = false}) {
    return GestureDetector(
      onTap: () {
        _onColorFilterSelected(colorName);
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 16.0 : 12.0,
          vertical: isTablet ? 10.0 : 8.0,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.8) : color,
          borderRadius: BorderRadius.circular(4),
          border: color == Colors.white 
              ? Border.all(color: AppColors.border, width: 1)
              : isSelected 
                  ? Border.all(color: color == AppColors.primary ? Colors.green : Colors.black, width: 2)
                  : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          colorName,
          style: TextStyle(
            color: color == Colors.black || color == Colors.blue || color == Colors.brown || color == Colors.purple || color == AppColors.primary
                ? Colors.white
                : Colors.black,
            fontSize: isTablet ? 14.0 : 12.0,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildProductCount(bool isTablet) {
    final filteredProducts = _getFilteredProducts();
    final count = filteredProducts.length;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 16.0 : 12.0,
        vertical: isTablet ? 12.0 : 8.0,
      ),
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
            Icons.inventory_2,
            color: AppColors.primary,
            size: isTablet ? 20.0 : 18.0,
          ),
          SizedBox(width: 8),
          Text(
            count == 1 ? '1 Glass' : '$count Glasses',
            style: TextStyle(
              fontSize: isTablet ? 16.0 : 14.0,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          Spacer(),
          Text(
            'in $_selectedColor',
            style: TextStyle(
              fontSize: isTablet ? 14.0 : 12.0,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRangeButton(bool isTablet) {
    return GestureDetector(
      onTap: () {
        _togglePriceRangeVisibility();
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 20.0 : 16.0,
          vertical: isTablet ? 16.0 : 12.0,
        ),
        decoration: BoxDecoration(
          color: Colors.green.shade600,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              color: Colors.white,
              size: isTablet ? 20.0 : 18.0,
            ),
            SizedBox(width: 8),
            Text(
              'Search by Range Price',
              style: TextStyle(
                color: Colors.white,
                fontSize: isTablet ? 16.0 : 14.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.arrow_forward,
              color: Colors.white,
              size: isTablet ? 18.0 : 16.0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRangeInputs(bool isTablet) {
    return Row(
      children: [
        // Min Price Input
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: Colors.grey,
                width: 1,
              ),
            ),
            child: TextField(
              controller: _minPriceController,
              keyboardType: TextInputType.number,
              style: TextStyle(
                fontSize: isTablet ? 14.0 : 12.0,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Min Price',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary.withOpacity(0.6),
                  fontSize: isTablet ? 14.0 : 12.0,
                ),
                prefixText: '\$ ',
                prefixStyle: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 12.0 : 10.0,
                  vertical: isTablet ? 12.0 : 10.0,
                ),
              ),
            ),
          ),
        ),
        
        SizedBox(width: 12),
        
        // Max Price Input
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: Colors.grey,
                width: 1,
              ),
            ),
            child: TextField(
              controller: _maxPriceController,
              keyboardType: TextInputType.number,
              style: TextStyle(
                fontSize: isTablet ? 14.0 : 12.0,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Max Price',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary.withOpacity(0.6),
                  fontSize: isTablet ? 14.0 : 12.0,
                ),
                prefixText: '\$ ',
                prefixStyle: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 12.0 : 10.0,
                  vertical: isTablet ? 12.0 : 10.0,
                ),
              ),
            ),
          ),
        ),
        
        SizedBox(width: 12),
        
        // Search Button
        GestureDetector(
          onTap: _handlePriceRangeSearch,
          child: Container(
            width: isTablet ? 50.0 : 45.0,
            height: isTablet ? 50.0 : 45.0,
            decoration: BoxDecoration(
              color: Colors.green.shade600,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.search,
              color: Colors.white,
              size: isTablet ? 20.0 : 18.0,
            ),
          ),
        ),
        
        SizedBox(width: 12),
        
        // Close Button
        GestureDetector(
          onTap: () {
            _togglePriceRangeVisibility();
          },
          child: Container(
            width: isTablet ? 50.0 : 45.0,
            height: isTablet ? 50.0 : 45.0,
            decoration: BoxDecoration(
              color: Colors.red.shade600,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.3),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.close,
              color: Colors.white,
              size: isTablet ? 20.0 : 18.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductGrid(bool isTablet) {
    // Show loading animation when filtering
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              strokeWidth: 3.0,
            ),
            SizedBox(height: 16),
            Text(
              'Loading glasses...',
              style: TextStyle(
                fontSize: isTablet ? 16.0 : 14.0,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }
    
    final filteredProducts = _getFilteredProducts();
    
    if (filteredProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: isTablet ? 80.0 : 60.0,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              'No record to display!',
              style: TextStyle(
                fontSize: isTablet ? 18.0 : 16.0,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try selecting a different color filter',
              style: TextStyle(
                fontSize: isTablet ? 14.0 : 12.0,
                color: AppColors.textSecondary.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }
    
    return Column(
              children: [
        // Product Grid
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: _visibleItems > filteredProducts.length ? filteredProducts.length : _visibleItems,
          itemBuilder: (context, index) {
            return _buildProductCard(filteredProducts[index], isTablet);
          },
        ),
        
        // Load More Button (if there are more items)
        if (_visibleItems < filteredProducts.length)
          Padding(
            padding: EdgeInsets.only(top: isTablet ? 20.0 : 16.0),
            child: _buildLoadMoreButton(isTablet),
          ),
      ],
    );
  }

  Widget _buildLoadMoreButton(bool isTablet) {
    return Center(
      child: GestureDetector(
        onTap: _loadMoreItems,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 32.0 : 24.0,
            vertical: isTablet ? 16.0 : 12.0,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.expand_more,
                color: Colors.white,
                size: isTablet ? 20.0 : 18.0,
              ),
              SizedBox(width: 8),
              Text(
                'Load More',
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
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, bool isTablet) {
    return GestureDetector(
      onTap: () {
        AppRouter.pushNamed(
          context,
          AppRoutes.productDetails,
          arguments: {'product': product},
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppConstants.defaultRadius),
                    topRight: Radius.circular(AppConstants.defaultRadius),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppConstants.defaultRadius),
                    topRight: Radius.circular(AppConstants.defaultRadius),
                  ),
                  child: Image.asset(
                    product['image'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.primary.withOpacity(0.1),
                        child: Center(
                          child: Icon(
                            Icons.image,
                            size: 40,
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            
            // Product Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(isTablet ? 8.0 : 6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'],
                      style: TextStyle(
                        fontSize: isTablet ? 14.0 : 12.0,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2),
                    Text(
                      product['color'],
                      style: TextStyle(
                        fontSize: isTablet ? 12.0 : 10.0,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${product['price']}',
                          style: TextStyle(
                            fontSize: isTablet ? 16.0 : 14.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Icon(
                          Icons.favorite_border,
                          size: isTablet ? 18.0 : 16.0,
                          color: AppColors.textSecondary,
                        ),
                      ],
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

}
