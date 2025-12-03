import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';
import '../constants/app_style.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.controller,
    this.hintText,
    this.onChanged,
    this.focusNode,
    this.initialValue,
    this.maxLines = 1,
    this.label,
    this.obscureText = false,
    this.validator,
    this.textInputAction,
    this.enabled = true,
    this.readOnly = false,
    this.onTap,
  });

  final String? hintText;
  final String? label;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final void Function()? onEditingComplete;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? initialValue;
  final int? maxLines;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final bool enabled;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => TextFormField(
    cursorColor: AppColors.primaryLight,
    obscureText: obscureText,
    textInputAction: textInputAction ?? TextInputAction.next,
    onEditingComplete: onEditingComplete,
    onFieldSubmitted: onFieldSubmitted,
    onChanged: onChanged,
    keyboardType: keyboardType,
    initialValue: initialValue,
    controller: controller,
    focusNode: focusNode,
    maxLines: maxLines,
    enabled: enabled,
    readOnly: readOnly,
    onTap: onTap,
    validator: validator ?? (value) => null,
    style: appStyle(
      14.sp,
      enabled ? AppColors.textPrimaryLight : Colors.grey.shade600,
      FontWeight.w500,
    ),
    decoration: InputDecoration(
      hintText: hintText,
      prefixIcon: prefixIcon != null
          ? Padding(
              padding: EdgeInsets.only(left: 16.w, right: 12.w),
              child: IconTheme(
                data: IconThemeData(color: Colors.grey.shade600, size: 22.r),
                child: prefixIcon!,
              ),
            )
          : null,
      suffixIcon: suffixIcon,
      label: label != null ? Text(label!) : null,
      labelStyle: appStyle(14.sp, Colors.grey.shade600, FontWeight.w500),
      floatingLabelStyle: appStyle(
        12.sp,
        AppColors.primaryLight,
        FontWeight.w600,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 20.h),
      hintStyle: appStyle(
        14.sp,
        enabled ? Colors.grey.shade600 : Colors.grey.shade400,
        FontWeight.w400,
      ).copyWith(letterSpacing: -0.5, height: 1.4),
      helperStyle: appStyle(12.sp, Colors.grey.shade500, FontWeight.w400),
      errorStyle: appStyle(12.sp, AppColors.error, FontWeight.w500),
      errorMaxLines: 2,
      border: _inputBorder(),
      enabledBorder: _inputBorder(),
      focusedBorder: _focusedBorder(),
      errorBorder: _errorBorder(),
      focusedErrorBorder: _errorBorder(),
      disabledBorder: _inputBorder(color: Colors.grey.shade300),
      filled: !enabled,
      fillColor: !enabled ? Colors.grey.shade50 : null,
    ),
  );

  OutlineInputBorder _inputBorder({Color? color}) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(20.r),
    borderSide: BorderSide(color: color ?? Colors.grey.shade200, width: 1.w),
  );

  OutlineInputBorder _focusedBorder() => OutlineInputBorder(
    borderRadius: BorderRadius.circular(20.r),
    borderSide: BorderSide(color: AppColors.superLike, width: 1.w),
  );

  OutlineInputBorder _errorBorder() => OutlineInputBorder(
    borderRadius: BorderRadius.circular(20.r),
    borderSide: BorderSide(color: AppColors.error, width: 1.w),
  );
}
