import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_style.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../providers/onboarding_provider.dart';

class OnboardingGraduationPage extends ConsumerStatefulWidget {
  const OnboardingGraduationPage({super.key});

  @override
  ConsumerState<OnboardingGraduationPage> createState() =>
      _OnboardingGraduationPageState();
}

class _OnboardingGraduationPageState
    extends ConsumerState<OnboardingGraduationPage> {
  int? _selectedYear;

  @override
  void initState() {
    super.initState();
    // Get current year and generate list
    final currentYear = DateTime.now().year;
    _years = List.generate(10, (index) => currentYear + index);
  }

  late List<int> _years;

  void _handleContinue() {
    if (_selectedYear != null) {
      ref.read(onboardingProvider.notifier).setGraduationYear(_selectedYear!);
      HapticFeedback.mediumImpact();
      context.push('/onboarding/profile/age');
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'When do you\ngraduate?',
                      style: appStyle(
                        32,
                        Colors.black,
                        FontWeight.w900,
                      ).copyWith(letterSpacing: -0.5, height: 1.2),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Select your expected graduation year',
                      style: appStyle(
                        15,
                        Colors.grey[600]!,
                        FontWeight.w400,
                      ).copyWith(letterSpacing: -0.2, height: 1.4),
                    ),
                    SizedBox(height: 40.h),

                    // Year selection grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 12.h,
                        childAspectRatio: 2.2,
                      ),
                      itemCount: _years.length,
                      itemBuilder: (context, index) {
                        final year = _years[index];
                        final isSelected = _selectedYear == year;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedYear = year;
                            });
                            HapticFeedback.selectionClick();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.black
                                  : Colors.grey[50],
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.black
                                    : Colors.grey[300]!,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                year.toString(),
                                style: appStyle(
                                  16,
                                  isSelected ? Colors.white : Colors.black,
                                  FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(24.w),
              child: CustomButton(
                text: 'Continue',
                onPressed: _selectedYear != null ? _handleContinue : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
