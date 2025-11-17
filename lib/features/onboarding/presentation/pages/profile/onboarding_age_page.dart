import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_style.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../../../../core/utils/validators.dart';
import '../../providers/onboarding_provider.dart';

class OnboardingAgePage extends ConsumerStatefulWidget {
  const OnboardingAgePage({super.key});

  @override
  ConsumerState<OnboardingAgePage> createState() => _OnboardingAgePageState();
}

class _OnboardingAgePageState extends ConsumerState<OnboardingAgePage> {
  final _ageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final age = ref.read(onboardingProvider).age;
    if (age != null) {
      _ageController.text = age.toString();
    }
  }

  @override
  void dispose() {
    _ageController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    if (_formKey.currentState!.validate()) {
      final age = int.parse(_ageController.text.trim());
      ref.read(onboardingProvider.notifier).setAge(age);
      HapticFeedback.mediumImpact();
      context.push('/onboarding/interests');
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
                      Text(
                        'How old\nare you?',
                        style: appStyle(
                          32,
                          Colors.black,
                          FontWeight.w900,
                        ).copyWith(letterSpacing: -0.5, height: 1.2),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'You must be 18 or older to use DataDate',
                        style: appStyle(
                          15,
                          Colors.grey[600]!,
                          FontWeight.w400,
                        ).copyWith(letterSpacing: -0.2, height: 1.4),
                      ),
                      SizedBox(height: 40.h),

                      CustomTextField(
                        label: 'Age',
                        hintText: 'Enter your age',
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        validator: Validators.age,
                        prefixIcon: const Icon(Icons.cake_outlined),
                      ),

                      SizedBox(height: 24.h),

                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.amber[50],
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.amber[700],
                              size: 24,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                'Your age will be visible on your profile',
                                style: appStyle(
                                  13,
                                  Colors.amber[900]!,
                                  FontWeight.w500,
                                ).copyWith(height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(24.w),
              child: CustomButton(text: 'Continue', onPressed: _handleContinue),
            ),
          ],
        ),
      ),
    );
  }
}
