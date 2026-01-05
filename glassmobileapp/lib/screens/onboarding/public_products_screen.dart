import 'package:flutter/material.dart';
import 'dart:async';
import '../../config/app_router.dart';
import '../../constants/routes.dart';
import '../../constants/colors.dart';
import '../../constants/app_constants.dart';
import '../../config/theme_controller.dart';

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
  bool _isLoading = false; // Track loading state
  int _visibleItems = 4; // Track visible items (2 rows x 2 columns)
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  final int _cartCount = 0; // Cart item count
  bool _isSellHovering = false;
  int? _minPrice;
  int? _maxPrice;
  String? _selectedSize;
  bool _isBottomSheetOpen = false;
  String? _lastNoResultsKeyShown;

  void _showBottomNotification(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        dismissDirection: DismissDirection.horizontal,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 3),
        duration: const Duration(seconds: 4),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF5D25E),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: messenger.hideCurrentSnackBar,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.normal,
                  ),
                ),
                child: const Text('Dismiss'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Filter selections
  String? _selectedGender;
  String? _selectedBrand;
  String? _selectedShape;
  String? _selectedTheme;
  String? _selectedCategory;
  String? _lastSelectedFilterType; // Track which filter type was selected last

  // List of hero images with product info and sizes
  final List<Map<String, dynamic>> _heroImages = [
    {'image': 'asset/images/a.jpg', 'name': 'Ray-Ban RB4165 Justin Rectangular', 'price': 45, 'size': 'Large Sunglasses', 'color': 'Black', 'heartCount': 12, 'category': 'Sunglasses'},
    {'image': 'asset/images/ab.jpg', 'name': 'Oakley Men\'s OO9102 Holbrook', 'price': 35, 'size': 'Medium Sunglasses', 'color': 'Green', 'heartCount': 0, 'category': 'Sunglasses'},
    {'image': 'asset/images/B.webp', 'name': 'Locs Gangster Oversized', 'price': 55, 'size': 'Extra Large Sunglasses', 'color': 'Blue', 'heartCount': 4, 'category': 'Sunglasses'},
    {'image': 'asset/images/c.webp', 'name': 'Gucci GG0061S Square', 'price': 40, 'size': 'Small Sunglasses', 'color': 'Red', 'heartCount': 8, 'category': 'Sunglasses'},
    {'image': 'asset/images/d.jpeg', 'name': 'Prada PR17WS Classic', 'price': 120, 'size': 'Large Sunglasses', 'color': 'Brown', 'heartCount': 0, 'category': 'Sunglasses'},
    {'image': 'asset/images/d.jpg', 'name': 'Ray-Ban RB2140 Wayfarer', 'price': 25, 'size': 'Medium Sunglasses', 'color': 'Gray', 'heartCount': 2, 'category': 'Sunglasses'},
    {'image': 'asset/images/f.webp', 'name': 'Oakley OO9208 Frogskins', 'price': 65, 'size': 'Small Sunglasses', 'color': 'White', 'heartCount': 0, 'category': 'Sunglasses'},
    {'image': 'asset/images/gt.webp', 'name': 'Locs Snapback Squared', 'price': 50, 'size': 'Extra Large Sunglasses', 'color': 'Purple', 'heartCount': 15, 'category': 'Sunglasses'},
    {'image': 'asset/images/hy.jpg', 'name': 'Gucci GG0070S Aviator', 'price': 85, 'size': 'Large Sunglasses', 'color': 'Black', 'heartCount': 0, 'category': 'Sunglasses'},
    {'image': 'asset/images/j.jpg', 'name': 'Prada PR 17ZS Rectangle', 'price': 30, 'size': 'Small Sunglasses', 'color': 'Green', 'heartCount': 5, 'category': 'Sunglasses'},
    {'image': 'asset/images/kj.jpg', 'name': 'Ray-Ban RB3016 Clubmaster', 'price': 45, 'size': 'Medium Sunglasses', 'color': 'Blue', 'heartCount': 0, 'category': 'Sunglasses'},
    {'image': 'asset/images/kj.png', 'name': 'Oakley OO9208 Frogskins XL', 'price': 35, 'size': 'Extra Large Sunglasses', 'color': 'Red', 'heartCount': 9, 'category': 'Sunglasses'},
    {'image': 'asset/images/m.jpg', 'name': 'Locs Knucklehead Screwless', 'price': 75, 'size': 'Large Sunglasses', 'color': 'Brown', 'heartCount': 0, 'category': 'Sunglasses'},
    {'image': 'asset/images/mn.jpg', 'name': 'Gucci GG0088S Round', 'price': 40, 'size': 'Small Sunglasses', 'color': 'Gray', 'heartCount': 3, 'category': 'Sunglasses'},
    {'image': 'asset/images/n.jpeg', 'name': 'Prada SPH2BF Rectangle', 'price': 60, 'size': 'Medium Sunglasses', 'color': 'White', 'heartCount': 0, 'category': 'Sunglasses'},
    {'image': 'asset/images/one.webp', 'name': 'Ray-Ban RB4075 Erika Round', 'price': 55, 'size': 'Extra Large Sunglasses', 'color': 'Purple', 'heartCount': 7, 'category': 'Sunglasses'},
    {'image': 'asset/images/p.jpeg', 'name': 'Oakley OO9238 Holbrook Metal', 'price': 70, 'size': 'Large Sunglasses', 'color': 'Black', 'heartCount': 0, 'category': 'Sunglasses'},
    {'image': 'asset/images/po.jpg', 'name': 'Locs Nighthawk Aviator', 'price': 50, 'size': 'Small Sunglasses', 'color': 'Green', 'heartCount': 11, 'category': 'Sunglasses'},
    {'image': 'asset/images/vb.webp', 'name': 'Gucci GG0025S Square Top', 'price': 45, 'size': 'Medium Sunglasses', 'color': 'Blue', 'heartCount': 0, 'category': 'Sunglasses'},
    {'image': 'asset/images/x.jpeg', 'name': 'Prada PR01VS Oversized', 'price': 90, 'size': 'Extra Large Sunglasses', 'color': 'Red', 'heartCount': 6, 'category': 'Sunglasses'},
  ];

  double _mockStarRatingFor(Map<String, dynamic> product) {
    // UI-only mock rating derived from heartCount for consistency per card.
    final hc = (product['heartCount'] as num?)?.toInt() ?? 0;
    final rating = 3.6 + ((hc % 15) * 0.1); // 3.6 .. 5.0
    return rating > 5.0 ? 5.0 : rating;
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

    // Filter by color (if not All)
    if (_selectedColor != 'All') {
      list = list.where((p) => (p['color'] ?? '').toString() == _selectedColor);
    }

    // Filter by category (optional)
    if (_selectedCategory != null) {
      list = list.where((p) => (p['category'] ?? '').toString() == _selectedCategory);
    }

    // Filter by size (optional)
    if (_selectedSize != null) {
      list = list.where((p) => (p['size'] ?? '').toString() == _selectedSize);
    }

    // Filters from the advanced options (optional; inferred from name)
    if (_selectedBrand != null) {
      list = list.where((p) => _inferBrand((p['name'] ?? '').toString()) == _selectedBrand);
    }
    if (_selectedShape != null) {
      list = list.where((p) => _inferShape((p['name'] ?? '').toString()) == _selectedShape);
    }
    if (_selectedTheme != null) {
      list = list.where((p) => _inferTheme((p['name'] ?? '').toString()) == _selectedTheme);
    }
    if (_selectedGender != null) {
      list = list.where((p) => _inferGender((p['name'] ?? '').toString()) == _selectedGender);
    }

    return list.toList();
  }

  String? _inferBrand(String name) {
    final n = name.toLowerCase();
    if (n.startsWith('ray-ban')) return 'Ray-Ban';
    if (n.startsWith('oakley')) return 'Oakley';
    if (n.startsWith('gucci')) return 'Gucci';
    if (n.startsWith('prada')) return 'Prada';
    if (n.startsWith('locs')) return 'Locs';

    // Fallback: match anywhere
    if (n.contains('ray-ban')) return 'Ray-Ban';
    if (n.contains('oakley')) return 'Oakley';
    if (n.contains('gucci')) return 'Gucci';
    if (n.contains('prada')) return 'Prada';
    if (n.contains('locs')) return 'Locs';
    return null;
  }

  String? _inferShape(String name) {
    final n = name.toLowerCase();
    if (n.contains('round')) return 'Round';
    if (n.contains('square')) return 'Square';
    if (n.contains('oval')) return 'Oval';
    if (n.contains('rectangle') || n.contains('rectangular')) return 'Rectangle';
    if (n.contains('aviator') || n.contains('wayfarer')) return 'Rectangle';
    return null;
  }

  String? _inferTheme(String name) {
    final brand = _inferBrand(name);
    if (brand == 'Oakley') return 'Sport';
    if (brand == 'Gucci' || brand == 'Prada') return 'Luxury';
    if (brand == 'Ray-Ban') return 'Classic';
    if (brand == 'Locs') return 'Fashion';
    return null;
  }

  String? _inferGender(String name) {
    final n = name.toLowerCase();
    if (n.contains("men's") || RegExp(r'\bmen\b').hasMatch(n)) return 'Male';
    if (n.contains("women's") || RegExp(r'\bwomen\b').hasMatch(n)) return 'Female';
    return null;
  }

  List<String> _availableSizes() {
    final sizes = <String>{};
    for (final p in _heroImages) {
      final s = (p['size'] ?? '').toString().trim();
      if (s.isNotEmpty) sizes.add(s);
    }
    final list = sizes.toList()..sort();
    return list;
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
    String chosenBrand = _selectedBrand ?? 'Any';
    String chosenSize = _selectedSize ?? 'Any';
    String chosenShape = _selectedShape ?? 'Any';
    String chosenTheme = _selectedTheme ?? 'Any';
    String chosenGender = _selectedGender ?? 'Any';

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
                  // Top navigation buttons (switch forms)
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
                  // Top navigation buttons (switch forms)
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
                        selectedColor: AppColors.primary.withOpacity(0.15),
                        onSelected: (_) => setModalState(() => chosenColor = c),
                        labelStyle: TextStyle(
                          color: selected ? AppColors.primary : AppColors.textPrimary,
                          fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                        ),
                        side: BorderSide(
                          color: selected ? AppColors.primary : AppColors.border,
                          width: selected ? 1.5 : 1,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            } else {
              final sizeOptions = <String>['Any', ..._availableSizes()];
              const brandOptions = ['Any', 'Ray-Ban', 'Oakley', 'Gucci', 'Prada', 'Locs'];
              const shapeOptions = ['Any', 'Round', 'Square', 'Oval', 'Rectangle'];
              const themeOptions = ['Any', 'Sport', 'Fashion', 'Classic', 'Luxury'];
              const genderOptions = ['Any', 'Male', 'Female', 'Babies'];
              const categoryOptions = ['Any', 'Sunglasses', 'Eyeglasses', 'Contact Lenses', 'Accessories'];

              InputDecoration deco(String label) => InputDecoration(
                    labelText: label,
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  );

              content = Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top navigation buttons (switch forms)
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
                  DropdownButtonFormField<String>(
                    value: chosenBrand,
                    decoration: deco('Brand'),
                    items: brandOptions
                        .map((v) => DropdownMenuItem<String>(value: v, child: Text(v)))
                        .toList(),
                    onChanged: (v) => setModalState(() => chosenBrand = v ?? 'Any'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: chosenSize,
                    decoration: deco('Size'),
                    items: sizeOptions
                        .map((v) => DropdownMenuItem<String>(value: v, child: Text(v)))
                        .toList(),
                    onChanged: (v) => setModalState(() => chosenSize = v ?? 'Any'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: chosenShape,
                    decoration: deco('Shape'),
                    items: shapeOptions
                        .map((v) => DropdownMenuItem<String>(value: v, child: Text(v)))
                        .toList(),
                    onChanged: (v) => setModalState(() => chosenShape = v ?? 'Any'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: chosenTheme,
                    decoration: deco('Theme'),
                    items: themeOptions
                        .map((v) => DropdownMenuItem<String>(value: v, child: Text(v)))
                        .toList(),
                    onChanged: (v) => setModalState(() => chosenTheme = v ?? 'Any'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: chosenGender,
                    decoration: deco('Gender'),
                    items: genderOptions
                        .map((v) => DropdownMenuItem<String>(value: v, child: Text(v)))
                        .toList(),
                    onChanged: (v) => setModalState(() => chosenGender = v ?? 'Any'),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showFilterBottomSheet();
                      },
                      child: const Text('Advanced filters'),
                    ),
                  ),
                ],
              );
            }

            // No "continue flow" — search directly from any tab
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
                            _selectedBrand = chosenBrand == 'Any' ? null : chosenBrand;
                            _selectedSize = chosenSize == 'Any' ? null : chosenSize;
                            _selectedShape = chosenShape == 'Any' ? null : chosenShape;
                            _selectedTheme = chosenTheme == 'Any' ? null : chosenTheme;
                            _selectedGender = chosenGender == 'Any' ? null : chosenGender;
                            _isLoading = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                        ),
                        child: Text(primaryButtonText),
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
  Future<void> _showFilterBottomSheet() async {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    if (_isBottomSheetOpen) return;
    setState(() => _isBottomSheetOpen = true);

    await showModalBottomSheet(
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

    if (!mounted) return;
    setState(() => _isBottomSheetOpen = false);
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

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final isTablet = screenWidth > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appBarFg = Theme.of(context).appBarTheme.foregroundColor ?? (isDark ? AppColors.white : AppColors.black);
    
    return Scaffold(
      appBar: AppBar(
        shape: const Border(
          bottom: BorderSide(
            color: Colors.black,
            width: 1,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        titleSpacing: 0,
        leadingWidth: isTablet ? 90 : 80,
        leading: Center(
          child: MouseRegion(
            onEnter: (_) => setState(() => _isSellHovering = true),
            onExit: (_) => setState(() => _isSellHovering = false),
            cursor: SystemMouseCursors.click,
            child: TextButton(
              onPressed: () {
                AppRouter.pushNamed(context, AppRoutes.signin);
              },
              style: TextButton.styleFrom(
                foregroundColor: appBarFg,
                padding: EdgeInsets.zero,
              ),
              child: Text(
                'Sell',
                style: TextStyle(
                  color: appBarFg,
                  fontSize: isTablet ? 18.0 : 16.0,
                  fontWeight: FontWeight.w600,
                  decoration: _isSellHovering ? TextDecoration.underline : TextDecoration.none,
                  decorationColor: appBarFg,
                ),
              ),
            ),
          ),
        ),
        title: Text(
          'Frame Flea',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 27.0,
            fontWeight: FontWeight.w700,
            fontFamily: 'Lobster',
          ),
        ),
        actions: [
          Stack(
                clipBehavior: Clip.none,
                children: [
              IconButton(
                onPressed: () => _handleNavAction('cart'),
                icon: const Icon(Icons.shopping_cart),
              ),
                  Positioned(
                right: 6,
                top: 6,
                    child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$_cartCount',
                    style: const TextStyle(
                          color: Colors.white,
                      fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          const SizedBox(width: 6),
        ],
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
            
            // Search by Range Price (opens multi-step flow)
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
      floatingActionButton: _isBottomSheetOpen
          ? null
          : ValueListenableBuilder<ThemeMode>(
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
    );
  }

  // (Centered logo title removed — replaced by "Frame" text title)

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
              color: Colors.black.withOpacity(isDark ? 0.22 : 0.15),
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
    
    // If filters yield no results, show SnackBar but keep cards visible (fallback to all).
    final bool hasActiveFilters =
        _selectedColor != 'All' ||
        _minPrice != null ||
        _maxPrice != null ||
        _selectedCategory != null ||
        _selectedBrand != null ||
        _selectedSize != null ||
        _selectedShape != null ||
        _selectedTheme != null ||
        _selectedGender != null;

    final List<Map<String, dynamic>> productsToShow =
        (filteredProducts.isEmpty && hasActiveFilters) ? _heroImages : filteredProducts;

    if (filteredProducts.isEmpty && hasActiveFilters) {
      final noResultsKey = [
        _selectedColor,
        _minPrice?.toString() ?? '',
        _maxPrice?.toString() ?? '',
        _selectedCategory ?? '',
        _selectedBrand ?? '',
        _selectedSize ?? '',
        _selectedShape ?? '',
        _selectedTheme ?? '',
        _selectedGender ?? '',
      ].join('|');

      if (_lastNoResultsKeyShown != noResultsKey) {
        _lastNoResultsKeyShown = noResultsKey;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _showBottomNotification('No record to display!');
        });
      }

      // Don't show the big empty-state widget; show only the red SnackBar.
      // Keep rendering the grid (fallback list) below.
    }

    // Reset so next time empty-state occurs, we can show again.
    if (filteredProducts.isNotEmpty) {
      _lastNoResultsKeyShown = null;
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
          itemCount: _visibleItems > productsToShow.length ? productsToShow.length : _visibleItems,
          itemBuilder: (context, index) {
            return _buildProductCard(productsToShow[index], isTablet);
          },
        ),
        
        // Load More Button (if there are more items)
        if (_visibleItems < productsToShow.length)
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
