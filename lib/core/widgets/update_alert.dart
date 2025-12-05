import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import '../constants/app_style.dart';
import '../constants/constants.dart';
import '../constants/kolors.dart';
import 'custom_button.dart';

void updateAlert(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isDismissible: true,
    enableDrag: true,
    builder: (context) {
      final animation = ModalRoute.of(context)!.animation!;

      return AnimatedPadding(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutQuint,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: kRadiusTop,
            color: Colors.transparent,
          ),
          child: ClipRRect(
            borderRadius: kRadiusTop,
            child: BackdropFilter(
              filter: ColorFilter.mode(
                Kolors.kPureWhite.withValues(alpha: 0.96),
                BlendMode.srcOver,
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Kolors.kPureWhite,
                      Kolors.kPureWhite.withValues(alpha: 0.96),
                    ],
                    stops: const [0.0, 0.8],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 40.r,
                      spreadRadius: 10.r,
                      offset: const Offset(0, -10),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 32.h,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Close button
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            icon: Icon(
                              Icons.close,
                              size: 24.w,
                              color: Kolors.kSecondaryText,
                            ),
                            onPressed: () => Navigator.pop(context),
                            splashRadius: 20.r,
                          ),
                        ),

                        // Animated illustration
                        ScaleTransition(
                          scale: CurvedAnimation(
                            parent: animation,
                            curve: const Interval(
                              0.0,
                              0.6,
                              curve: Curves.elasticOut,
                            ),
                          ),
                          child: FadeTransition(
                            opacity: CurvedAnimation(
                              parent: animation,
                              curve: const Interval(0.2, 1.0),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Kolors.kPrimary.withValues(
                                      alpha: 0.1,
                                    ),
                                    blurRadius: 30.r,
                                    spreadRadius: 5.r,
                                  ),
                                ],
                              ),
                              child: Lottie.asset(
                                'assets/animations/rocket.json',
                                width: 180.w,
                                height: 180.h,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // Title with animated entry
                        SlideTransition(
                          position:
                              Tween<Offset>(
                                begin: const Offset(0, 0.3),
                                end: Offset.zero,
                              ).animate(
                                CurvedAnimation(
                                  parent: animation,
                                  curve: const Interval(
                                    0.3,
                                    0.8,
                                    curve: Curves.easeOutBack,
                                  ),
                                ),
                              ),
                          child: FadeTransition(
                            opacity: CurvedAnimation(
                              parent: animation,
                              curve: const Interval(0.4, 1.0),
                            ),
                            child: Text(
                              'New Features Incoming!',
                              style: appStyle(
                                26.sp,
                                Kolors.kDark,
                                FontWeight.w800,
                              ).copyWith(letterSpacing: -0.8, height: 1.3),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        SizedBox(height: 12.h),

                        // Animated body text
                        FadeTransition(
                          opacity: CurvedAnimation(
                            parent: animation,
                            curve: const Interval(0.5, 1.0),
                          ),
                          child: Transform.translate(
                            offset: Offset(0, 30 * (1 - animation.value)),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              child: Column(
                                children: [
                                  Text.rich(
                                    TextSpan(
                                      text: 'We\'re excited to announce that ',
                                      style: appStyle(
                                        16.sp,
                                        Kolors.textGray,
                                        FontWeight.w400,
                                      ).copyWith(height: 1.6),
                                      children: [
                                        TextSpan(
                                          text: 'new features',
                                          style: appStyle(
                                            16.sp,
                                            Kolors.kPrimary,
                                            FontWeight.w600,
                                          ),
                                        ),
                                        TextSpan(
                                          text:
                                              ' are currently in development!',
                                          style: appStyle(
                                            16.sp,
                                            Kolors.textGray,
                                            FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 12.h),
                                  Text(
                                    'Stay tuned for amazing updates coming soon.',
                                    style: appStyle(
                                      16.sp,
                                      Kolors.textGray,
                                      FontWeight.w400,
                                    ).copyWith(height: 1.6),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 36.h),

                        // Animated action button
                        ScaleTransition(
                          scale: CurvedAnimation(
                            parent: animation,
                            curve: const Interval(
                              0.5,
                              1.0,
                              curve: Curves.elasticOut,
                            ),
                          ),
                          child: FadeTransition(
                            opacity: CurvedAnimation(
                              parent: animation,
                              curve: const Interval(0.6, 1.0),
                            ),
                            child: CustomButton(
                              radius: 50.r,
                              text: 'Got It!',
                              textColor: Kolors.jetBlack,
                              btnHieght: 56.h,
                              btnWidth: double.infinity,
                              gradient: const LinearGradient(
                                colors: [
                                  Kolors.mellowLime,
                                  Colors.yellowAccent,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              onTap: () => Navigator.pop(context),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).viewInsets.bottom > 0
                              ? MediaQuery.of(context).viewInsets.bottom + 16.h
                              : 16.h,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
