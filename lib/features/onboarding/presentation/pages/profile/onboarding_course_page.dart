import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_style.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../../../../core/widgets/onboarding_progress.dart';
import '../../providers/onboarding_provider.dart';

class OnboardingCoursePage extends ConsumerStatefulWidget {
  const OnboardingCoursePage({super.key});

  @override
  ConsumerState<OnboardingCoursePage> createState() =>
      _OnboardingCoursePageState();
}

class _OnboardingCoursePageState extends ConsumerState<OnboardingCoursePage> {
  final _courseController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final course = ref.read(onboardingProvider).course;
    if (course != null) {
      _courseController.text = course;
    }
  }

  @override
  void dispose() {
    _courseController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    if (_formKey.currentState!.validate()) {
      ref
          .read(onboardingProvider.notifier)
          .setCourse(_courseController.text.trim());
      HapticFeedback.mediumImpact();
      context.push('/onboarding/profile/graduation');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            HapticFeedback.lightImpact();
            context.pop();
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const OnboardingProgress(currentStep: 6, totalSteps: 10),
                      SizedBox(height: 20.h),
                      Text(
                        'What are you\nstudying?',
                        style: appStyle(
                          32,
                          Colors.black,
                          FontWeight.w900,
                        ).copyWith(letterSpacing: -0.5, height: 1.2),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Enter your course or major',
                        style: appStyle(
                          15,
                          Colors.grey[600]!,
                          FontWeight.w400,
                        ).copyWith(letterSpacing: -0.2, height: 1.4),
                      ),
                      SizedBox(height: 40.h),

                      CustomTextField(
                        label: 'Course/Major',
                        hintText: 'e.g., Computer Science, Business, Medicine',
                        controller: _courseController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your course';
                          }
                          return null;
                        },
                        prefixIcon: const Icon(Icons.school_outlined),
                      ),

                      SizedBox(height: 24.h),

                      // Popular courses suggestions
                      Text(
                        'Popular Courses',
                        style: appStyle(14, Colors.grey[700]!, FontWeight.w600),
                      ),
                      SizedBox(height: 12.h),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children:
                            [
                              'Computer Science',
                              'Business',
                              'Engineering',
                              'Medicine',
                              'Law',
                              'Psychology',
                              'Arts',
                              'Economics',
                            ].map((course) {
                              return GestureDetector(
                                onTap: () {
                                  _courseController.text = course;
                                  HapticFeedback.selectionClick();
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 14.w,
                                    vertical: 8.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(20.r),
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  child: Text(
                                    course,
                                    style: appStyle(
                                      13,
                                      Colors.grey[700]!,
                                      FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(24.w),
              child: CustomButton(text: 'Continue', onTap: _handleContinue),
            ),
          ],
        ),
      ),
    );
  }
}
