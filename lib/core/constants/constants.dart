import 'package:datadate/core/constants/kolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

LinearGradient kGradient = const LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Kolors.kPrimaryLight, Kolors.kWhite, Kolors.kPrimary],
);

LinearGradient kPGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Kolors.kPrimaryLight,
    Kolors.kPrimaryLight.withValues(alpha: 0.7),
    Kolors.kPrimary,
  ],
);

LinearGradient kBtnGradient = const LinearGradient(
  begin: Alignment.bottomLeft,
  end: Alignment.bottomRight,
  colors: [Kolors.kPrimaryLight, Kolors.kWhite],
);

BorderRadiusGeometry kClippingRadius = BorderRadius.only(
  topLeft: Radius.circular(10.r),
  topRight: Radius.circular(10.r),
);

BorderRadiusGeometry kRadiusAll = BorderRadius.circular(12.r);

BorderRadiusGeometry kRadiusTop = BorderRadius.only(
  topLeft: Radius.circular(16.r),
  topRight: Radius.circular(16.r),
);

BorderRadiusGeometry kRadiusBottom = BorderRadius.only(
  bottomLeft: Radius.circular(12.r),
  bottomRight: Radius.circular(12.r),
);
BorderRadiusGeometry kFlatRadius = BorderRadius.circular(9.r);

BorderRadiusGeometry kRoundedRadius = BorderRadius.circular(20.r);

// Widget Function(BuildContext, String)? placeholder = (p0, p1) =>
//     Image.asset(R.ASSETS_IMAGES_PLACEHOLDER_WEBP, fit: BoxFit.cover);

// Widget Function(BuildContext, String, Object)? errorWidget = (p0, p1, p3) =>
//     Image.asset(R.ASSETS_IMAGES_PLACEHOLDER_WEBP, fit: BoxFit.cover);

String avatar =
    'https://firebasestorage.googleapis.com/v0/b/authenification-b4dc9.appspot.com/o/uploads%2Favatar.png?alt=media&token=7da81de9-a163-4296-86ac-3194c490ce15';
