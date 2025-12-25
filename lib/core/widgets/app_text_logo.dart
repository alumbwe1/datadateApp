import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' show SizeExtension;

import '../constants/app_colors.dart';
import '../constants/app_style.dart';

class AppTextLogo extends StatelessWidget {
  const AppTextLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return   // HeartLink Logo with Gradient
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        AppColors.heartGradient.createShader(
                          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                        ),
                    child: Text(
                      'HeartLink',
                      style: appStyle(
                        24.sp,
                        Colors.white,
                        FontWeight.w800,
                      ).copyWith(letterSpacing: -0.5, height: 1),
                    ),
                  );
  }
}