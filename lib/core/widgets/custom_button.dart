import 'package:datadate/core/widgets/reusable_text.dart' show ReusableText;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_style.dart';
import '../constants/kolors.dart';

enum ButtonVariant { filled, outlined, text }

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    this.onTap,
    this.btnWidth,
    this.text,
    this.bold,
    this.btnHieght,
    this.textSize,
    this.borderColor,
    this.radius,
    this.btnColor,
    this.gradient,
    this.elevation,
    this.textColor,
    this.variant = ButtonVariant.filled,
    this.boxShadow,
    this.icon,
    this.iconGap = 8.0,
  }) : assert(
         text != null || icon != null,
         'Either text or icon must be provided',
       );

  final void Function()? onTap;
  final double? btnWidth;
  final List<BoxShadow>? boxShadow;
  final double? btnHieght;
  final double? radius;
  final String? text;
  final double? textSize;
  final FontWeight? bold;
  final Color? borderColor;
  final Color? btnColor;
  final Gradient? gradient;
  final double? elevation;
  final Color? textColor;
  final ButtonVariant variant;
  final Widget? icon;
  final double iconGap;

  @override
  Widget build(BuildContext context) {
    final resolvedColors = _resolveColors();

    return Material(
      elevation: elevation ?? 0,
      borderRadius: BorderRadius.circular(radius ?? 6.r),
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius ?? 6.r),
        onTap: onTap,
        child: Container(
          width: btnWidth ?? ScreenUtil().screenWidth,
          height: btnHieght ?? 48.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius ?? 6.r),
            gradient: gradient,
            color: gradient == null ? resolvedColors.backgroundColor : null,
            boxShadow: boxShadow,
            border: Border.all(
              width: _borderWidth,
              color: resolvedColors.borderColor,
            ),
          ),
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: _buildContent(resolvedColors.textColor),
            ),
          ),
        ),
      ),
    );
  }

  _ButtonColors _resolveColors() {
    switch (variant) {
      case ButtonVariant.filled:
        return _ButtonColors(
          backgroundColor: btnColor ?? Kolors.kPrimary,
          borderColor: borderColor ?? Colors.transparent,
          textColor: textColor ?? Colors.white,
        );
      case ButtonVariant.outlined:
        return _ButtonColors(
          backgroundColor: Colors.transparent,
          borderColor: borderColor ?? Kolors.kPrimary,
          textColor: textColor ?? Kolors.kPrimary,
        );
      case ButtonVariant.text:
        return _ButtonColors(
          backgroundColor: Colors.transparent,
          borderColor: Colors.transparent,
          textColor: textColor ?? Kolors.kPrimary,
        );
    }
  }

  double get _borderWidth => variant == ButtonVariant.outlined ? 0.7.w : 0.0;

  Widget _buildContent(Color textColor) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (icon != null) icon!,
      if (icon != null && text != null) SizedBox(width: iconGap),
      if (text != null)
        ReusableText(
          text: text!,
          style: appStyle(
            textSize ?? 16.sp,
            textColor,
            bold ?? FontWeight.w600,
          ).copyWith(letterSpacing: -0.02, height: 1.2),
        ),
    ],
  );
}

class _ButtonColors {
  _ButtonColors({
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
  });
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
}
