import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';

import '../../../config/app_router.dart';
import '../../../constants/colors.dart';
import '../../../constants/routes.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> with TickerProviderStateMixin {
  int _currentBottomNavIndex = 2; // Statistics tab in admin bottom nav

  String _overviewChartType = 'Pie'; // [Pie, Bar chart, Histogram, Line graph, Scatter plot, Area chart]
  String _overviewMetric = 'Sales'; // [Users, Sales]
  bool _didNormalizeOverviewFilters = false;

  static const List<String> _overviewChartTypes = [
    'Pie',
    'Bar chart',
    'Histogram',
    'Line graph',
    'Scatter plot',
    'Area chart',
  ];

  // Commission over time controls (minute -> years)
  String _commissionRange = '24h';
  String _commissionBucket = 'Auto'; // [Auto, Minute, Hour, Day, Week, Month, Year]

  static const List<String> _commissionRanges = [
    '1m',
    '15m',
    '1h',
    '6h',
    '24h',
    '7d',
    '30d',
    '6mo',
    '1y',
    '5y',
  ];

  static const List<String> _commissionBuckets = [
    'Auto',
    'Minute',
    'Hour',
    'Day',
    'Week',
    'Month',
    'Year',
  ];

  String _normalizeChartType(String v) {
    // Backward compatibility: older builds used "Graph"
    if (v.trim().toLowerCase() == 'graph') return 'Line graph';
    if (_overviewChartTypes.contains(v)) return v;
    return 'Pie';
  }

  DateTime _subtractMonths(DateTime from, int months) {
    final year = from.year + ((from.month - 1 - months) ~/ 12);
    final month = ((from.month - 1 - months) % 12) + 1;
    final day = min(from.day, DateTime(year, month + 1, 0).day);
    return DateTime(year, month, day, from.hour, from.minute, from.second);
  }

  DateTime _subtractYears(DateTime from, int years) {
    final year = from.year - years;
    final day = min(from.day, DateTime(year, from.month + 1, 0).day);
    return DateTime(year, from.month, day, from.hour, from.minute, from.second);
  }

  DateTime _rangeStart(DateTime now, String range) {
    switch (range) {
      case '1m':
        return now.subtract(const Duration(minutes: 1));
      case '15m':
        return now.subtract(const Duration(minutes: 15));
      case '1h':
        return now.subtract(const Duration(hours: 1));
      case '6h':
        return now.subtract(const Duration(hours: 6));
      case '24h':
        return now.subtract(const Duration(hours: 24));
      case '7d':
        return now.subtract(const Duration(days: 7));
      case '30d':
        return now.subtract(const Duration(days: 30));
      case '6mo':
        return _subtractMonths(now, 6);
      case '1y':
        return _subtractYears(now, 1);
      case '5y':
        return _subtractYears(now, 5);
      default:
        return now.subtract(const Duration(hours: 24));
    }
  }

  String _autoBucketForRange(Duration range) {
    if (range.inMinutes <= 360) return 'Minute'; // <= 6h
    if (range.inHours <= 24 * 7) return 'Hour'; // <= 7d
    if (range.inDays <= 180) return 'Day'; // <= ~6mo
    if (range.inDays <= 365 * 5) return 'Month'; // <= 5y
    return 'Year';
  }

  String _formatBucketLabel(DateTime dt, String bucket) {
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
    String two(int v) => v.toString().padLeft(2, '0');

    switch (bucket.toLowerCase()) {
      case 'minute':
        return '${two(dt.hour)}:${two(dt.minute)}';
      case 'hour':
        return '${months[dt.month - 1]} ${two(dt.day)} ${two(dt.hour)}h';
      case 'day':
      case 'week':
        return '${two(dt.day)} ${months[dt.month - 1]}';
      case 'month':
        return '${months[dt.month - 1]} ${dt.year.toString().substring(2)}';
      case 'year':
        return '${dt.year}';
      default:
        return '${two(dt.day)} ${months[dt.month - 1]}';
    }
  }

  // Generates a mock commission series for any range & bucket (minute -> years).
  List<_SeriesPoint> _generateCommissionSeries({
    required DateTime from,
    required DateTime to,
    required String bucket,
    int maxPoints = 120,
  }) {
    final lower = bucket.toLowerCase();
    final List<_SeriesPoint> points = [];

    // Helper: deterministic "noise"
    double noise(int i) => (((i * 37) % 11) - 5).toDouble(); // -5..5

    // Compute next timestamp based on bucket
    DateTime next(DateTime t, int step) {
      switch (lower) {
        case 'minute':
          return t.add(Duration(minutes: step));
        case 'hour':
          return t.add(Duration(hours: step));
        case 'day':
          return t.add(Duration(days: step));
        case 'week':
          return t.add(Duration(days: 7 * step));
        case 'month':
          return DateTime(t.year, t.month + step, 1);
        case 'year':
          return DateTime(t.year + step, 1, 1);
        default:
          return t.add(const Duration(hours: 1));
      }
    }

    // Determine step size to keep points <= maxPoints
    int step = 1;
    if (lower == 'minute') {
      final total = max(1, to.difference(from).inMinutes);
      step = max(1, (total / maxPoints).ceil());
    } else if (lower == 'hour') {
      final total = max(1, to.difference(from).inHours);
      step = max(1, (total / maxPoints).ceil());
    } else if (lower == 'day') {
      final total = max(1, to.difference(from).inDays);
      step = max(1, (total / maxPoints).ceil());
    } else if (lower == 'week') {
      final total = max(1, (to.difference(from).inDays / 7).ceil());
      step = max(1, (total / maxPoints).ceil());
    } else if (lower == 'month') {
      final total = max(1, (to.year - from.year) * 12 + (to.month - from.month));
      step = max(1, (total / maxPoints).ceil());
    } else if (lower == 'year') {
      final total = max(1, to.year - from.year);
      step = max(1, (total / maxPoints).ceil());
    }

    // Align start for month/year to clean boundaries
    DateTime t = from;
    if (lower == 'month') {
      t = DateTime(from.year, from.month, 1);
    } else if (lower == 'year') {
      t = DateTime(from.year, 1, 1);
    }

    int i = 0;
    while (!t.isAfter(to)) {
      // Scale per bucket step
      double minutesInBucket;
      if (lower == 'month') {
        minutesInBucket = 30.0 * 24 * 60 * step;
      } else if (lower == 'year') {
        minutesInBucket = 365.0 * 24 * 60 * step;
      } else {
        final t2 = next(t, step);
        minutesInBucket = max(1.0, t2.difference(t).inMinutes.toDouble());
      }

      // Base commission rate per minute
      const basePerMinute = 0.06; // $0.06 per minute average
      final wave = 1.0 + 0.35 * sin(i / 3.0) + 0.15 * sin(i / 7.0);
      final value = max(0.0, (basePerMinute * minutesInBucket * wave) + noise(i));

      points.add(_SeriesPoint(label: _formatBucketLabel(t, bucket), value: value));
      t = next(t, step);
      i++;

      if (i > maxPoints + 5) break;
    }

    return points;
  }

  // Mock stats (replace with real API later)
  final int _publishedFrames = 54;
  final int _usersCreated = 128;
  final int _commissionIncomeTotal = 1234898;

  final List<_SellerStat> _topSellers = const [
    _SellerStat(name: 'Drew', soldCount: 18, totalRevenue: 620.0),
    _SellerStat(name: 'Sophia', soldCount: 14, totalRevenue: 510.0),
    _SellerStat(name: 'Michael', soldCount: 11, totalRevenue: 455.0),
  ];

  final _ProductStat _mostSoldProduct = const _ProductStat(
    name: "Oakley Men's OO9102 Holbrook",
    soldCount: 12,
  );

  final _SearchStat _mostSearchType = const _SearchStat(
    type: 'Aviator',
    searches: 286,
  );

  // Charts (mock)
  final List<_PieSlice> _salesByType = const [
    _PieSlice(label: 'Aviator', value: 30, color: Color(0xFF111111)),
    _PieSlice(label: 'Wayfarer', value: 25, color: Color(0xFF8AC1ED)),
    _PieSlice(label: 'Round', value: 18, color: Color(0xFFD93211)),
    _PieSlice(label: 'Cat-Eye', value: 15, color: Color(0xFF1E884A)),
    _PieSlice(label: 'Other', value: 12, color: Color(0xFFBDBDBD)),
  ];

  final List<_PieSlice> _usersByType = const [
    _PieSlice(label: 'Buyers', value: 62, color: Color(0xFF111111)),
    _PieSlice(label: 'Sellers', value: 36, color: Color(0xFF8AC1ED)),
    _PieSlice(label: 'Admins', value: 2, color: Color(0xFFD93211)),
  ];

  final List<_SeriesPoint> _accountsCreatedLast7Days = const [
    _SeriesPoint(label: 'Mon', value: 8),
    _SeriesPoint(label: 'Tue', value: 12),
    _SeriesPoint(label: 'Wed', value: 10),
    _SeriesPoint(label: 'Thu', value: 16),
    _SeriesPoint(label: 'Fri', value: 14),
    _SeriesPoint(label: 'Sat', value: 9),
    _SeriesPoint(label: 'Sun', value: 11),
  ];

  final List<_SeriesPoint> _commissionLast7Days = const [
    _SeriesPoint(label: 'Mon', value: 32),
    _SeriesPoint(label: 'Tue', value: 44),
    _SeriesPoint(label: 'Wed', value: 28),
    _SeriesPoint(label: 'Thu', value: 50),
    _SeriesPoint(label: 'Fri', value: 46),
    _SeriesPoint(label: 'Sat', value: 34),
    _SeriesPoint(label: 'Sun', value: 40),
  ];

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    // Avoid dropdown assertion errors if hot-reload preserved an old value (e.g. "Graph").
    if (!_didNormalizeOverviewFilters) {
      final normalized = _normalizeChartType(_overviewChartType);
      if (normalized != _overviewChartType) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() {
            _overviewChartType = normalized;
            _didNormalizeOverviewFilters = true;
          });
        });
      } else {
        _didNormalizeOverviewFilters = true;
      }
    }

    final now = DateTime.now();
    final from = _rangeStart(now, _commissionRange);
    final rangeDuration = now.difference(from);
    final resolvedBucket =
        _commissionBucket == 'Auto' ? _autoBucketForRange(rangeDuration) : _commissionBucket;
    final commissionTimeSeries = _generateCommissionSeries(
      from: from,
      to: now,
      bucket: resolvedBucket,
    );

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              GestureDetector(
                onTap: () => AppRouter.pushNamed(context, AppRoutes.profile),
                child: CircleAvatar(
                  radius: isTablet ? 20.0 : 18.0,
                  backgroundColor: AppColors.white,
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
                      'Statistics',
                      style: TextStyle(
                        fontSize: isTablet ? 18.0 : 16.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    Text(
                      'Frames & app performance',
                      style: TextStyle(
                        fontSize: isTablet ? 13.0 : 12.0,
                        color: AppColors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kTextTabBarHeight),
            child: Container(
              color: const Color(0xFF919191),
              child: TabBar(
                labelColor: Colors.black,
                unselectedLabelColor: Colors.black.withOpacity(0.75),
                indicatorColor: Colors.black,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isTablet ? 14.0 : 12.0,
                ),
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Products'),
                  Tab(text: 'Users'),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _OverviewTab(
              isTablet: isTablet,
              publishedFrames: _publishedFrames,
              usersCreated: _usersCreated,
              commissionIncomeTotal: _commissionIncomeTotal,
              chartType: _overviewChartType,
              metric: _overviewMetric,
              onChartTypeChanged: (v) {
                if (v == null) return;
                setState(() => _overviewChartType = v);
              },
              onMetricChanged: (v) {
                if (v == null) return;
                setState(() => _overviewMetric = v);
              },
              commissionRange: _commissionRange,
              commissionBucket: _commissionBucket,
              onCommissionRangeChanged: (v) {
                if (v == null) return;
                setState(() => _commissionRange = v);
              },
              onCommissionBucketChanged: (v) {
                if (v == null) return;
                setState(() => _commissionBucket = v);
              },
              resolvedCommissionBucket: resolvedBucket,
              commissionTimeSeries: commissionTimeSeries,
              salesByType: _salesByType,
              usersByType: _usersByType,
              accountsSeries: _accountsCreatedLast7Days,
              commissionSeries: _commissionLast7Days,
            ),
            _ProductsTab(
              isTablet: isTablet,
              publishedFrames: _publishedFrames,
              mostSoldProduct: _mostSoldProduct,
              mostSearchType: _mostSearchType,
              salesByType: _salesByType,
            ),
            _UsersTab(
              isTablet: isTablet,
              usersCreated: _usersCreated,
              accountsSeries: _accountsCreatedLast7Days,
              topSellers: _topSellers,
            ),
          ],
        ),
        bottomNavigationBar: _AdminBottomNav(
          currentIndex: _currentBottomNavIndex,
          onTap: (index) {
            setState(() {
              _currentBottomNavIndex = index;
            });

            switch (index) {
              case 0:
                // Home (admin dashboard)
                AppRouter.pushReplacementNamed(context, AppRoutes.adminDashboard);
                break;
              case 1:
                // Products
                AppRouter.pushNamed(context, AppRoutes.adminProducts);
                break;
              case 2:
                // Statistics (already here)
                break;
              case 3:
                // Customers
                AppRouter.pushNamed(context, AppRoutes.adminUsers);
                break;
              case 4:
                // Settings
                AppRouter.pushNamed(context, AppRoutes.profile);
                break;
            }
          },
        ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({
    required this.isTablet,
    required this.publishedFrames,
    required this.usersCreated,
    required this.commissionIncomeTotal,
    required this.chartType,
    required this.metric,
    required this.onChartTypeChanged,
    required this.onMetricChanged,
    required this.commissionRange,
    required this.commissionBucket,
    required this.onCommissionRangeChanged,
    required this.onCommissionBucketChanged,
    required this.resolvedCommissionBucket,
    required this.commissionTimeSeries,
    required this.salesByType,
    required this.usersByType,
    required this.accountsSeries,
    required this.commissionSeries,
  });

  final bool isTablet;
  final int publishedFrames;
  final int usersCreated;
  final int commissionIncomeTotal;
  final String chartType;
  final String metric;
  final ValueChanged<String?> onChartTypeChanged;
  final ValueChanged<String?> onMetricChanged;
  final String commissionRange;
  final String commissionBucket;
  final ValueChanged<String?> onCommissionRangeChanged;
  final ValueChanged<String?> onCommissionBucketChanged;
  final String resolvedCommissionBucket;
  final List<_SeriesPoint> commissionTimeSeries;
  final List<_PieSlice> salesByType;
  final List<_PieSlice> usersByType;
  final List<_SeriesPoint> accountsSeries;
  final List<_SeriesPoint> commissionSeries;

  @override
  Widget build(BuildContext context) {
    final bool isPie = chartType.toLowerCase() == 'pie';
    final bool isUsers = metric.toLowerCase() == 'users';
    final String heading = isPie
        ? '${isUsers ? "Users" : "Sales"} distribution (pie)'
        : '${isUsers ? "Users" : "Sales"} ($chartType)';

    const chartItems = [
      'Pie',
      'Bar chart',
      'Histogram',
      'Line graph',
      'Scatter plot',
      'Area chart',
    ];
    final safeChartType = chartItems.contains(chartType) ? chartType : 'Pie';

    Widget buildChart() {
      final series = isUsers ? accountsSeries : commissionSeries;
      final lower = safeChartType.toLowerCase();

      switch (lower) {
        case 'pie':
          return Row(
            children: [
              SizedBox(
                width: isTablet ? 200 : 160,
                height: isTablet ? 200 : 160,
                child: _PieChart(slices: isUsers ? usersByType : salesByType),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PieLegend(
                  slices: isUsers ? usersByType : salesByType,
                  isTablet: isTablet,
                ),
              ),
            ],
          );
        case 'bar chart':
          return SizedBox(
            height: isTablet ? 180 : 160,
            child: _BarChart(
              series: series,
              barColor: isUsers ? const Color(0xFF111111) : const Color(0xFFD93211),
            ),
          );
        case 'histogram':
          return SizedBox(
            height: isTablet ? 180 : 160,
            child: _HistogramChart(
              series: series,
              barColor: isUsers ? const Color(0xFF111111) : const Color(0xFFD93211),
              // Users histogram uses multi-colors (different colors per bar)
              palette: isUsers
                  ? const [
                      Color(0xFF111111),
                      Color(0xFF8AC1ED),
                      Color(0xFF1E884A),
                      Color(0xFFD93211),
                    ]
                  : null,
            ),
          );
        case 'line graph':
          return SizedBox(
            height: isTablet ? 180 : 160,
            child: _LineChart(
              series: series,
              lineColor: isUsers ? const Color(0xFF111111) : const Color(0xFFD93211),
            ),
          );
        case 'scatter plot':
          return SizedBox(
            height: isTablet ? 180 : 160,
            child: _ScatterChart(
              series: series,
              dotColor: isUsers ? const Color(0xFF111111) : const Color(0xFFD93211),
            ),
          );
        case 'area chart':
          return SizedBox(
            height: isTablet ? 180 : 160,
            child: _AreaChart(
              series: series,
              color: isUsers ? const Color(0xFF1E884A) : const Color(0xFFD93211),
            ),
          );
        default:
          // fallback
          return SizedBox(
            height: isTablet ? 180 : 160,
            child: _LineChart(series: series, lineColor: const Color(0xFF111111)),
          );
      }
    }

    return ListView(
      padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
      children: [
        Row(
          children: [
            Expanded(
              child: _AnimatedStatCard(
                isTablet: isTablet,
                title: 'Frames Published',
                endValue: publishedFrames,
                icon: Icons.remove_red_eye_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _AnimatedStatCard(
                isTablet: isTablet,
                title: 'Accounts Created',
                endValue: usersCreated,
                icon: Icons.person_add_alt_1_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _AnimatedStatCard(
          key: const ValueKey('commissionIncomeCard'),
          isTablet: isTablet,
          title: 'Commission Income',
          endValue: commissionIncomeTotal,
          icon: Icons.monetization_on_outlined,
          valueColor: const Color(0xFFD93211),
        ),
        SizedBox(height: isTablet ? 16.0 : 12.0),
        // Filters row (Chart type + Data)
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: safeChartType,
                isExpanded: true,
                onChanged: onChartTypeChanged,
                items: chartItems
                    .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                    .toList(),
                decoration: InputDecoration(
                  isDense: true,
                  labelText: 'Chart',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.border, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: isTablet ? 10 : 8,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: metric,
                isExpanded: true,
                onChanged: onMetricChanged,
                items: const ['Users', 'Sales']
                    .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                    .toList(),
                decoration: InputDecoration(
                  isDense: true,
                  labelText: 'Data',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.border, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.primary, width: 1.5),
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
        const SizedBox(height: 12),
        Text(
          heading,
          style: TextStyle(
            fontSize: isTablet ? 16.0 : 14.0,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        _ChartCard(
          child: buildChart(),
        ),
        SizedBox(height: isTablet ? 16.0 : 12.0),
        Text(
          'Commission over time',
          style: TextStyle(
            fontSize: isTablet ? 16.0 : 14.0,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: commissionRange,
                isExpanded: true,
                onChanged: onCommissionRangeChanged,
                items: _StatisticsScreenState._commissionRanges
                    .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                    .toList(),
                decoration: InputDecoration(
                  isDense: true,
                  labelText: 'Range',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.border, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: isTablet ? 10 : 8,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: commissionBucket,
                isExpanded: true,
                onChanged: onCommissionBucketChanged,
                items: _StatisticsScreenState._commissionBuckets
                    .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                    .toList(),
                decoration: InputDecoration(
                  isDense: true,
                  labelText: 'Bucket',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.border, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.primary, width: 1.5),
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
        const SizedBox(height: 10),
        _ChartCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bucket: $resolvedCommissionBucket',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: isTablet ? 12.5 : 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: isTablet ? 180 : 160,
                child: _AreaChart(
                  series: commissionTimeSeries,
                  color: const Color(0xFFD93211),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LoopingCountText extends StatefulWidget {
  const _LoopingCountText({
    super.key,
    required this.endValue,
    required this.style,
    this.startValue = 1,
    this.restartDelay = const Duration(minutes: 1),
  });

  final int startValue;
  final int endValue;
  final TextStyle style;
  final Duration restartDelay;

  @override
  State<_LoopingCountText> createState() => _LoopingCountTextState();
}

class _LoopingCountTextState extends State<_LoopingCountText> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<int> _count;
  Timer? _restartTimer;
  bool _isDisposed = false;
  late final void Function(AnimationStatus) _statusListener;

  @override
  void initState() {
    super.initState();

    final end = widget.endValue;
    final duration = end >= 100000 ? const Duration(milliseconds: 2200) : const Duration(milliseconds: 1200);

    _controller = AnimationController(vsync: this, duration: duration);
    _count = IntTween(begin: widget.startValue, end: widget.endValue).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _statusListener = (status) {
      if (status == AnimationStatus.completed) {
        if (_isDisposed) return;
        _restartTimer?.cancel();
        _restartTimer = Timer(widget.restartDelay, () {
          if (_isDisposed || !mounted) return;
          _controller.reset();
          _controller.forward();
        });
      }
    };
    _controller.addStatusListener(_statusListener);

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant _LoopingCountText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.endValue != widget.endValue || oldWidget.startValue != widget.startValue) {
      _restartTimer?.cancel();
      _count = IntTween(begin: widget.startValue, end: widget.endValue).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      if (!_isDisposed) {
        _controller
          ..reset()
          ..forward();
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _restartTimer?.cancel();
    _controller.removeStatusListener(_statusListener);
    _controller.dispose();
    super.dispose();
  }

  String _formatWithCommas(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idxFromEnd = s.length - i;
      buf.write(s[i]);
      if (idxFromEnd > 1 && idxFromEnd % 3 == 1) {
        buf.write(',');
      }
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _count,
      builder: (context, _) {
        return Text(
          _formatWithCommas(_count.value),
          style: widget.style,
        );
      },
    );
  }
}

class _AnimatedStatCard extends StatelessWidget {
  const _AnimatedStatCard({
    super.key,
    required this.isTablet,
    required this.title,
    required this.endValue,
    required this.icon,
    this.valueColor,
  });

  final bool isTablet;
  final String title;
  final int endValue;
  final IconData icon;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                _LoopingCountText(
                  key: ValueKey('$title-$endValue'),
                  startValue: 1,
                  endValue: endValue,
                  restartDelay: const Duration(minutes: 1),
                  style: TextStyle(
                    fontSize: isTablet ? 20.0 : 18.0,
                    color: valueColor ?? AppColors.textPrimary,
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
}

class _ScatterChart extends StatelessWidget {
  const _ScatterChart({required this.series, required this.dotColor});

  final List<_SeriesPoint> series;
  final Color dotColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ScatterChartPainter(series: series, dotColor: dotColor),
    );
  }
}

class _ScatterChartPainter extends CustomPainter {
  _ScatterChartPainter({required this.series, required this.dotColor});

  final List<_SeriesPoint> series;
  final Color dotColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (series.isEmpty) return;

    final maxV = series.map((p) => p.value).reduce(max);
    final minV = series.map((p) => p.value).reduce(min);
    final range = max(1.0, (maxV - minV).toDouble());

    const paddingLeft = 26.0;
    const paddingBottom = 22.0;
    const paddingTop = 8.0;
    const paddingRight = 8.0;

    final chartW = size.width - paddingLeft - paddingRight;
    final chartH = size.height - paddingTop - paddingBottom;

    // axes
    final axisPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    canvas.drawLine(
      const Offset(paddingLeft, paddingTop),
      Offset(paddingLeft, paddingTop + chartH),
      axisPaint,
    );
    canvas.drawLine(
      Offset(paddingLeft, paddingTop + chartH),
      Offset(paddingLeft + chartW, paddingTop + chartH),
      axisPaint,
    );

    final dotPaint = Paint()..color = dotColor;
    for (int i = 0; i < series.length; i++) {
      final x = paddingLeft + (chartW * (i / max(1, series.length - 1)));
      final yNorm = (series[i].value - minV) / range;
      final y = paddingTop + chartH - (chartH * yNorm);
      canvas.drawCircle(Offset(x, y), 3.2, dotPaint);
    }

    // labels
    final textStyle = TextStyle(color: AppColors.textSecondary, fontSize: 10);
    for (int i = 0; i < series.length; i++) {
      final x = paddingLeft + (chartW * (i / max(1, series.length - 1)));
      final tp = TextPainter(
        text: TextSpan(text: series[i].label, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, paddingTop + chartH + 6));
    }
  }

  @override
  bool shouldRepaint(covariant _ScatterChartPainter oldDelegate) =>
      oldDelegate.series != series || oldDelegate.dotColor != dotColor;
}

class _AreaChart extends StatelessWidget {
  const _AreaChart({required this.series, required this.color});

  final List<_SeriesPoint> series;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _AreaChartPainter(series: series, color: color),
    );
  }
}

class _AreaChartPainter extends CustomPainter {
  _AreaChartPainter({required this.series, required this.color});

  final List<_SeriesPoint> series;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (series.isEmpty) return;

    final maxV = series.map((p) => p.value).reduce(max);
    final minV = series.map((p) => p.value).reduce(min);
    final range = max(1.0, (maxV - minV).toDouble());

    const paddingLeft = 26.0;
    const paddingBottom = 22.0;
    const paddingTop = 8.0;
    const paddingRight = 8.0;

    final chartW = size.width - paddingLeft - paddingRight;
    final chartH = size.height - paddingTop - paddingBottom;

    // axes
    final axisPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    canvas.drawLine(
      const Offset(paddingLeft, paddingTop),
      Offset(paddingLeft, paddingTop + chartH),
      axisPaint,
    );
    canvas.drawLine(
      Offset(paddingLeft, paddingTop + chartH),
      Offset(paddingLeft + chartW, paddingTop + chartH),
      axisPaint,
    );

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final fillPaint = Paint()
      ..color = color.withOpacity(0.18)
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < series.length; i++) {
      final x = paddingLeft + (chartW * (i / max(1, series.length - 1)));
      final yNorm = (series[i].value - minV) / range;
      final y = paddingTop + chartH - (chartH * yNorm);
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, paddingTop + chartH);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    fillPath.lineTo(paddingLeft + chartW, paddingTop + chartH);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    // labels
    final textStyle = TextStyle(color: AppColors.textSecondary, fontSize: 10);
    for (int i = 0; i < series.length; i++) {
      final x = paddingLeft + (chartW * (i / max(1, series.length - 1)));
      final tp = TextPainter(
        text: TextSpan(text: series[i].label, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, paddingTop + chartH + 6));
    }
  }

  @override
  bool shouldRepaint(covariant _AreaChartPainter oldDelegate) =>
      oldDelegate.series != series || oldDelegate.color != color;
}

class _HistogramChart extends StatelessWidget {
  const _HistogramChart({
    required this.series,
    required this.barColor,
    this.palette,
  });

  final List<_SeriesPoint> series;
  final Color barColor;
  final List<Color>? palette;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _HistogramChartPainter(series: series, barColor: barColor, palette: palette),
    );
  }
}

class _HistogramChartPainter extends CustomPainter {
  _HistogramChartPainter({required this.series, required this.barColor, this.palette});

  final List<_SeriesPoint> series;
  final Color barColor;
  final List<Color>? palette;

  @override
  void paint(Canvas canvas, Size size) {
    if (series.isEmpty) return;

    final maxV = series.map((p) => p.value).reduce(max).toDouble();

    const paddingLeft = 26.0;
    const paddingBottom = 22.0;
    const paddingTop = 8.0;
    const paddingRight = 8.0;

    final chartW = size.width - paddingLeft - paddingRight;
    final chartH = size.height - paddingTop - paddingBottom;

    // axes
    final axisPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    canvas.drawLine(
      const Offset(paddingLeft, paddingTop),
      Offset(paddingLeft, paddingTop + chartH),
      axisPaint,
    );
    canvas.drawLine(
      Offset(paddingLeft, paddingTop + chartH),
      Offset(paddingLeft + chartW, paddingTop + chartH),
      axisPaint,
    );

    final barW = (chartW / max(1, series.length)).toDouble();

    for (int i = 0; i < series.length; i++) {
      final barPaint = Paint()
        ..color = (palette == null || palette!.isEmpty
                ? barColor
                : palette![i % palette!.length])
            .withOpacity(0.85);
      final x = paddingLeft + (i * barW);
      final h = maxV == 0 ? 0.0 : ((series[i].value / maxV) * chartH).toDouble();
      // histogram bars touch (no gaps)
      final rect = Rect.fromLTWH(x, paddingTop + chartH - h, barW, h);
      canvas.drawRect(rect, barPaint);
    }

    // labels (sparse to avoid overlap)
    final textStyle = TextStyle(color: AppColors.textSecondary, fontSize: 10);
    for (int i = 0; i < series.length; i++) {
      if (series.length > 7 && i.isOdd) continue;
      final x = paddingLeft + (i * barW) + barW / 2;
      final tp = TextPainter(
        text: TextSpan(text: series[i].label, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, paddingTop + chartH + 6));
    }
  }

  @override
  bool shouldRepaint(covariant _HistogramChartPainter oldDelegate) =>
      oldDelegate.series != series ||
      oldDelegate.barColor != barColor ||
      oldDelegate.palette != palette;
}

class _ProductsTab extends StatelessWidget {
  const _ProductsTab({
    required this.isTablet,
    required this.publishedFrames,
    required this.mostSoldProduct,
    required this.mostSearchType,
    required this.salesByType,
  });

  final bool isTablet;
  final int publishedFrames;
  final _ProductStat mostSoldProduct;
  final _SearchStat mostSearchType;
  final List<_PieSlice> salesByType;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
      children: [
        _AnimatedStatCard(
          isTablet: isTablet,
          title: 'Frames Published',
          endValue: publishedFrames,
          icon: Icons.add_photo_alternate_outlined,
        ),
        SizedBox(height: isTablet ? 16.0 : 12.0),
        _InfoCard(
          title: 'Most sold product',
          value: mostSoldProduct.name,
          trailing: '${mostSoldProduct.soldCount} sold',
          isTablet: isTablet,
        ),
        const SizedBox(height: 12),
        _InfoCard(
          title: 'Most searched type',
          value: mostSearchType.type,
          trailing: '${mostSearchType.searches} searches',
          isTablet: isTablet,
        ),
        SizedBox(height: isTablet ? 16.0 : 12.0),
        Text(
          'Sales by type (pie)',
          style: TextStyle(
            fontSize: isTablet ? 16.0 : 14.0,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        _ChartCard(
          child: Row(
            children: [
              SizedBox(
                width: isTablet ? 200 : 160,
                height: isTablet ? 200 : 160,
                child: _PieChart(slices: salesByType),
              ),
              const SizedBox(width: 12),
              Expanded(child: _PieLegend(slices: salesByType, isTablet: isTablet)),
            ],
          ),
        ),
      ],
    );
  }
}

class _UsersTab extends StatelessWidget {
  const _UsersTab({
    required this.isTablet,
    required this.usersCreated,
    required this.accountsSeries,
    required this.topSellers,
  });

  final bool isTablet;
  final int usersCreated;
  final List<_SeriesPoint> accountsSeries;
  final List<_SellerStat> topSellers;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
      children: [
        _AnimatedStatCard(
          isTablet: isTablet,
          title: 'Accounts Created',
          endValue: usersCreated,
          icon: Icons.people_outline,
        ),
        SizedBox(height: isTablet ? 16.0 : 12.0),
        Text(
          'Account creation (graph)',
          style: TextStyle(
            fontSize: isTablet ? 16.0 : 14.0,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        _ChartCard(
          child: SizedBox(
            height: isTablet ? 180 : 160,
            child: _LineChart(series: accountsSeries, lineColor: const Color(0xFF1E884A)),
          ),
        ),
        SizedBox(height: isTablet ? 16.0 : 12.0),
        Text(
          'Top sellers (accounts sold more)',
          style: TextStyle(
            fontSize: isTablet ? 16.0 : 14.0,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        _ChartCard(
          child: Column(
            children: topSellers
                .map(
                  (s) => ListTile(
                    dense: true,
                    leading: Icon(Icons.emoji_events_outlined, color: const Color(0xFFD93211)),
                    title: Text(
                      s.name,
                      style: TextStyle(
                        fontSize: isTablet ? 14.0 : 13.0,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      '${s.soldCount} sold',
                      style: TextStyle(
                        fontSize: isTablet ? 13.0 : 12.0,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    trailing: Text(
                      '\$${s.totalRevenue.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: isTablet ? 13.5 : 12.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.value,
    required this.trailing,
    required this.isTablet,
  });

  final String title;
  final String value;
  final String trailing;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    return _ChartCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.label_outline, color: AppColors.primary),
          const SizedBox(width: 10),
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
                    fontSize: isTablet ? 14.0 : 13.0,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            trailing,
            style: TextStyle(
              fontSize: isTablet ? 13.0 : 12.0,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    return Container(
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
      child: child,
    );
  }
}

class _PieLegend extends StatelessWidget {
  const _PieLegend({required this.slices, required this.isTablet});

  final List<_PieSlice> slices;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final total = slices.fold<double>(0, (sum, s) => sum + s.value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: slices
          .map((s) {
            final pct = total == 0 ? 0 : (s.value / total) * 100;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: s.color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      s.label,
                      style: TextStyle(
                        fontSize: isTablet ? 13.0 : 12.0,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '${pct.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: isTablet ? 12.5 : 11.5,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          })
          .toList(),
    );
  }
}

class _PieChart extends StatelessWidget {
  const _PieChart({required this.slices});

  final List<_PieSlice> slices;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PieChartPainter(slices: slices),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  _PieChartPainter({required this.slices});

  final List<_PieSlice> slices;

  @override
  void paint(Canvas canvas, Size size) {
    final total = slices.fold<double>(0, (sum, s) => sum + s.value);
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (min(size.width, size.height) / 2).toDouble();

    final paint = Paint()..style = PaintingStyle.fill;
    double startAngle = -pi / 2;

    for (final s in slices) {
      final sweep = total == 0 ? 0.0 : ((s.value / total) * 2 * pi).toDouble();
      paint.color = s.color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        true,
        paint,
      );
      startAngle += sweep;
    }

    // donut hole
    final holePaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, radius * 0.55, holePaint);
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) => oldDelegate.slices != slices;
}

class _LineChart extends StatelessWidget {
  const _LineChart({required this.series, required this.lineColor});

  final List<_SeriesPoint> series;
  final Color lineColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LineChartPainter(series: series, lineColor: lineColor),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({required this.series, required this.lineColor});

  final List<_SeriesPoint> series;
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (series.isEmpty) return;

    final maxV = series.map((p) => p.value).reduce(max);
    final minV = series.map((p) => p.value).reduce(min);
    final range = max(1.0, (maxV - minV).toDouble());

    final paddingLeft = 26.0;
    final paddingBottom = 22.0;
    final paddingTop = 8.0;
    final paddingRight = 8.0;

    final chartW = size.width - paddingLeft - paddingRight;
    final chartH = size.height - paddingTop - paddingBottom;

    // axes
    final axisPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(paddingLeft, paddingTop),
      Offset(paddingLeft, paddingTop + chartH),
      axisPaint,
    );
    canvas.drawLine(
      Offset(paddingLeft, paddingTop + chartH),
      Offset(paddingLeft + chartW, paddingTop + chartH),
      axisPaint,
    );

    // line
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    for (int i = 0; i < series.length; i++) {
      final x = paddingLeft + (chartW * (i / max(1, series.length - 1)));
      final yNorm = (series[i].value - minV) / range;
      final y = paddingTop + chartH - (chartH * yNorm);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, linePaint);

    // points
    final dotPaint = Paint()..color = lineColor;
    for (int i = 0; i < series.length; i++) {
      final x = paddingLeft + (chartW * (i / max(1, series.length - 1)));
      final yNorm = (series[i].value - minV) / range;
      final y = paddingTop + chartH - (chartH * yNorm);
      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }

    // labels
    final textStyle = TextStyle(color: AppColors.textSecondary, fontSize: 10);
    for (int i = 0; i < series.length; i++) {
      final x = paddingLeft + (chartW * (i / max(1, series.length - 1)));
      final tp = TextPainter(
        text: TextSpan(text: series[i].label, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, paddingTop + chartH + 6));
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) =>
      oldDelegate.series != series || oldDelegate.lineColor != lineColor;
}

class _BarChart extends StatelessWidget {
  const _BarChart({required this.series, required this.barColor});

  final List<_SeriesPoint> series;
  final Color barColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BarChartPainter(series: series, barColor: barColor),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  _BarChartPainter({required this.series, required this.barColor});

  final List<_SeriesPoint> series;
  final Color barColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (series.isEmpty) return;

    final maxV = series.map((p) => p.value).reduce(max).toDouble();
    final paddingLeft = 26.0;
    final paddingBottom = 22.0;
    final paddingTop = 8.0;
    final paddingRight = 8.0;

    final chartW = size.width - paddingLeft - paddingRight;
    final chartH = size.height - paddingTop - paddingBottom;

    // axes
    final axisPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(paddingLeft, paddingTop),
      Offset(paddingLeft, paddingTop + chartH),
      axisPaint,
    );
    canvas.drawLine(
      Offset(paddingLeft, paddingTop + chartH),
      Offset(paddingLeft + chartW, paddingTop + chartH),
      axisPaint,
    );

    final barPaint = Paint()..color = barColor;
    final barW = (chartW / (series.length * 1.6)).toDouble();
    final gap = (barW * 0.6).toDouble();

    for (int i = 0; i < series.length; i++) {
      final x = paddingLeft + (i * (barW + gap)) + gap / 2;
      final h = maxV == 0 ? 0.0 : ((series[i].value / maxV) * chartH).toDouble();
      final rect = Rect.fromLTWH(x, paddingTop + chartH - h, barW, h);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(6)),
        barPaint,
      );
    }

    final textStyle = TextStyle(color: AppColors.textSecondary, fontSize: 10);
    for (int i = 0; i < series.length; i++) {
      final x = paddingLeft + (i * (barW + gap)) + gap / 2 + barW / 2;
      final tp = TextPainter(
        text: TextSpan(text: series[i].label, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, paddingTop + chartH + 6));
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) =>
      oldDelegate.series != series || oldDelegate.barColor != barColor;
}

class _AdminBottomNav extends StatelessWidget {
  const _AdminBottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF8AC1ED),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF8AC1ED),
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: isTablet ? 12.0 : 10.0,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: isTablet ? 10.0 : 9.0,
        ),
        selectedFontSize: isTablet ? 12.0 : 10.0,
        unselectedFontSize: isTablet ? 10.0 : 9.0,
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              currentIndex == 0 ? Icons.home : Icons.home_outlined,
              size: isTablet ? 24.0 : 22.0,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              currentIndex == 1 ? Icons.remove_red_eye : Icons.remove_red_eye_outlined,
              size: isTablet ? 24.0 : 22.0,
            ),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              currentIndex == 2 ? Icons.query_stats : Icons.query_stats_outlined,
              size: isTablet ? 24.0 : 22.0,
            ),
            label: 'Statistics',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              currentIndex == 3 ? Icons.people : Icons.people_outline,
              size: isTablet ? 24.0 : 22.0,
            ),
            label: 'Customers',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              currentIndex == 4 ? Icons.settings : Icons.settings_outlined,
              size: isTablet ? 24.0 : 22.0,
            ),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _PieSlice {
  const _PieSlice({required this.label, required this.value, required this.color});
  final String label;
  final double value;
  final Color color;
}

class _SeriesPoint {
  const _SeriesPoint({required this.label, required this.value});
  final String label;
  final double value;
}

class _SellerStat {
  const _SellerStat({required this.name, required this.soldCount, required this.totalRevenue});
  final String name;
  final int soldCount;
  final double totalRevenue;
}

class _ProductStat {
  const _ProductStat({required this.name, required this.soldCount});
  final String name;
  final int soldCount;
}

class _SearchStat {
  const _SearchStat({required this.type, required this.searches});
  final String type;
  final int searches;
}






