import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class CommissionDialog extends StatefulWidget {
  final Function(int) onCommissionSelected;
  final bool isFirstRowOccupied;

  const CommissionDialog({
    super.key,
    required this.onCommissionSelected,
    this.isFirstRowOccupied = false,
  });

  @override
  State<CommissionDialog> createState() => _CommissionDialogState();
}

class _CommissionDialogState extends State<CommissionDialog> {
  static const double _commissionAmount = 10.00;
  bool _isAccepted = false;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Dialog(
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: screenSize.height * 0.6,
          maxWidth: isTablet ? 500 : screenSize.width * 0.9,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(isTablet ? 16.0 : 14.0),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.monetization_on,
                    color: AppColors.white,
                    size: isTablet ? 24.0 : 20.0,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Commission Fees',
                          style: TextStyle(
                            fontSize: isTablet ? 22.0 : 20.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Fixed commission rate',
                          style: TextStyle(
                            fontSize: isTablet ? 14.0 : 12.0,
                            color: AppColors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(isTablet ? 16.0 : 14.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Commission Display
                  Container(
                    padding: EdgeInsets.all(isTablet ? 20.0 : 16.0),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.monetization_on,
                          color: AppColors.primary,
                          size: isTablet ? 36.0 : 32.0,
                        ),
                        SizedBox(height: isTablet ? 12.0 : 10.0),
                        Text(
                          'Commission',
                          style: TextStyle(
                            fontSize: isTablet ? 16.0 : 14.0,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: isTablet ? 6.0 : 4.0),
                        Text(
                          '\$${_commissionAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: isTablet ? 28.0 : 24.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: isTablet ? 16.0 : 12.0),
                  
                  // Checkbox to accept
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isAccepted = !_isAccepted;
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: isTablet ? 24.0 : 22.0,
                          height: isTablet ? 24.0 : 22.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _isAccepted ? AppColors.primary : AppColors.border,
                              width: 2,
                            ),
                            color: _isAccepted ? AppColors.primary : Colors.transparent,
                          ),
                          child: _isAccepted
                              ? Icon(
                                  Icons.check,
                                  color: AppColors.white,
                                  size: isTablet ? 16.0 : 14.0,
                                )
                              : null,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'I accept the commission fee',
                          style: TextStyle(
                            fontSize: isTablet ? 14.0 : 12.0,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Footer Buttons
            Container(
              padding: EdgeInsets.all(isTablet ? 16.0 : 14.0),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: BorderSide(color: AppColors.border, width: 1),
                        padding: EdgeInsets.symmetric(
                          vertical: isTablet ? 12.0 : 10.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: isTablet ? 16.0 : 14.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 12),

                  // Continue Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isAccepted
                          ? () {
                              print('🔵 CONTINUE CLICKED - Fixed commission: \$${_commissionAmount.toStringAsFixed(2)}');
                              // Pass 0 as default tier since we only have one commission now
                              widget.onCommissionSelected(0);
                              print('✅ CALLBACK CALLED - Dialog will be closed by parent');
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isAccepted ? AppColors.primary : AppColors.primary.withOpacity(0.5),
                        foregroundColor: AppColors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: isTablet ? 12.0 : 10.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: isTablet ? 16.0 : 14.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
