import 'package:flutter/material.dart';
import 'dart:async';
import '../../config/app_router.dart';
import '../../constants/routes.dart';
import '../../constants/colors.dart';
import '../../constants/app_constants.dart';

class PublicProductsScreen extends StatefulWidget {
  const PublicProductsScreen({super.key});

  @override
  State<PublicProductsScreen> createState() => _PublicProductsScreenState();
}

class _PublicProductsScreenState extends State<PublicProductsScreen> {
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
  final int _cartCount = 0; // Cart item count
  
  // Filter selections
  String? _selectedGender;
  String? _selectedBrand;
  String? _selectedShape;
  String? _selectedTheme;
  String? _lastSelectedFilterType; // Track which filter type was selected last

  // Navigation menu items
  final List<Map<String, dynamic>> _navMenuItems = [
    {
      'type': 'title',
      'text': 'Sell',
      'isExpanded': true,
    },
    {
      'type': 'text',
      'text': 'Cart',
      'action': 'cart',
    },
    {
      'type': 'icon',
      'icon': Icons.shopping_cart,
      'action': 'cart',
    },
  ];

  // List of hero images with product info and sizes
  final List<Map<String, dynamic>> _heroImages = [
    {'image': 'asset/images/a.jpg', 'name': 'Ray-Ban RB4165 Justin Rectangular', 'price': 45, 'size': 'Large Sunglasses', 'color': 'Black', 'heartCount': 12},
    {'image': 'asset/images/ab.jpg', 'name': 'Oakley Men\'s OO9102 Holbrook', 'price': 35, 'size': 'Medium Sunglasses', 'color': 'Green', 'heartCount': 0},
    {'image': 'asset/images/B.webp', 'name': 'Locs Gangster Oversized', 'price': 55, 'size': 'Extra Large Sunglasses', 'color': 'Blue', 'heartCount': 4},
    {'image': 'asset/images/c.webp', 'name': 'Gucci GG0061S Square', 'price': 40, 'size': 'Small Sunglasses', 'color': 'Red', 'heartCount': 8},
    {'image': 'asset/images/d.jpeg', 'name': 'Prada PR17WS Classic', 'price': 120, 'size': 'Large Sunglasses', 'color': 'Brown', 'heartCount': 0},
    {'image': 'asset/images/d.jpg', 'name': 'Ray-Ban RB2140 Wayfarer', 'price': 25, 'size': 'Medium Sunglasses', 'color': 'Gray', 'heartCount': 2},
    {'image': 'asset/images/f.webp', 'name': 'Oakley OO9208 Frogskins', 'price': 65, 'size': 'Small Sunglasses', 'color': 'White', 'heartCount': 0},
    {'image': 'asset/images/gt.webp', 'name': 'Locs Snapback Squared', 'price': 50, 'size': 'Extra Large Sunglasses', 'color': 'Purple', 'heartCount': 15},
    {'image': 'asset/images/hy.jpg', 'name': 'Gucci GG0070S Aviator', 'price': 85, 'size': 'Large Sunglasses', 'color': 'Black', 'heartCount': 0},
    {'image': 'asset/images/j.jpg', 'name': 'Prada PR 17ZS Rectangle', 'price': 30, 'size': 'Small Sunglasses', 'color': 'Green', 'heartCount': 5},
    {'image': 'asset/images/kj.jpg', 'name': 'Ray-Ban RB3016 Clubmaster', 'price': 45, 'size': 'Medium Sunglasses', 'color': 'Blue', 'heartCount': 0},
    {'image': 'asset/images/kj.png', 'name': 'Oakley OO9208 Frogskins XL', 'price': 35, 'size': 'Extra Large Sunglasses', 'color': 'Red', 'heartCount': 9},
    {'image': 'asset/images/m.jpg', 'name': 'Locs Knucklehead Screwless', 'price': 75, 'size': 'Large Sunglasses', 'color': 'Brown', 'heartCount': 0},
    {'image': 'asset/images/mn.jpg', 'name': 'Gucci GG0088S Round', 'price': 40, 'size': 'Small Sunglasses', 'color': 'Gray', 'heartCount': 3},
    {'image': 'asset/images/n.jpeg', 'name': 'Prada SPH2BF Rectangle', 'price': 60, 'size': 'Medium Sunglasses', 'color': 'White', 'heartCount': 0},
    {'image': 'asset/images/one.webp', 'name': 'Ray-Ban RB4075 Erika Round', 'price': 55, 'size': 'Extra Large Sunglasses', 'color': 'Purple', 'heartCount': 7},
    {'image': 'asset/images/p.jpeg', 'name': 'Oakley OO9238 Holbrook Metal', 'price': 70, 'size': 'Large Sunglasses', 'color': 'Black', 'heartCount': 0},
    {'image': 'asset/images/po.jpg', 'name': 'Locs Nighthawk Aviator', 'price': 50, 'size': 'Small Sunglasses', 'color': 'Green', 'heartCount': 11},
    {'image': 'asset/images/vb.webp', 'name': 'Gucci GG0025S Square Top', 'price': 45, 'size': 'Medium Sunglasses', 'color': 'Blue', 'heartCount': 0},
    {'image': 'asset/images/x.jpeg', 'name': 'Prada PR01VS Oversized', 'price': 90, 'size': 'Extra Large Sunglasses', 'color': 'Red', 'heartCount': 6},
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
    // Show bottom sheet when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showFilterBottomSheet();
    });
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
    return _heroImages.where((product) => product['size'] == _selectedColor).toList();
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

  // Handle navigation menu actions
  void _handleNavAction(String action) {
    switch (action) {
      case 'back':
        AppRouter.pop(context);
        break;
      case 'explore':
        // Handle explore navigation
        break;
      case 'register':
        AppRouter.pushNamed(context, AppRoutes.register);
        break;
      case 'cart':
        // Handle cart navigation
        break;
      default:
        break;
    }
  }

  // Show filter bottom sheet
  void _showFilterBottomSheet() {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 24.0 : 16.0,
            vertical: isTablet ? 24.0 : 20.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: isTablet ? 24.0 : 20.0),
              
              // Title
              Text(
                'Filter Flames',
                style: TextStyle(
                  fontSize: isTablet ? 24.0 : 20.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: isTablet ? 24.0 : 20.0),
              
              // First row: Gender
              _buildFilterRow(
                context: context,
                title: 'Gender',
                filterType: 'Gender',
                options: ['Male', 'Female', 'Babies'],
                selectedValue: _selectedGender,
                lastSelectedFilterType: _lastSelectedFilterType,
                onSelect: (value) {
                  setState(() {
                    if (_selectedGender == value) {
                      // Deselecting - keep Shop Now button where it is
                      _selectedGender = null;
                      // Only clear if there are no other selections
                      if (_selectedBrand == null && _selectedShape == null && _selectedTheme == null) {
                        _lastSelectedFilterType = null;
                      }
                    } else {
                      // Selecting new option - move Shop Now button here
                      _selectedGender = value;
                      _lastSelectedFilterType = 'Gender';
                    }
                  });
                  setModalState(() {});
                },
                isTablet: isTablet,
                optionCounts: {
                  'Male': '1,234',
                  'Female': '2,456',
                  'Babies': '345',
                },
              ),
              SizedBox(height: isTablet ? 20.0 : 16.0),
              
              // Second row: Brand
              _buildFilterRow(
                context: context,
                title: 'Brand',
                filterType: 'Brand',
                options: ['Ray-Ban', 'Oakley', 'Gucci', 'Prada'],
                selectedValue: _selectedBrand,
                lastSelectedFilterType: _lastSelectedFilterType,
                onSelect: (value) {
                  setState(() {
                    if (_selectedBrand == value) {
                      // Deselecting - keep Shop Now button where it is
                      _selectedBrand = null;
                      // Only clear if there are no other selections
                      if (_selectedGender == null && _selectedShape == null && _selectedTheme == null) {
                        _lastSelectedFilterType = null;
                      }
                    } else {
                      // Selecting new option - move Shop Now button here
                      _selectedBrand = value;
                      _lastSelectedFilterType = 'Brand';
                    }
                  });
                  setModalState(() {});
                },
                isTablet: isTablet,
                optionCounts: {
                  'Ray-Ban': '5,678',
                  'Oakley': '3,890',
                  'Gucci': '2,345',
                  'Prada': '1,567',
                },
              ),
              SizedBox(height: isTablet ? 20.0 : 16.0),
              
              // Third row: Shape
              _buildFilterRow(
                context: context,
                title: 'Shape',
                filterType: 'Shape',
                options: ['Round', 'Square', 'Oval', 'Rectangle'],
                selectedValue: _selectedShape,
                lastSelectedFilterType: _lastSelectedFilterType,
                onSelect: (value) {
                  setState(() {
                    if (_selectedShape == value) {
                      // Deselecting - keep Shop Now button where it is
                      _selectedShape = null;
                      // Only clear if there are no other selections
                      if (_selectedGender == null && _selectedBrand == null && _selectedTheme == null) {
                        _lastSelectedFilterType = null;
                      }
                    } else {
                      // Selecting new option - move Shop Now button here
                      _selectedShape = value;
                      _lastSelectedFilterType = 'Shape';
                    }
                  });
                  setModalState(() {});
                },
                isTablet: isTablet,
                optionCounts: {
                  'Round': '4,321',
                  'Square': '3,456',
                  'Oval': '2,345',
                  'Rectangle': '1,234',
                },
              ),
              SizedBox(height: isTablet ? 20.0 : 16.0),
              
              // Fourth row: Themes
              _buildFilterRow(
                context: context,
                title: 'Themes',
                filterType: 'Themes',
                options: ['Sport', 'Fashion', 'Classic', 'Luxury'],
                selectedValue: _selectedTheme,
                lastSelectedFilterType: _lastSelectedFilterType,
                onSelect: (value) {
                  setState(() {
                    if (_selectedTheme == value) {
                      // Deselecting - keep Shop Now button where it is
                      _selectedTheme = null;
                      // Only clear if there are no other selections
                      if (_selectedGender == null && _selectedBrand == null && _selectedShape == null) {
                        _lastSelectedFilterType = null;
                      }
                    } else {
                      // Selecting new option - move Shop Now button here
                      _selectedTheme = value;
                      _lastSelectedFilterType = 'Themes';
                    }
                  });
                  setModalState(() {});
                },
                isTablet: isTablet,
                optionCounts: {
                  'Sport': '6,789',
                  'Fashion': '5,432',
                  'Classic': '3,210',
                  'Luxury': '1,987',
                },
              ),
              SizedBox(height: isTablet ? 24.0 : 20.0),
            ],
          ),
        ),
      ),
    );
  }

  // Build filter row with checkboxes
  Widget _buildFilterRow({
    required BuildContext context,
    required String title,
    required String filterType,
    required List<String> options,
    String? selectedValue,
    String? lastSelectedFilterType,
    required Function(String) onSelect,
    required bool isTablet,
    Map<String, String>? optionCounts,
  }) {
    // Check if this is the last selected filter type
    final bool showShopNow = selectedValue != null && lastSelectedFilterType == filterType;
    
    // Find the index of the selected option to determine position
    int? selectedIndex = selectedValue != null 
        ? options.indexWhere((opt) => opt == selectedValue) 
        : null;
    
    // Determine Shop Now position: if selected is at end (last index), show before; otherwise show after
    final bool showShopNowBefore = selectedIndex != null && selectedIndex == options.length - 1;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isTablet ? 18.0 : 16.0,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            // Build all options, keeping them in original positions
            ...options.asMap().entries.expand((entry) {
              final int index = entry.key;
              final String option = entry.value;
              final bool isSelected = selectedValue == option;
              final bool shouldShow = selectedValue == null || isSelected;
              
              if (!shouldShow) {
                // Hide unselected options when something is selected
                return [];
              }
              
              // Build widgets for this position
              final bool hasShopNow = showShopNow && isSelected && index == selectedIndex;
              
              // If Shop Now is present, need to handle differently
              if (hasShopNow) {
                List<Widget> widgets = [];
                
                // Shop Now button before selected option (if at end)
                if (showShopNowBefore) {
                  widgets.add(
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: isTablet ? 12.0 : 10.0,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.red,
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Shop Now',
                                style: TextStyle(
                                  fontSize: isTablet ? 14.0 : 12.0,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }
                
                // Option button
                widgets.add(
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        onSelect(option);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: isTablet ? 12.0 : 10.0,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFF156311),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Color(0xFF156311),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check,
                              size: isTablet ? 16.0 : 14.0,
                              color: AppColors.white,
                            ),
                            SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                optionCounts != null && optionCounts.containsKey(option)
                                    ? '$option (${optionCounts[option]} records)'
                                    : option,
                                style: TextStyle(
                                  fontSize: isTablet ? 14.0 : 12.0,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
                
                // Shop Now button after selected option (if not at end)
                if (!showShopNowBefore) {
                  widgets.add(
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: isTablet ? 12.0 : 10.0,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.red,
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Shop Now',
                                style: TextStyle(
                                  fontSize: isTablet ? 14.0 : 12.0,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }
                
                return widgets;
              }
              
              // Just the option button (no Shop Now)
              // Check if there's a visible option after this one
              bool hasVisibleOptionAfter = options.asMap().entries.any((e) {
                if (e.key <= index) return false;
                final bool eIsSelected = selectedValue == e.value;
                return selectedValue == null || eIsSelected;
              });
              
              return [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: hasVisibleOptionAfter ? 8 : 0,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        onSelect(option);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: isTablet ? 12.0 : 10.0,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? Color(0xFF156311)
                              : AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected 
                                ? Color(0xFF156311)
                                : AppColors.primary.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isSelected ? Icons.check : Icons.add,
                              size: isTablet ? 16.0 : 14.0,
                              color: isSelected 
                                  ? AppColors.white 
                                  : AppColors.textPrimary,
                            ),
                            SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                isSelected && optionCounts != null && optionCounts.containsKey(option)
                                    ? '$option (${optionCounts[option]} records)'
                                    : option,
                                style: TextStyle(
                                  fontSize: isTablet ? 14.0 : 12.0,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected 
                                      ? AppColors.white 
                                      : AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ];
            }),
          ],
        ),
      ],
    );
  }

  // Build navigation menu items from array
  List<Widget> _buildNavMenuItems(bool isTablet) {
    List<Widget> widgets = [];
    
    for (int i = 0; i < _navMenuItems.length; i++) {
      final item = _navMenuItems[i];
      final previousItem = i > 0 ? _navMenuItems[i - 1] : null;
      
      // Add spacing between items (except for the first item)
      if (i > 0) {
        // Reduce space between icon and text (both directions)
        if ((previousItem?['type'] == 'icon' && item['type'] == 'text') ||
            (previousItem?['type'] == 'text' && item['type'] == 'icon')) {
          widgets.add(SizedBox(width: 2));
        } else if (item['type'] == 'title') {
          widgets.add(SizedBox(width: 12));
        } else {
          widgets.add(SizedBox(width: 8));
        }
      }
      
      switch (item['type']) {
        case 'icon':
          widgets.add(
            GestureDetector(
              onTap: () => _handleNavAction(item['action']),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    child: Icon(
                      item['icon'],
                      size: isTablet ? 24.0 : 22.0,
                      color: AppColors.white,
                    ),
                  ),
                  // Badge showing cart count
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$_cartCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isTablet ? 10.0 : 8.0,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
          break;
          
        case 'title':
          widgets.add(
            Expanded(
              child: Text(
                item['text'],
                style: TextStyle(
                  fontSize: isTablet ? 20.0 : 18.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ),
          );
          break;
          
        case 'text':
          widgets.add(
            GestureDetector(
              onTap: () => _handleNavAction(item['action']),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(
                  item['text'],
                  style: TextStyle(
                    fontSize: isTablet ? 16.0 : 14.0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          );
          break;
      }
    }
    
    return widgets;
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
          children: _buildNavMenuItems(isTablet),
        ),
      ),
      body: Column(
        children: [
          // Fixed Section: Hero Image Carousel, Filter Buttons, Search by Range Price
          Column(
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
            ],
          ),
          // Scrollable Section: Product Grid
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isTablet ? 24.0 : 16.0),
                child: Column(
                  children: [
                    SizedBox(height: isTablet ? 16.0 : 12.0),
                    _buildProductGrid(isTablet),
                    SizedBox(height: isTablet ? 24.0 : 16.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
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
                      product['size'],
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
                              Icons.visibility,
                              size: isTablet ? 18.0 : 16.0,
                              color: Colors.orange,
                            ),
                            SizedBox(width: 2),
                            Text(
                              '${product['heartCount'] ?? 0}',
                              style: TextStyle(
                                fontSize: isTablet ? 14.0 : 12.0,
                                fontWeight: FontWeight.w500,
                                color: Colors.orange,
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
