class AppConstants {
  // App Information
  static const String appName = 'Glass Root';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Sunglass Marketplace';
  static const String versionText = 'Version 1.0';
  
  // Animation Durations
  static const Duration splashDuration = Duration(seconds: 4);
  static const Duration shortAnimation = Duration(milliseconds: 300);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation = Duration(milliseconds: 800);
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 32.0;
  
  static const double defaultRadius = 12.0;
  static const double smallRadius = 8.0;
  static const double largeRadius = 16.0;
  static const double extraLargeRadius = 24.0;
  
  // Icon Sizes
  static const double smallIconSize = 16.0;
  static const double defaultIconSize = 24.0;
  static const double largeIconSize = 32.0;
  static const double extraLargeIconSize = 48.0;
  
  // Font Sizes
  static const double smallFontSize = 12.0;
  static const double defaultFontSize = 14.0;
  static const double mediumFontSize = 16.0;
  static const double largeFontSize = 18.0;
  static const double extraLargeFontSize = 24.0;
  static const double titleFontSize = 28.0;
  static const double headingFontSize = 32.0;
  
  // Image Sizes
  static const double smallImageSize = 40.0;
  static const double defaultImageSize = 60.0;
  static const double largeImageSize = 80.0;
  static const double extraLargeImageSize = 120.0;
  
  // Button Heights
  static const double smallButtonHeight = 32.0;
  static const double defaultButtonHeight = 48.0;
  static const double largeButtonHeight = 56.0;
  static const double extraLargeButtonHeight = 64.0;
  
  // Card Dimensions
  static const double cardElevation = 2.0;
  static const double cardRadius = 12.0;
  static const double cardPadding = 16.0;
  
  // List Item Heights
  static const double listItemHeight = 56.0;
  static const double largeListItemHeight = 72.0;
  static const double extraLargeListItemHeight = 88.0;
  
  // Grid Constants
  static const int defaultGridCrossAxisCount = 2;
  static const double gridSpacing = 16.0;
  static const double gridChildAspectRatio = 0.75;
  
  // API Constants
  static const int defaultTimeout = 30; // seconds
  static const int maxRetries = 3;
  static const int pageSize = 20;
  
  // Validation Constants
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 50;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int maxDescriptionLength = 500;
  static const int maxTitleLength = 100;
  
  // File Upload Constants
  static const int maxImageSize = 50 * 1024 * 1024; // 50MB
  static const int maxVideoSize = 50 * 1024 * 1024; // 50MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];
  static const List<String> allowedVideoTypes = ['mp4', 'mov', 'avi'];
  
  // Commission Constants
  static const double defaultCommissionRate = 0.1; // 10%
  static const double minCommissionRate = 0.05; // 5%
  static const double maxCommissionRate = 0.25; // 25%
  
  // Order Status
  static const String orderPending = 'pending';
  static const String orderConfirmed = 'confirmed';
  static const String orderShipped = 'shipped';
  static const String orderDelivered = 'delivered';
  static const String orderCancelled = 'cancelled';
  static const String orderReturned = 'returned';
  
  // User Roles
  static const String roleUser = 'user';
  static const String roleSeller = 'seller';
  static const String roleAdmin = 'admin';
  
  // Product Status
  static const String productDraft = 'draft';
  static const String productActive = 'active';
  static const String productInactive = 'inactive';
  static const String productSold = 'sold';
  
  // Notification Types
  static const String notificationOrder = 'order';
  static const String notificationMessage = 'message';
  static const String notificationSystem = 'system';
  static const String notificationPromotion = 'promotion';
}
