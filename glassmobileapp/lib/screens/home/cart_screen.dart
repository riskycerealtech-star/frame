import 'package:flutter/material.dart';

import '../../config/app_router.dart';
import '../../constants/colors.dart';
import '../../constants/routes.dart';
import '../../widgets/common/bottom_navigation_bar_widget.dart';
import '../../widgets/common/commission_dialog.dart';
import '../../widgets/common/app_bar_action_icons.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Bottom navigation
  int _currentBottomNavIndex = 2;
  static const int _notificationCount = 14;
  static const int _cartCount = 2;

  // Commission dialog state
  final bool _isFirstRowOccupied = false;

  // Keep in sync with CommissionDialog fixed fee.
  static const double _fixedCommissionFee = 10.00;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final Map<String, _SellerRating> _sellerRatingsByRecordKey = {};

  // Mock sold frames list (replace with real API later)
  final List<_SoldFrameRecord> _soldFrames = [
    _SoldFrameRecord(
      sellerName: 'Drew',
      frameName: "Oakley Men's OO9102 Holbrook",
      price: 35.00,
      soldAt: DateTime(2025, 12, 22, 9, 40),
      status: 'Completed',
    ),
    _SoldFrameRecord(
      sellerName: 'Sophia',
      frameName: 'Ray-Ban RB2140 Wayfarer',
      price: 25.00,
      soldAt: DateTime(2025, 12, 21, 18, 12),
      status: 'Completed',
    ),
    _SoldFrameRecord(
      sellerName: 'Ava',
      frameName: 'Prada PR 17WS Cat-Eye',
      price: 55.00,
      soldAt: DateTime(2025, 12, 21, 14, 5),
      status: 'Pending',
    ),
    _SoldFrameRecord(
      sellerName: 'Michael',
      frameName: 'Gucci GG0061S Square',
      price: 40.00,
      soldAt: DateTime(2025, 12, 20, 12, 5),
      status: 'Completed',
    ),
  ];

  String _formatDateTime(DateTime dt) {
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
    final date = '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]}, ${dt.year}';
    final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$date $hour12:$minute $ampm';
  }

  bool _isPendingStatus(String status) => status.trim().toLowerCase() == 'pending';
  bool _isCompletedStatus(String status) => status.trim().toLowerCase() == 'completed';

  double _commissionFeeFor(_SoldFrameRecord record) {
    if (!_isCompletedStatus(record.status)) return 0;
    return record.price < _fixedCommissionFee ? record.price : _fixedCommissionFee;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _recordKey(_SoldFrameRecord r) =>
      '${r.sellerName}|${r.frameName}|${r.soldAt.millisecondsSinceEpoch}';

  Future<void> _showRateSellerDialog(_SoldFrameRecord record) async {
    final key = _recordKey(record);
    final existing = _sellerRatingsByRecordKey[key];
    int stars = existing?.stars ?? 5;
    final commentCtrl = TextEditingController(text: existing?.comment ?? '');

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        final isTablet = MediaQuery.of(ctx).size.width > 600;
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Dialog(
              backgroundColor: AppColors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: EdgeInsets.all(isTablet ? 18.0 : 14.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rate Seller',
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      record.sellerName,
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Stars
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) {
                        final filled = i < stars;
                        return IconButton(
                          onPressed: () => setModalState(() => stars = i + 1),
                          splashRadius: 20,
                          icon: Icon(
                            filled ? Icons.star : Icons.star_border,
                            color: filled ? Colors.amber.shade700 : AppColors.border,
                            size: isTablet ? 30 : 28,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        '$stars/5',
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Comment (optional)
                    TextField(
                      controller: commentCtrl,
                      maxLines: 3,
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                        hintText: 'Write a comment (optional)',
                        hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.7)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.black, width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.black, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.black, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      style: const TextStyle(color: Colors.black),
                    ),

                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red, width: 1),
                              padding: EdgeInsets.symmetric(vertical: isTablet ? 12 : 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _sellerRatingsByRecordKey[key] = _SellerRating(
                                  stars: stars,
                                  comment: commentCtrl.text.trim().isEmpty ? null : commentCtrl.text.trim(),
                                  ratedAt: DateTime.now(),
                                );
                              });
                              Navigator.of(ctx).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.white,
                              padding: EdgeInsets.symmetric(vertical: isTablet ? 12 : 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                            child: Text(existing == null ? 'Submit' : 'Update'),
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
      },
    );

    commentCtrl.dispose();
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

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appBarBg = isDark ? AppColors.primary : AppColors.white;
    final appBarFg = isDark ? AppColors.white : Colors.black;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final filtered = _searchQuery.trim().isEmpty
        ? _soldFrames
        : _soldFrames.where((r) {
            final q = _searchQuery.trim().toLowerCase();
            return r.sellerName.toLowerCase().contains(q) ||
                r.frameName.toLowerCase().contains(q) ||
                r.status.toLowerCase().contains(q);
          }).toList();

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
                    'Cart',
                    style: TextStyle(
                      fontSize: isTablet ? 18.0 : 16.0,
                      fontWeight: FontWeight.bold,
                      color: appBarFg,
                    ),
                  ),
                  Text(
                    'Sold Frames',
                    style: TextStyle(
                      fontSize: isTablet ? 13.0 : 12.0,
                      color: appBarFg.withOpacity(0.9),
                    ),
                  ),
                ],
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
              onCartTap: () {
                // Already on Cart
              },
            ),
          ],
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
        children: [
          Text(
            'People Sold Frames',
            style: TextStyle(
              fontSize: isTablet ? 18.0 : 16.0,
              fontWeight: FontWeight.bold,
              color: onSurface,
            ),
          ),
          SizedBox(height: isTablet ? 12.0 : 10.0),
          // Search input
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 12.0 : 10.0,
              vertical: isTablet ? 4.0 : 3.0,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(4),
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
                });
              },
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  vertical: isTablet ? 6.0 : 4.0,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.textSecondary,
                  size: isTablet ? 22 : 20,
                ),
                prefixIconConstraints: BoxConstraints(
                  minWidth: isTablet ? 40 : 36,
                  minHeight: isTablet ? 34 : 30,
                ),
                hintText: 'Search sold frames...',
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
                          });
                        },
                        constraints: BoxConstraints(
                          minWidth: isTablet ? 40 : 36,
                          minHeight: isTablet ? 34 : 30,
                        ),
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
          if (filtered.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 32),
                child: Text(
                  _searchQuery.trim().isEmpty ? 'No sold frames yet' : 'No results',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: isTablet ? 14.0 : 13.0,
                  ),
                ),
              ),
            )
          else
            ...filtered.map((r) {
              final recordKey = _recordKey(r);
              final rating = _sellerRatingsByRecordKey[recordKey];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.all(isTablet ? 14.0 : 12.0),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: isTablet ? 44 : 40,
                      height: isTablet ? 44 : 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.sell_outlined, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.sellerName,
                            style: TextStyle(
                              fontSize: isTablet ? 14.0 : 13.0,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (rating != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                ...List.generate(
                                  5,
                                  (i) => Icon(
                                    i < rating.stars ? Icons.star : Icons.star_border,
                                    size: isTablet ? 16 : 14,
                                    color: i < rating.stars ? Colors.amber.shade700 : AppColors.border,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Rated',
                                  style: TextStyle(
                                    fontSize: isTablet ? 12.5 : 11.5,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            if ((rating.comment ?? '').isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                '"${rating.comment!}"',
                                style: TextStyle(
                                  fontSize: isTablet ? 12.5 : 11.5,
                                  color: AppColors.textSecondary,
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                          const SizedBox(height: 4),
                          Text(
                            r.frameName,
                            style: TextStyle(
                              fontSize: isTablet ? 13.0 : 12.0,
                              color: AppColors.textSecondary,
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _formatDateTime(r.soldAt),
                                  style: TextStyle(
                                    fontSize: isTablet ? 12.5 : 11.5,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              Text(
                                '\$${r.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: isTablet ? 14.0 : 13.0,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          if (_isCompletedStatus(r.status)) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Commission: \$${_commissionFeeFor(r).toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: isTablet ? 12.5 : 11.5,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  'Remaining: \$${(r.price - _commissionFeeFor(r)).toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: isTablet ? 13.0 : 12.0,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: (_isPendingStatus(r.status) ? Colors.orange : Colors.green)
                                        .withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: (_isPendingStatus(r.status) ? Colors.orange : Colors.green)
                                          .withOpacity(0.35),
                                    ),
                                  ),
                                  child: Text(
                                    r.status,
                                    style: TextStyle(
                                      color: _isPendingStatus(r.status)
                                          ? Colors.orange.shade800
                                          : Colors.green.shade700,
                                      fontSize: isTablet ? 12.0 : 11.0,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                if (_isCompletedStatus(r.status)) ...[
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    height: isTablet ? 34 : 32,
                                    child: OutlinedButton(
                                      onPressed: () => _showRateSellerDialog(r),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.primary,
                                        side: BorderSide(color: AppColors.primary.withOpacity(0.6)),
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        rating == null ? 'Rate Seller' : 'Edit Rating',
                                        style: TextStyle(
                                          fontSize: isTablet ? 12.5 : 11.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
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
              AppRouter.pushNamed(context, AppRoutes.myMarket);
              break;
            case 2:
              // Already on cart
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

class _SoldFrameRecord {
  const _SoldFrameRecord({
    required this.sellerName,
    required this.frameName,
    required this.price,
    required this.soldAt,
    required this.status,
  });

  final String sellerName;
  final String frameName;
  final double price;
  final DateTime soldAt;
  final String status;
}

class _SellerRating {
  const _SellerRating({
    required this.stars,
    required this.ratedAt,
    this.comment,
  });

  final int stars;
  final String? comment;
  final DateTime ratedAt;
}






