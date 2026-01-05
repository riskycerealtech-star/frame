import 'package:flutter/material.dart';

import '../../config/app_router.dart';
import '../../config/app_theme.dart';
import '../../constants/colors.dart';

class BuyFrameScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const BuyFrameScreen({
    super.key,
    required this.product,
  });

  @override
  State<BuyFrameScreen> createState() => _BuyFrameScreenState();
}

enum _PaymentMethod { card, paypal, applePay, googlePay }

class _BuyFrameScreenState extends State<BuyFrameScreen> {
  final _formKey = GlobalKey<FormState>();

  int _step = 0; // 0 = customer info, 1 = card payment

  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _address1 = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _zip = TextEditingController();
  final _country = TextEditingController(text: 'United States');

  final _cardNumber = TextEditingController();
  final _nameOnCard = TextEditingController();
  final _expiry = TextEditingController();
  final _cvv = TextEditingController();

  // Payment method (card step)
  _PaymentMethod _paymentMethod = _PaymentMethod.card;
  String? _expMonth;
  String? _expYear;
  bool _billingSameAsShipping = true;

  bool _stepLoading = false;
  bool _submitting = false;

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _phone.dispose();
    _address1.dispose();
    _city.dispose();
    _state.dispose();
    _zip.dispose();
    _country.dispose();
    _cardNumber.dispose();
    _nameOnCard.dispose();
    _expiry.dispose();
    _cvv.dispose();
    super.dispose();
  }

  Future<void> _goToPayment() async {
    FocusScope.of(context).unfocus();
    if (_stepLoading || _submitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _stepLoading = true);
    await Future.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    setState(() {
      _step = 1;
      _stepLoading = false;
    });
  }

  void _backToCustomer() {
    FocusScope.of(context).unfocus();
    if (_stepLoading || _submitting) return;
    setState(() => _step = 0);
  }

  Future<void> _placeOrder() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    setState(() => _submitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Order submitted successfully'),
        backgroundColor: AppColors.primary,
        duration: Duration(seconds: 2),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    AppRouter.pop(context);
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool requiredField = true,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: (v) {
        if (!requiredField) return null;
        if ((v ?? '').trim().isEmpty) return 'Required';
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  Widget _paymentMethodTile({
    required bool isTablet,
    required _PaymentMethod value,
    required Widget leading,
    required String label,
  }) {
    final selected = _paymentMethod == value;
    return InkWell(
      onTap: () => setState(() => _paymentMethod = value),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 16 : 12,
          vertical: isTablet ? 14 : 12,
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                size: isTablet ? 18 : 16,
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? AppColors.textPrimary : AppColors.textSecondary,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _paymentMethodCard({
    required _PaymentMethod value,
    required Widget leading,
    required String label,
  }) {
    final selected = _paymentMethod == value;
    return Padding(
      padding: const EdgeInsets.only(right: 14),
      child: InkWell(
        onTap: () => setState(() => _paymentMethod = value),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              size: 16,
              color: selected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? AppColors.textPrimary : AppColors.textSecondary,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _brandChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE9ECEF),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF6B7280),
        ),
      ),
    );
  }

  Widget _buildPaymentDetails(bool isTablet) {
    if (_paymentMethod != _PaymentMethod.card) {
      final label = switch (_paymentMethod) {
        _PaymentMethod.paypal => 'PayPal',
        _PaymentMethod.applePay => 'Apple Pay',
        _PaymentMethod.googlePay => 'Google Pay',
        _ => 'Payment',
      };
      return Padding(
        padding: EdgeInsets.all(isTablet ? 14 : 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selected method',
              style: TextStyle(
                fontSize: isTablet ? 14 : 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'This is a UI mock. You can connect real payment APIs later.',
              style: TextStyle(
                fontSize: isTablet ? 13 : 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    const months = [
      '01 - January',
      '02 - February',
      '03 - March',
      '04 - April',
      '05 - May',
      '06 - June',
      '07 - July',
      '08 - August',
      '09 - September',
      '10 - October',
      '11 - November',
      '12 - December',
    ];
    final nowYear = DateTime.now().year;
    final years = List<String>.generate(12, (i) => (nowYear + i).toString());

    return Padding(
      padding: EdgeInsets.all(isTablet ? 14 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _brandChip('VISA'),
                _brandChip('Mastercard'),
                _brandChip('AMEX'),
                _brandChip('Discover'),
                _brandChip('JCB'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _cardNumber,
            keyboardType: TextInputType.number,
            validator: (v) {
              if (_paymentMethod != _PaymentMethod.card) return null;
              if ((v ?? '').trim().isEmpty) return 'Required';
              return null;
            },
            decoration: const InputDecoration(
              labelText: 'Card Number *',
              suffixIcon: Icon(Icons.lock_outline),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _expMonth,
                  isExpanded: true,
                  items: months.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                  onChanged: (v) => setState(() => _expMonth = v),
                  validator: (v) {
                    if (_paymentMethod != _PaymentMethod.card) return null;
                    if (v == null || v.isEmpty) return 'Required';
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Month *',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _expYear,
                  isExpanded: true,
                  items: years.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
                  onChanged: (v) => setState(() => _expYear = v),
                  validator: (v) {
                    if (_paymentMethod != _PaymentMethod.card) return null;
                    if (v == null || v.isEmpty) return 'Required';
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Year *',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _cvv,
            keyboardType: TextInputType.number,
            validator: (v) {
              if (_paymentMethod != _PaymentMethod.card) return null;
              if ((v ?? '').trim().isEmpty) return 'Required';
              return null;
            },
            decoration: const InputDecoration(
              labelText: 'Security Code *',
              suffixIcon: Icon(Icons.info_outline, color: Colors.orange),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => setState(() => _billingSameAsShipping = !_billingSameAsShipping),
            child: Row(
              children: [
                Checkbox(
                  value: _billingSameAsShipping,
                  onChanged: (v) => setState(() => _billingSameAsShipping = v ?? true),
                  activeColor: AppColors.primary,
                ),
                Expanded(
                  child: Text(
                    'My billing information is the same as my shipping information.',
                    style: TextStyle(
                      fontSize: isTablet ? 13 : 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepChip({
    required String label,
    required bool selected,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: selected ? AppColors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final name = (widget.product['name'] ?? 'Frame').toString();
    final price = (widget.product['price'] as num?)?.toDouble();
    final image = widget.product['image']?.toString();

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 8,
        title: Text(
          'Buy Frame',
          style: TextStyle(
            fontSize: isTablet ? 20.0 : 18.0,
            fontWeight: FontWeight.normal,
          ),
        ),
        leading: IconButton(
          onPressed: () => AppRouter.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Theme(
        // Force a light look for the page content, even if the app defaults to dark.
        data: AppTheme.light().copyWith(
          inputDecorationTheme: AppTheme.light().inputDecorationTheme.copyWith(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            isTablet ? 24 : 16,
            isTablet ? 18 : 14,
            isTablet ? 24 : 16,
            isTablet ? 24 : 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product summary
              Container(
                padding: EdgeInsets.all(isTablet ? 14 : 12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: isTablet ? 64 : 56,
                      height: isTablet ? 64 : 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.primary.withOpacity(0.08),
                        border: Border.all(color: AppColors.border),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: image == null
                          ? const Icon(Icons.image, color: AppColors.primary)
                          : Image.asset(
                              image,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.image, color: AppColors.primary),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: isTablet ? 16 : 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            price == null ? '' : '\$${price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: isTablet ? 16 : 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: isTablet ? 18 : 14),

              Row(
                children: [
                  _stepChip(label: 'Customer info', selected: _step == 0),
                  const SizedBox(width: 10),
                  _stepChip(label: 'Card', selected: _step == 1),
                ],
              ),
              SizedBox(height: isTablet ? 16 : 12),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (_step == 0) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Customer information',
                          style: TextStyle(
                            fontSize: isTablet ? 18 : 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      SizedBox(height: isTablet ? 10 : 8),
                      _field(label: 'Full name', controller: _fullName),
                      const SizedBox(height: 10),
                      _field(label: 'Email', controller: _email, keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 10),
                      _field(label: 'Phone', controller: _phone, keyboardType: TextInputType.phone),
                      const SizedBox(height: 10),
                      _field(label: 'Address', controller: _address1),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: _field(label: 'City', controller: _city)),
                          const SizedBox(width: 10),
                          Expanded(child: _field(label: 'State', controller: _state)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: _field(label: 'ZIP code', controller: _zip, keyboardType: TextInputType.number)),
                          const SizedBox(width: 10),
                          Expanded(child: _field(label: 'Country', controller: _country)),
                        ],
                      ),
                      SizedBox(height: isTablet ? 16 : 14),
                      SizedBox(
                        width: double.infinity,
                        height: isTablet ? 48 : 46,
                        child: ElevatedButton(
                          onPressed: (_submitting || _stepLoading) ? null : _goToPayment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                          ),
                          child: _stepLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Continue'),
                        ),
                      ),
                    ] else ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Payment Method',
                          style: TextStyle(
                            fontSize: isTablet ? 18 : 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      SizedBox(height: isTablet ? 10 : 8),

                      // Layout inspired by provided screenshot
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: isTablet
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 260,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        _paymentMethodTile(
                                          isTablet: isTablet,
                                          value: _PaymentMethod.card,
                                          leading: const SizedBox.shrink(),
                                          label: 'Credit Card',
                                        ),
                                        Divider(height: 1, thickness: 1, color: AppColors.border),
                                        _paymentMethodTile(
                                          isTablet: isTablet,
                                          value: _PaymentMethod.paypal,
                                          leading: const SizedBox.shrink(),
                                          label: 'PayPal',
                                        ),
                                        Divider(height: 1, thickness: 1, color: AppColors.border),
                                        _paymentMethodTile(
                                          isTablet: isTablet,
                                          value: _PaymentMethod.applePay,
                                          leading: const SizedBox.shrink(),
                                          label: 'Apple Pay',
                                        ),
                                        Divider(height: 1, thickness: 1, color: AppColors.border),
                                        _paymentMethodTile(
                                          isTablet: isTablet,
                                          value: _PaymentMethod.googlePay,
                                          leading: const SizedBox.shrink(),
                                          label: 'Google Pay',
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        border: Border(left: BorderSide(color: AppColors.border)),
                                      ),
                                      child: _buildPaymentDetails(isTablet),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  _buildPaymentDetails(isTablet),
                                  const Divider(height: 1, thickness: 1, color: AppColors.border),
                                  SizedBox(
                                    height: 74,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      physics: const BouncingScrollPhysics(),
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                      child: Row(
                                        children: [
                                          _paymentMethodCard(
                                            value: _PaymentMethod.card,
                                            leading: const Icon(Icons.credit_card, color: AppColors.textPrimary),
                                            label: 'Credit Card',
                                          ),
                                          _paymentMethodCard(
                                            value: _PaymentMethod.paypal,
                                            leading: const Text(
                                              'PayPal',
                                              style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF003087)),
                                            ),
                                            label: 'PayPal',
                                          ),
                                          _paymentMethodCard(
                                            value: _PaymentMethod.applePay,
                                            leading: const Icon(Icons.apple, color: Colors.black),
                                            label: 'Apple Pay',
                                          ),
                                          _paymentMethodCard(
                                            value: _PaymentMethod.googlePay,
                                            leading: const Text(
                                              'G',
                                              style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF4285F4)),
                                            ),
                                            label: 'Google Pay',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      SizedBox(height: isTablet ? 16 : 14),
                      Row(
                        children: [
                          TextButton(
                            onPressed: (_submitting || _stepLoading) ? null : _backToCustomer,
                            child: const Text('Back'),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SizedBox(
                              height: isTablet ? 48 : 46,
                              child: ElevatedButton(
                                onPressed: _submitting ? null : _placeOrder,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.white,
                                ),
                                child: _submitting
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : const Text('Place Order'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}









