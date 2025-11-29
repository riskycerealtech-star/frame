import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/app_constants.dart';

class DashboardProductScreen extends StatefulWidget {
  const DashboardProductScreen({super.key});

  @override
  State<DashboardProductScreen> createState() => _DashboardProductScreenState();
}

class _DashboardProductScreenState extends State<DashboardProductScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final isTablet = screenWidth > 600;
    final isLargeScreen = screenWidth > 900;
    
    // Responsive values
    final horizontalPadding = isTablet ? 24.0 : 16.0;
    final titleFontSize = isLargeScreen ? 28.0 : (isTablet ? 24.0 : 20.0);
    final cardPadding = isTablet ? 20.0 : 16.0;
    
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          'Product Dashboard',
          style: TextStyle(
            fontSize: isTablet ? 20.0 : 18.0,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
      ),
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  
                  // Welcome Section
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(cardPadding),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome to Product Dashboard',
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Manage your sunglasses inventory, track sales, and monitor performance.',
                          style: TextStyle(
                            fontSize: isTablet ? 16.0 : 14.0,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Stats Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: isTablet ? 3 : 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: isTablet ? 1.5 : 1.2,
                    children: [
                      _buildStatCard(
                        'Total Products',
                        '24',
                        Icons.inventory_2,
                        Colors.blue,
                        isTablet,
                      ),
                      _buildStatCard(
                        'Active Listings',
                        '18',
                        Icons.visibility,
                        Colors.green,
                        isTablet,
                      ),
                      _buildStatCard(
                        'Sold Items',
                        '6',
                        Icons.shopping_bag,
                        Colors.orange,
                        isTablet,
                      ),
                      _buildStatCard(
                        'Total Revenue',
                        '\$2,450',
                        Icons.attach_money,
                        Colors.purple,
                        isTablet,
                      ),
                      _buildStatCard(
                        'Pending Orders',
                        '3',
                        Icons.pending,
                        Colors.red,
                        isTablet,
                      ),
                      _buildStatCard(
                        'Avg Rating',
                        '4.8',
                        Icons.star,
                        Colors.amber,
                        isTablet,
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Quick Actions
                  Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: isTablet ? 20.0 : 18.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          'Add Product',
                          Icons.add_circle,
                          Colors.green,
                          isTablet,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          'View Orders',
                          Icons.list_alt,
                          Colors.blue,
                          isTablet,
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          'Analytics',
                          Icons.analytics,
                          Colors.purple,
                          isTablet,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          'Settings',
                          Icons.settings,
                          Colors.grey,
                          isTablet,
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Recent Activity
                  Text(
                    'Recent Activity',
                    style: TextStyle(
                      fontSize: isTablet ? 20.0 : 18.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  _buildActivityList(isTablet),
                  
                  SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 20.0 : 16.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? 12.0 : 10.0),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: isTablet ? 24.0 : 20.0,
            ),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isTablet ? 20.0 : 18.0,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: isTablet ? 12.0 : 10.0,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color color, bool isTablet) {
    return Container(
      height: isTablet ? 60.0 : 50.0,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          onTap: () {
            // Handle action button tap
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: isTablet ? 20.0 : 18.0,
              ),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: isTablet ? 14.0 : 12.0,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityList(bool isTablet) {
    final activities = [
      {'title': 'New order received', 'subtitle': 'Ray-Ban Aviator - \$150', 'time': '2 hours ago', 'color': Colors.green},
      {'title': 'Product sold', 'subtitle': 'Oakley Sunglasses - \$200', 'time': '5 hours ago', 'color': Colors.blue},
      {'title': 'New review', 'subtitle': '5 stars for Gucci Sunglasses', 'time': '1 day ago', 'color': Colors.amber},
      {'title': 'Inventory updated', 'subtitle': 'Added 3 new products', 'time': '2 days ago', 'color': Colors.purple},
    ];

    return Column(
      children: activities.map((activity) {
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(isTablet ? 16.0 : 12.0),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
            border: Border.all(
              color: AppColors.border,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: activity['color'] as Color,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity['title'] as String,
                      style: TextStyle(
                        fontSize: isTablet ? 14.0 : 12.0,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      activity['subtitle'] as String,
                      style: TextStyle(
                        fontSize: isTablet ? 12.0 : 10.0,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                activity['time'] as String,
                style: TextStyle(
                  fontSize: isTablet ? 10.0 : 8.0,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
