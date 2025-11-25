import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

class LottieLoadingIndicator extends StatelessWidget {
  final double? width;
  final double? height;
  final String? animationPath;

  const LottieLoadingIndicator({
    super.key,
    this.width,
    this.height,
    this.animationPath,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(
        animationPath ?? 'assets/lottie/loader.json',
        width: width ?? 80.w,
        height: height ?? 80.h,
        fit: BoxFit.contain,
      ),
    );
  }
}
