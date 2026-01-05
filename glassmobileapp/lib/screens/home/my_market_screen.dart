import 'package:flutter/material.dart';

import '../../config/app_router.dart';
import '../../constants/colors.dart';
import '../../constants/routes.dart';
import '../../widgets/common/bottom_navigation_bar_widget.dart';
import '../../widgets/common/app_bar_action_icons.dart';
import '../../widgets/common/commission_dialog.dart';

class MyMarketScreen extends StatefulWidget {
  const MyMarketScreen({super.key});

  @override
  State<MyMarketScreen> createState() => _MyMarketScreenState();
}

class _MyMarketScreenState extends State<MyMarketScreen> {
  int _currentBottomNavIndex = 1;
  final bool _isFirstRowOccupied = false;
  String? _expandedProductKey;
  static const int _notificationCount = 14;
  static const int _cartCount = 2;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Mock stats (replace with real data later)
  final int _views = 1240;

  // People view events (mock). If the viewer is not logged in, name is hidden.
  final List<_ViewEvent> _viewEvents = [
    _ViewEvent(name: 'Sophia', isViewerLoggedIn: true, timestamp: DateTime(2024, 12, 12, 10, 24)),
    _ViewEvent(name: 'Michael', isViewerLoggedIn: true, timestamp: DateTime(2024, 12, 12, 12, 12)),
    _ViewEvent(name: null, isViewerLoggedIn: false, timestamp: DateTime(2024, 12, 12, 13, 40)),
    _ViewEvent(name: 'Ava', isViewerLoggedIn: true, timestamp: DateTime(2024, 12, 13, 9, 5)),
    _ViewEvent(name: null, isViewerLoggedIn: false, timestamp: DateTime(2024, 12, 14, 18, 55)),
    _ViewEvent(name: 'Noah', isViewerLoggedIn: true, timestamp: DateTime(2024, 12, 15, 8, 31)),
  ];

  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();
  DateTime? _fromDate;
  DateTime? _toDate;

  // Mock uploaded products list
  final List<Map<String, dynamic>> _myProducts = [
    {
      'name': "Oakley Men's OO9102 Holbrook",
      'price': 35.00,
      'image': 'asset/images/ab.jpg',
      'views': 402,
      'opens': 98,
      'interested': 3,
      'uploadedOn': '24 Dec, 2025',
    },
    {
      'name': 'Ray-Ban RB2140 Wayfarer',
      'price': 25.00,
      'image': 'asset/images/d.jpg',
      'views': 516,
      'opens': 121,
      'interested': 2,
      'uploadedOn': '20 Dec, 2025',
    },
    {
      'name': 'Gucci GG0061S Square',
      'price': 40.00,
      'image': 'asset/images/c.webp',
      'views': 322,
      'opens': 99,
      'interested': 2,
      'uploadedOn': '18 Dec, 2025',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _fromDateController.dispose();
    _toDateController.dispose();
    super.dispose();
  }

  int _viewsPerDay() {
    if (_viewEvents.isEmpty) return 0;
    // Use the most recent day in the list for a stable "per day" value
    final latest = _viewEvents.map((e) => e.timestamp).reduce((a, b) => a.isAfter(b) ? a : b);
    return _viewEvents.where((e) {
      final t = e.timestamp;
      return t.year == latest.year && t.month == latest.month && t.day == latest.day;
    }).length;
  }

  String _formatDate(DateTime dt) {
    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]}, ${dt.year}';
  }

  String _formatDateTime(DateTime dt) {
    final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${_formatDate(dt)} $hour12:$minute $ampm';
  }

  Future<void> _pickFilterDate({required bool isFrom}) async {
    final initial = isFrom ? (_fromDate ?? DateTime.now()) : (_toDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime(2100, 12, 31),
    );
    if (!mounted || picked == null) return;

    setState(() {
      final normalized = DateTime(picked.year, picked.month, picked.day);
      if (isFrom) {
        _fromDate = normalized;
        _fromDateController.text = _formatDate(normalized);
      } else {
        _toDate = normalized;
        _toDateController.text = _formatDate(normalized);
      }
    });
  }

  List<_ViewEvent> _filteredViewEvents() {
    final from = _fromDate;
    final to = _toDate;
    if (from == null && to == null) return _viewEvents;

    return _viewEvents.where((e) {
      final d = DateTime(e.timestamp.year, e.timestamp.month, e.timestamp.day);
      final afterFrom = from == null ? true : !d.isBefore(from);
      final beforeTo = to == null ? true : !d.isAfter(to);
      return afterFrom && beforeTo;
    }).toList();
  }

  void _showViewsListDialog() {
    final isTablet = MediaQuery.of(context).size.width > 600;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        final events = _filteredViewEvents();
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.75,
              maxWidth: isTablet ? 520 : MediaQuery.of(context).size.width * 0.92,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 16.0 : 14.0,
                    vertical: isTablet ? 14.0 : 12.0,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    'People Views',
                    style: TextStyle(
                      fontSize: isTablet ? 18.0 : 16.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(isTablet ? 16.0 : 14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _fromDateController,
                        readOnly: true,
                        onTap: () => _pickFilterDate(isFrom: true),
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: 'From',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: AppColors.primary, width: 1.2),
                          ),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Material(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                              child: InkWell(
                                onTap: () => _pickFilterDate(isFrom: true),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: isTablet ? 40 : 36,
                                  height: isTablet ? 40 : 36,
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.calendar_month_outlined,
                                    color: AppColors.white,
                                    size: isTablet ? 20 : 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: isTablet ? 10 : 8,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _toDateController,
                        readOnly: true,
                        onTap: () => _pickFilterDate(isFrom: false),
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: 'To',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: AppColors.primary, width: 1.2),
                          ),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Material(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                              child: InkWell(
                                onTap: () => _pickFilterDate(isFrom: false),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: isTablet ? 40 : 36,
                                  height: isTablet ? 40 : 36,
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.calendar_month_outlined,
                                    color: AppColors.white,
                                    size: isTablet ? 20 : 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: isTablet ? 10 : 8,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _fromDate = null;
                        _toDate = null;
                        _fromDateController.clear();
                        _toDateController.clear();
                      });
                    },
                    child: const Text('Clear'),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.48,
                  child: events.isEmpty
                      ? Center(
                          child: Text(
                            'No views in selected range',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: isTablet ? 14.0 : 13.0,
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: events.length,
                          separatorBuilder: (_, __) => Divider(
                            height: 1,
                            color: AppColors.border,
                          ),
                          itemBuilder: (context, i) {
                            final e = events[i];
                            final who = e.isViewerLoggedIn ? (e.name ?? 'Unknown') : 'Unknown';
                            return ListTile(
                              dense: true,
                              leading: Icon(
                                Icons.visibility,
                                color: Colors.orange,
                                size: isTablet ? 20 : 18,
                              ),
                              title: Text(
                                who,
                                style: TextStyle(
                                  fontSize: isTablet ? 14.0 : 13.0,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              subtitle: Text(
                                _formatDateTime(e.timestamp),
                                style: TextStyle(
                                  fontSize: isTablet ? 13.0 : 12.0,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            );
                          },
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
  }

  void _confirmDeleteProduct(String productKey) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    showDialog(
      context: context,
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
                  'Delete Frame?',
                  style: TextStyle(
                    fontSize: isTablet ? 18.0 : 16.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This will remove the uploaded frame from your market list.',
                  style: TextStyle(
                    fontSize: isTablet ? 14.0 : 13.0,
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          side: BorderSide(color: AppColors.border, width: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          setState(() {
                            _myProducts.removeWhere(
                              (p) => (p['name'] ?? '').toString() == productKey,
                            );
                            if (_expandedProductKey == productKey) {
                              _expandedProductKey = null;
                            }
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Deleted'),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFD93211),
                          side: const BorderSide(color: Color(0xFFD93211), width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Delete'),
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
                arguments: {
                  'commissionTier': tier,
                  'isFirstRowOccupied': _isFirstRowOccupied,
                },
              );
            });
          },
          isFirstRowOccupied: _isFirstRowOccupied,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appBarBg = isDark ? AppColors.primary : AppColors.white;
    final appBarFg = isDark ? AppColors.white : Colors.black;
    final filteredProducts = _searchQuery.trim().isEmpty
        ? _myProducts
        : _myProducts
            .where(
              (p) => (p['name'] ?? '')
                  .toString()
                  .toLowerCase()
                  .contains(_searchQuery.trim().toLowerCase()),
            )
            .toList();

    return Scaffold(
      floatingActionButton: Transform.scale(
        scale: isTablet ? 0.92 : 0.88,
        child: FloatingActionButton.extended(
          onPressed: () {
            AppRouter.pushNamed(context, AppRoutes.productRegister);
          },
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
          label: const Text('Sell'),
          icon: const Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            GestureDetector(
              onTap: () => AppRouter.pushNamed(context, AppRoutes.profile),
              child: CircleAvatar(
                radius: isTablet ? 20.0 : 18.0,
                backgroundColor: appBarFg,
                child: CircleAvatar(
                  radius: isTablet ? 18.0 : 16.0,
                  backgroundImage: const AssetImage('asset/images/n.jpeg'),
                  onBackgroundImageError: (_, __) {},
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'My Market',
                    style: TextStyle(
                      fontSize: isTablet ? 18.0 : 16.0,
                      fontWeight: FontWeight.bold,
                      color: appBarFg,
                    ),
                  ),
                  Text(
                    'Own Uploaded Frame',
                    style: TextStyle(
                      fontSize: isTablet ? 13.0 : 12.0,
                      color: appBarFg.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
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
          // Stats row
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'People Views',
                  value: _views.toString(),
                  icon: Icons.visibility_outlined,
                  isTablet: isTablet,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Views / Day',
                  value: _viewsPerDay().toString(),
                  icon: Icons.bar_chart_outlined,
                  isTablet: isTablet,
                  onTap: _showViewsListDialog,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(height: isTablet ? 20.0 : 16.0),

          Text(
            'My Frame Uploaded',
            style: TextStyle(
              fontSize: isTablet ? 18.0 : 16.0,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: isTablet ? 12.0 : 10.0),
          // Search input
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 12.0 : 10.0,
              vertical: isTablet ? 6.0 : 4.0,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (v) {
                setState(() {
                  _searchQuery = v;
                  // collapse if the expanded item is no longer visible in results
                  if (_expandedProductKey != null) {
                    final q = v.trim().toLowerCase();
                    final stillVisible = q.isEmpty
                        ? _myProducts.any((p) => (p['name'] ?? '').toString() == _expandedProductKey)
                        : _myProducts.any((p) {
                            final name = (p['name'] ?? '').toString();
                            return name == _expandedProductKey &&
                                name.toLowerCase().contains(q);
                          });
                    if (!stillVisible) _expandedProductKey = null;
                  }
                });
              },
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  vertical: isTablet ? 8.0 : 6.0,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.textSecondary,
                  size: isTablet ? 22 : 20,
                ),
                hintText: 'Search your uploads...',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary.withOpacity(0.7),
                  fontSize: isTablet ? 14.0 : 13.0,
                ),
                suffixIcon: _searchQuery.trim().isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                            _expandedProductKey = null;
                          });
                        },
                        icon: Icon(
                          Icons.close,
                          color: AppColors.textSecondary,
                          size: isTablet ? 22 : 20,
                        ),
                      ),
              ),
              style: TextStyle(
                fontSize: isTablet ? 14.0 : 13.0,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(height: isTablet ? 12.0 : 10.0),

          ...filteredProducts.map((p) {
            final key = (p['name'] ?? '').toString();
            final isExpanded = _expandedProductKey == key;
            return _ProductStatTile(
              product: p,
              isTablet: isTablet,
              isExpanded: isExpanded,
              onUpdate: () {
                // Placeholder edit flow: route to product register.
                AppRouter.pushNamed(
                  context,
                  AppRoutes.productRegister,
                  arguments: {'product': p, 'mode': 'edit'},
                );
              },
              onDelete: () => _confirmDeleteProduct(key),
              onTap: () {
                setState(() {
                  _expandedProductKey = isExpanded ? null : key;
                });
              },
            );
          }),
          SizedBox(height: isTablet ? 16.0 : 12.0),
        ],
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        currentIndex: _currentBottomNavIndex,
        cartBadgeCount: _cartCount,
        onTap: (index) {
          setState(() {
            _currentBottomNavIndex = index;
          });

          switch (index) {
            case 0:
              AppRouter.pushReplacementNamed(context, AppRoutes.home);
              break;
            case 1:
              // Already on market
              break;
            case 2:
              AppRouter.pushNamed(context, AppRoutes.cart);
              break;
            case 3:
              _showCommissionDialog();
              break;
            case 4:
              AppRouter.pushNamed(context, AppRoutes.profile);
              break;
          }
        },
      ),
    );
  }
}

// (_NotificationBell removed; replaced by shared AppBarActionIcons)

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.isTablet,
    this.onTap,
  });

  final String title;
  final String value;
  final IconData icon;
  final bool isTablet;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(isTablet ? 16.0 : 14.0),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: isTablet ? 44 : 40,
                height: isTablet ? 44 : 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: isTablet ? 13.0 : 12.0,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: isTablet ? 20.0 : 18.0,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: isTablet ? 22 : 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ViewEvent {
  const _ViewEvent({
    required this.name,
    required this.isViewerLoggedIn,
    required this.timestamp,
  });

  final String? name;
  final bool isViewerLoggedIn;
  final DateTime timestamp;
}

class _ProductStatTile extends StatelessWidget {
  const _ProductStatTile({
    required this.product,
    required this.isTablet,
    required this.isExpanded,
    required this.onTap,
    required this.onUpdate,
    required this.onDelete,
  });

  final Map<String, dynamic> product;
  final bool isTablet;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final name = (product['name'] ?? '').toString();
    final price = (product['price'] as num?)?.toDouble() ?? 0.0;
    final views = (product['views'] as int?) ?? 0;
    final opens = (product['opens'] as int?) ?? 0;
    final interested = (product['interested'] as int?) ?? 0;
    final uploadedOn = (product['uploadedOn'] ?? 'N/A').toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  (product['image'] ?? 'asset/images/a.jpg').toString(),
                  width: isTablet ? 56 : 50,
                  height: isTablet ? 56 : 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: isTablet ? 56 : 50,
                      height: isTablet ? 56 : 50,
                      color: AppColors.primary.withOpacity(0.12),
                      child: Icon(Icons.image, color: AppColors.primary),
                    );
                  },
                ),
              ),
              title: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isTablet ? 15.0 : 14.0,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  children: [
                    _MiniStat(icon: Icons.visibility, text: '$views', isTablet: isTablet),
                    _MiniStat(icon: Icons.open_in_new, text: '$opens', isTablet: isTablet),
                    _MiniStat(icon: Icons.favorite, text: '$interested', isTablet: isTablet, color: Colors.red),
                  ],
                ),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: isTablet ? 16.0 : 14.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.textSecondary,
                    size: isTablet ? 20 : 18,
                  ),
                ],
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: EdgeInsets.fromLTRB(
                  isTablet ? 16.0 : 14.0,
                  0,
                  isTablet ? 16.0 : 14.0,
                  isTablet ? 14.0 : 12.0,
                ),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(isTablet ? 12.0 : 10.0),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DetailRow(label: 'Date Uploaded', value: uploadedOn, isTablet: isTablet),
                      const SizedBox(height: 8),
                      _DetailRow(label: 'Status', value: 'Published', isTablet: isTablet),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: onUpdate,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.darkGreen,
                                side: const BorderSide(color: AppColors.darkGreen, width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: isTablet ? 12 : 10,
                                ),
                              ),
                              child: const Text('Update'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: onDelete,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFD93211),
                                side: const BorderSide(color: Color(0xFFD93211), width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: isTablet ? 12 : 10,
                                ),
                              ),
                              child: const Text('Delete'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 220),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.isTablet,
  });

  final String label;
  final String value;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: isTablet ? 13.0 : 12.0,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: isTablet ? 13.0 : 12.0,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.text,
    required this.isTablet,
    this.color,
  });

  final IconData icon;
  final String text;
  final bool isTablet;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: isTablet ? 16 : 14,
          color: color ?? Colors.orange,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: isTablet ? 13.0 : 12.0,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}







