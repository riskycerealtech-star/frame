import 'package:flutter/material.dart';
import 'dart:async';
import '../../config/app_router.dart';
import '../../config/theme_controller.dart';
import '../../constants/routes.dart';
import '../../constants/colors.dart';
import '../../constants/app_constants.dart';
import '../../widgets/common/bottom_navigation_bar_widget.dart';
import '../../widgets/common/app_bar_action_icons.dart';
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
  String? _selectedCategory; // Track selected category filter
  bool _isLoading = false; // Track loading state
  int _visibleItems = 4; // Track visible items (2 rows x 2 columns)
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  int? _minPrice;
  int? _maxPrice;
  static const int _notificationCount = 14;
  static const int _cartCount = 2;
  
  // Bottom navigation
  int _currentBottomNavIndex = 0;
  
  // Commission dialog state
  final bool _isFirstRowOccupied = false;

  // List of hero images with product info and colors
  final List<Map<String, dynamic>> _heroImages = [
    {'image': 'asset/images/a.jpg', 'name': 'Classic Aviator', 'price': 45, 'color': 'Black', 'heartCount': 12, 'category': 'Sunglasses'},
    {'image': 'asset/images/ab.jpg', 'name': 'Sport Sunglasses', 'price': 35, 'color': 'Green', 'heartCount': 0, 'category': 'Sunglasses'},
    {'image': 'asset/images/B.webp', 'name': 'Vintage Round', 'price': 55, 'color': 'Blue', 'heartCount': 4, 'category': 'Sunglasses'},
    {'image': 'asset/images/c.webp', 'name': 'Modern Square', 'price': 40, 'color': 'Red', 'heartCount': 8, 'category': 'Sunglasses'},
    {'image': 'asset/images/d.jpeg', 'name': 'Luxury Designer', 'price': 120, 'color': 'Brown', 'heartCount': 0, 'category': 'Sunglasses'},
    {'image': 'asset/images/d.jpg', 'name': 'Casual Shades', 'price': 25, 'color': 'Gray', 'heartCount': 2, 'category': 'Sunglasses'},
    {'image': 'asset/images/f.webp', 'name': 'Polarized Pro', 'price': 65, 'color': 'White', 'heartCount': 0, 'category': 'Sunglasses'},
    {'image': 'asset/images/gt.webp', 'name': 'Gradient Style', 'price': 50, 'color': 'Purple', 'heartCount': 15, 'category': 'Sunglasses'},
    {'image': 'asset/images/hy.jpg', 'name': 'High Fashion', 'price': 85, 'color': 'Black', 'heartCount': 0, 'category': 'Sunglasses'},
    {'image': 'asset/images/j.jpg', 'name': 'Urban Explorer', 'price': 30, 'color': 'Green', 'heartCount': 5, 'category': 'Sunglasses'},
    {'image': 'asset/images/kj.jpg', 'name': 'Retro Classic', 'price': 45, 'color': 'Blue', 'heartCount': 0, 'category': 'Sunglasses'},
    {'image': 'asset/images/kj.png', 'name': 'Minimalist', 'price': 35, 'color': 'Red', 'heartCount': 9, 'category': 'Sunglasses'},
    {'image': 'asset/images/m.jpg', 'name': 'Premium Metal', 'price': 75, 'color': 'Brown', 'heartCount': 0, 'category': 'Sunglasses'},
    {'image': 'asset/images/mn.jpg', 'name': 'Trendy Frame', 'price': 40, 'color': 'Gray', 'heartCount': 3, 'category': 'Sunglasses'},
    {'image': 'asset/images/n.jpeg', 'name': 'Elegant Style', 'price': 60, 'color': 'White', 'heartCount': 0, 'category': 'Sunglasses'},
    {'image': 'asset/images/one.webp', 'name': 'Unique Design', 'price': 55, 'color': 'Purple', 'heartCount': 7, 'category': 'Sunglasses'},
    {'image': 'asset/images/p.jpeg', 'name': 'Professional', 'price': 70, 'color': 'Black', 'heartCount': 0, 'category': 'Sunglasses'},
    {'image': 'asset/images/po.jpg', 'name': 'Fashion Forward', 'price': 50, 'color': 'Green', 'heartCount': 11, 'category': 'Sunglasses'},
    {'image': 'asset/images/vb.webp', 'name': 'Vintage Blue', 'price': 45, 'color': 'Blue', 'heartCount': 0, 'category': 'Sunglasses'},
    {'image': 'asset/images/x.jpeg', 'name': 'Exclusive Model', 'price': 90, 'color': 'Red', 'heartCount': 6, 'category': 'Sunglasses'},
  ];

  double _mockStarRatingFor(Map<String, dynamic> product) {
    // UI-only mock rating derived from heartCount for consistency per card.
    final hc = (product['heartCount'] as num?)?.toInt() ?? 0;
    final rating = 3.6 + ((hc % 15) * 0.1); // 3.6 .. 5.0
    return rating > 5.0 ? 5.0 : rating;
  }

  String _greetingForNow() {
    final hour = DateTime.now().hour; // 0..23
    if (hour < 12) return 'Good Morning';
    if (hour < 18) return 'Good Afternoon';
    return 'Good Evening';
  }

  static const String _displayName = 'Andrew';

  String _displayNameMax10() {
    final name = _displayName.trim();
    if (name.length <= 10) return name;
    return name.substring(0, 10);
  }

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
    Iterable<Map<String, dynamic>> list = _heroImages;

    // Filter by price range (if set)
    if (_minPrice != null) {
      list = list.where((p) => (p['price'] as num?) != null && (p['price'] as num) >= _minPrice!);
    }
    if (_maxPrice != null) {
      list = list.where((p) => (p['price'] as num?) != null && (p['price'] as num) <= _maxPrice!);
    }

    // Filter by color
    if (_selectedColor != 'All') {
      list = list.where((p) => (p['color'] ?? '').toString() == _selectedColor);
    }

    // Filter by category
    if (_selectedCategory != null) {
      list = list.where((p) => (p['category'] ?? '').toString() == _selectedCategory);
    }

    return list.toList();
  }

  // Load more items
  void _loadMoreItems() {
    setState(() {
      _visibleItems += 2; // Add 1 more row (2 items)
    });
  }

  void _startPriceSearchFlow() {
    final isTablet = MediaQuery.of(context).size.width > 600;

    // Prefill from current filters
    _minPriceController.text = _minPrice?.toString() ?? '';
    _maxPriceController.text = _maxPrice?.toString() ?? '';

    int step = 0; // 0=price, 1=color, 2=more
    String chosenColor = _selectedColor;
    String chosenCategory = _selectedCategory ?? 'Any';

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Widget tabButton({
              required String label,
              required int index,
            }) {
              final selected = step == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setModalState(() => step = index),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: isTablet ? 10 : 9,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : AppColors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.border,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        label,
                        style: TextStyle(
                          color: selected ? AppColors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: isTablet ? 13 : 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              );
            }

            final title = step == 0
                ? 'Search by price'
                : step == 1
                    ? 'Search by color'
                    : 'More options';

            Widget content;
            if (step == 0) {
              content = Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      tabButton(label: 'Price', index: 0),
                      const SizedBox(width: 10),
                      tabButton(label: 'Color', index: 1),
                      const SizedBox(width: 10),
                      tabButton(label: 'More', index: 2),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _minPriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Min price',
                      prefixText: '\$ ',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _maxPriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Max price',
                      prefixText: '\$ ',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Enter price range then press Search.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: isTablet ? 13.0 : 12.0,
                    ),
                  ),
                ],
              );
            } else if (step == 1) {
              const colors = [
                'All',
                'Black',
                'Green',
                'Blue',
                'Red',
                'Brown',
                'Gray',
                'White',
                'Purple',
              ];

              content = Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      tabButton(label: 'Price', index: 0),
                      const SizedBox(width: 10),
                      tabButton(label: 'Color', index: 1),
                      const SizedBox(width: 10),
                      tabButton(label: 'More', index: 2),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Choose a color (optional)',
                    style: TextStyle(
                      fontSize: isTablet ? 14.0 : 13.0,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: colors.map((c) {
                      final selected = chosenColor == c;
                      return ChoiceChip(
                        label: Text(c),
                        selected: selected,
                        onSelected: (_) => setModalState(() => chosenColor = c),
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: selected ? AppColors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            } else {
              const categoryOptions = ['Any', 'Sunglasses', 'Eyeglasses', 'Contact Lenses', 'Accessories'];

              InputDecoration deco(String label) => InputDecoration(
                    labelText: label,
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  );

              content = Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      tabButton(label: 'Price', index: 0),
                      const SizedBox(width: 10),
                      tabButton(label: 'Color', index: 1),
                      const SizedBox(width: 10),
                      tabButton(label: 'More', index: 2),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: chosenCategory,
                    decoration: deco('Category'),
                    items: categoryOptions
                        .map((v) => DropdownMenuItem<String>(value: v, child: Text(v)))
                        .toList(),
                    onChanged: (v) => setModalState(() => chosenCategory = v ?? 'Any'),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        setModalState(() {
                          chosenColor = 'All';
                          chosenCategory = 'Any';
                          _minPriceController.clear();
                          _maxPriceController.clear();
                        });
                      },
                      child: const Text('Reset'),
                    ),
                  ),
                ],
              );
            }

            const String primaryButtonText = 'Search';
            final dialogTheme = ThemeData(
              brightness: Brightness.light,
              dialogTheme: const DialogThemeData(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,
              ),
              colorScheme: const ColorScheme.light(
                primary: AppColors.primary,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black,
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.white,
                labelStyle: const TextStyle(color: Colors.black),
                hintStyle: const TextStyle(color: Colors.black54),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black, width: 2),
                ),
              ),
            );

            return Theme(
              data: dialogTheme,
              child: AlertDialog(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,
                title: Text(
                  title,
                  style: TextStyle(
                    fontSize: isTablet ? 18.0 : 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                content: SizedBox(width: double.maxFinite, child: content),
                actions: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: isTablet ? 46 : 44,
                        child: ElevatedButton(
                          onPressed: () async {
                            final minText = _minPriceController.text.trim();
                            final maxText = _maxPriceController.text.trim();
                            final minVal = minText.isEmpty ? null : int.tryParse(minText);
                            final maxVal = maxText.isEmpty ? null : int.tryParse(maxText);

                            if ((minText.isNotEmpty && minVal == null) || (maxText.isNotEmpty && maxVal == null)) {
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter valid numbers for price'),
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              return;
                            }
                            if (minVal != null && maxVal != null && minVal > maxVal) {
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                const SnackBar(
                                  content: Text('Min price cannot be greater than max price'),
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              return;
                            }

                            Navigator.of(context).pop();
                            setState(() {
                              _isLoading = true;
                              _visibleItems = 4;
                            });
                            await Future.delayed(const Duration(milliseconds: 600));
                            if (!mounted) return;
                          setState(() {
                            _minPrice = minVal;
                            _maxPrice = maxVal;
                            _selectedColor = chosenColor;
                            _selectedCategory = chosenCategory == 'Any' ? null : chosenCategory;
                            _isLoading = false;
                          });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                          ),
                          child: const Text(primaryButtonText),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        shape: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white : Colors.black,
            width: 1,
          ),
        ),
        backgroundColor: isDark ? AppColors.primary : AppColors.white,
        foregroundColor: isDark ? AppColors.white : Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        leadingWidth: isTablet ? 160 : 150,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => AppRouter.pushNamed(context, AppRoutes.profile),
                child: CircleAvatar(
                  radius: isTablet ? 20.0 : 18.0,
                  backgroundColor: isDark ? AppColors.white : Colors.black,
                  child: CircleAvatar(
                    radius: isTablet ? 18.0 : 16.0,
                    backgroundImage: const AssetImage('asset/images/n.jpeg'),
                    onBackgroundImageError: (_, __) {},
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_greetingForNow()},',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white.withOpacity(0.9) : Colors.black.withOpacity(0.85),
                        height: 1.0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _displayNameMax10(),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.white : Colors.black,
                        height: 1.0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        title: Text(
          'Frame Flea',
          style: TextStyle(
            fontSize: 27.0,
            fontWeight: FontWeight.w700,
            fontFamily: 'Lobster',
            color: isDark ? AppColors.white : Colors.black,
          ),
        ),
        actions: [
          AppBarActionIcons(
            notificationCount: _notificationCount,
            cartCount: _cartCount,
            isTablet: isTablet,
            iconColor: isDark ? AppColors.white : Colors.black,
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

            // Search by Range Price Button (search flow is inside the button)
            Padding(
              padding: EdgeInsets.fromLTRB(
                isTablet ? 24.0 : 16.0,
                isTablet ? 16.0 : 12.0,
                isTablet ? 24.0 : 16.0,
                0,
              ),
              child: _buildPriceRangeButton(isTablet),
            ),

            SizedBox(height: isTablet ? 16.0 : 12.0),

            // Product Count Display
            if (_selectedColor != 'All')
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isTablet ? 24.0 : 16.0),
                child: _buildProductCount(isTablet),
              ),

            // Product Cards Grid
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isTablet ? 24.0 : 16.0),
              child: _buildProductGrid(isTablet),
            ),
            
            SizedBox(height: isTablet ? 24.0 : 16.0),
          ],
        ),
      ),
      floatingActionButton: ValueListenableBuilder<ThemeMode>(
        valueListenable: appThemeMode,
        builder: (context, mode, _) {
          IconData icon;
          String tooltip;
          switch (mode) {
            case ThemeMode.light:
              icon = Icons.light_mode;
              tooltip = 'Switch to dark mode';
              break;
            case ThemeMode.dark:
              icon = Icons.dark_mode;
              tooltip = 'Switch to system mode';
              break;
            case ThemeMode.system:
              icon = Icons.brightness_auto;
              tooltip = 'Switch to light mode';
              break;
          }
          return FloatingActionButton.small(
            onPressed: toggleAppThemeMode,
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            tooltip: tooltip,
            child: Icon(icon),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNavigationBarWidget(
        currentIndex: _currentBottomNavIndex,
        cartBadgeCount: _cartCount,
        onTap: (index) {
          setState(() {
            _currentBottomNavIndex = index;
          });
          
          // Home screen provides a custom onTap, so we must handle navigation here.
          switch (index) {
            case 0:
              // Home (already here)
              break;
            case 1:
              // Market
              AppRouter.pushNamed(context, AppRoutes.myMarket);
              break;
            case 2:
              AppRouter.pushNamed(context, AppRoutes.cart);
              break;
            case 3:
              // Sell
            _showCommissionDialog();
              break;
            case 4:
              // Profile
              AppRouter.pushNamed(context, AppRoutes.profile);
              break;
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        _startPriceSearchFlow();
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 20.0 : 16.0,
          vertical: isTablet ? 16.0 : 12.0,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.white : AppColors.primary,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : Colors.black).withOpacity(isDark ? 0.22 : 0.15),
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
              color: isDark ? AppColors.primary : Colors.white,
              size: isTablet ? 20.0 : 18.0,
            ),
            SizedBox(width: 8),
            Text(
              'Search by Range Price',
              style: TextStyle(
                color: isDark ? AppColors.primary : Colors.white,
                fontSize: isTablet ? 16.0 : 14.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.arrow_forward,
              color: isDark ? AppColors.primary : Colors.white,
              size: isTablet ? 18.0 : 16.0,
            ),
          ],
        ),
      ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: TextButton(
        onPressed: _loadMoreItems,
        style: TextButton.styleFrom(
          foregroundColor: isDark ? Colors.white : Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          minimumSize: const Size(0, 0),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: TextStyle(
            fontSize: isTablet ? 16.0 : 14.0,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.none,
          ),
        ),
        child: const Text('Load more'),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, bool isTablet) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBorderColor = isDark ? AppColors.border : Colors.black;
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
            color: cardBorderColor,
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
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              size: isTablet ? 18.0 : 16.0,
                              color: Colors.amber.shade700,
                            ),
                            SizedBox(width: 2),
                            Text(
                              _mockStarRatingFor(product).toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: isTablet ? 14.0 : 12.0,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
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
