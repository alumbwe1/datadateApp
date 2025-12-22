import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/constants/app_style.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/services/analytics_service.dart';
import 'account_deletion_confirmation_sheet.dart';

class AccountDeletionFeedbackSheet extends ConsumerStatefulWidget {
  const AccountDeletionFeedbackSheet({super.key});

  @override
  ConsumerState<AccountDeletionFeedbackSheet> createState() =>
      _AccountDeletionFeedbackSheetState();
}

class _AccountDeletionFeedbackSheetState
    extends ConsumerState<AccountDeletionFeedbackSheet> {
  String? selectedReason;
  final TextEditingController _otherReasonController = TextEditingController();

  final List<String> deletionReasons = [
    'I don\'t want to pay',
    'I don\'t feel safe',
    'I\'m with someone',
    'HeartLink isn\'t what I expected',
    'I feel overwhelmed',
    'I\'m not meeting anyone',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    // Track feedback sheet view
    AnalyticsService.trackFeatureUsage(
      featureName: 'account_deletion_feedback_viewed',
    );
  }

  @override
  void dispose() {
    _otherReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;
    final bgColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                children: [

                  ///Drag handle
                         Container(
                margin: EdgeInsets.only(top: 8.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                    
                         
                 
             const Spacer(),
              GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[800] : Colors.white,
                        borderRadius: BorderRadius.circular(22.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(Icons.close, size: 20.w, color: textColor),
                    ),
                  ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  // Illustration
                 Lottie.asset(
        'assets/lottie/sorry.json',
        width: 100.w,
        height: 100.h,
        fit: BoxFit.contain,
      ),
                  SizedBox(height: 30.h),
                  Text(
                    "We're sorry you're leaving!\nTell us why.",
                    textAlign: TextAlign.center,
                    style: appStyle(
                      24.sp,
                      textColor,
                      FontWeight.w800,
                    ).copyWith(letterSpacing: -0.5, height: 1.2),
                  ),
                ],
              ),
            ),

            // Reasons List
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                itemCount: deletionReasons.length,
                itemBuilder: (context, index) {
                  final reason = deletionReasons[index];
                  final isSelected = selectedReason == reason;
                  final isOther = reason == 'Other';

                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            selectedReason = reason;
                          });

                          // Track reason selection
                          AnalyticsService.trackFeatureUsage(
                            featureName: 'deletion_reason_selected',
                            parameters: {'reason': reason, 'is_other': isOther},
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 16.h,
                          ),
                          margin: EdgeInsets.only(bottom: 12.h),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDarkMode
                                      ? Colors.grey[700]
                                      : Colors.grey[100])
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: isSelected
                                  ? (isDarkMode
                                        ? Colors.grey[600]!
                                        : Colors.grey[300]!)
                                  : Colors.transparent,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  reason,
                                  style: appStyle(
                                    16.sp,
                                    textColor,
                                    FontWeight.w500,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                                size: 20.w,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Other reason text field
                      if (isOther && isSelected) ...[
                        Container(
                          margin: EdgeInsets.only(bottom: 12.h),
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? Colors.grey[800]
                                : Colors.grey[50],
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: isDarkMode
                                  ? Colors.grey[600]!
                                  : Colors.grey[200]!,
                            ),
                          ),
                          child: TextField(
                            controller: _otherReasonController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText:
                                  'Please tell us more about your reason...',
                              hintStyle: appStyle(
                                14.sp,
                                isDarkMode
                                    ? Colors.grey[400]!
                                    : Colors.grey[600]!,
                                FontWeight.w400,
                              ),
                              border: InputBorder.none,
                            ),
                            style: appStyle(14.sp, textColor, FontWeight.w400),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),

            // Continue Button
            Padding(
              padding: EdgeInsets.all(20.w),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedReason != null ? _handleContinue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    disabledBackgroundColor: Colors.grey[400],
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: appStyle(16.sp, Colors.white, FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleContinue() {
    if (selectedReason == null) return;

    HapticFeedback.mediumImpact();

    // Track feedback submission
    AnalyticsService.trackFeatureUsage(
      featureName: 'deletion_feedback_submitted',
      parameters: {
        'selected_reason': selectedReason!,
        'has_other_text':
            selectedReason == 'Other' && _otherReasonController.text.isNotEmpty,
        'other_text_length': selectedReason == 'Other'
            ? _otherReasonController.text.length
            : 0,
      },
    );

    Navigator.pop(context);

    // Show confirmation sheet
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => AccountDeletionConfirmationSheet(
        selectedReason: selectedReason!,
        otherReasonText: selectedReason == 'Other'
            ? _otherReasonController.text
            : null,
      ),
    );
  }
}
