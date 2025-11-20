import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_style.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/widgets/onboarding_progress.dart';
import '../../providers/onboarding_provider.dart';

class OnboardingBioPage extends ConsumerStatefulWidget {
  const OnboardingBioPage({super.key});

  @override
  ConsumerState<OnboardingBioPage> createState() => _OnboardingBioPageState();
}

class _OnboardingBioPageState extends ConsumerState<OnboardingBioPage> {
  final _bioController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final bio = ref.read(onboardingProvider).bio;
    if (bio != null) {
      _bioController.text = bio;
    }
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    if (_formKey.currentState!.validate()) {
      ref.read(onboardingProvider.notifier).setBio(_bioController.text.trim());
      HapticFeedback.mediumImpact();
      context.push('/onboarding/profile/course');
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
                      const OnboardingProgress(currentStep: 5, totalSteps: 10),
                      SizedBox(height: 20.h),
                      Text(
                        'Tell us about\nyourself',
                        style: appStyle(
                          32,
                          Colors.black,
                          FontWeight.w900,
                        ).copyWith(letterSpacing: -0.5, height: 1.2),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Write a short bio that describes you',
                        style: appStyle(
                          15,
                          Colors.grey[600]!,
                          FontWeight.w400,
                        ).copyWith(letterSpacing: -0.2, height: 1.4),
                      ),
                      SizedBox(height: 40.h),

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: TextFormField(
                          controller: _bioController,
                          maxLines: 6,
                          maxLength: 500,
                          decoration: InputDecoration(
                            hintText:
                                'e.g., Love hiking, coffee, and good conversations. Looking for someone to explore the city with...',
                            hintStyle: appStyle(
                              14,
                              Colors.grey[500]!,
                              FontWeight.w400,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16.w),
                            counterStyle: appStyle(
                              12,
                              Colors.grey[600]!,
                              FontWeight.w400,
                            ),
                          ),
                          style: appStyle(15, Colors.black, FontWeight.w500),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please write something about yourself';
                            }
                            if (value.trim().length < 20) {
                              return 'Bio should be at least 20 characters';
                            }
                            return null;
                          },
                        ),
                      ),

                      SizedBox(height: 24.h),

                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: Colors.blue[700],
                              size: 24,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                'Tip: Be authentic and specific. Mention your hobbies, interests, or what makes you unique!',
                                style: appStyle(
                                  13,
                                  Colors.blue[900]!,
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
