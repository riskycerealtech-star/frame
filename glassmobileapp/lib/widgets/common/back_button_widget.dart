import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class BackButtonWidget extends StatelessWidget {
  final VoidCallback? onPressed;
  final double? size;
  final Color? color;
  final EdgeInsets? padding;

  const BackButtonWidget({
    super.key,
    this.onPressed,
    this.size,
    this.color,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final isTablet = screenWidth > 600;
    
    return GestureDetector(
      onTap: onPressed ?? () => Navigator.pop(context),
      child: Container(
        padding: padding ?? EdgeInsets.all(8),
        child: Icon(
          Icons.arrow_back_ios,
          size: size ?? (isTablet ? 24.0 : 22.0),
          color: color ?? AppColors.white,
        ),
      ),
    );
  }
}
