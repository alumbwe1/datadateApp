import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_style.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class AccountDeletionConfirmationSheet extends ConsumerStatefulWidget {
  final String selectedReason;
  final String? otherReasonText;

  const AccountDeletionConfirmationSheet({
    super.key,
    required this.selectedReason,
    this.otherReasonText,
  });

  @override
  ConsumerState<AccountDeletionConfirmationSheet> createState() =>
      _AccountDeletionConfirmationSheetState();
}

class _AccountDeletionConfirmationSheetState
    extends ConsumerState<AccountDeletionConfirmationSheet> {
  String? selectedOption;
  bool isDeleting = false;

  final List<Map<String, String>> options = [
    {
      'title': 'Only get shown to people you like',
      'description': 'Reduce unwanted matches',
    },
    {
      'title': 'Hide your account, so you won\'t be shown',
      'description': 'Take a break without losing data',
    },
    {
      'title': 'Clear all activity',
      'description': 'Start fresh with a clean slate',
    },
    {
      'title': 'Turn off notifications',
      'description': 'Stay connected without interruptions',
    },
    {
      'title': 'Just log out instead',
      'description': 'Keep your account but sign out',
    },
    {
      'title': 'Delete your account',
      'description': 'Permanently remove all data',
    },
  ];

  @override
  void initState() {
    super.initState();
    AnalyticsService.trackFeatureUsage(
      featureName: 'account_deletion_confirmation_viewed',
      parameters: {'reason': widget.selectedReason},
    );
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
            SizedBox(height: 5.h,),
            //Drag Handle
                          Container(
                margin: EdgeInsets.only(top: 8.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            
            // Header
            Padding(
              padding: EdgeInsets.all(10.w),
              child: Row(
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
            ),

            // Title and Description
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Are you sure you want to\ndelete your account?',
                    style: appStyle(
                      24.sp,
                      textColor,
                      FontWeight.w800,
                    ).copyWith(letterSpacing: -0.3, height: 1.2),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'If you\'d just like to hide for a while or start over,\nyou can:',
                    style: appStyle(
                      14.sp,
                      isDarkMode ? Colors.grey[400]! : Colors.grey[600]!,
                      FontWeight.w400,
                    ).copyWith(height: 1.4),
                  ),
                ],
              ),
            ),

            SizedBox(height: 30.h),

            // Options List
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options[index];
                  final isSelected = selectedOption == option['title'];
                  final isDelete = option['title'] == 'Delete your account';

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        selectedOption = option['title'];
                      });

                      AnalyticsService.trackFeatureUsage(
                        featureName: 'deletion_option_selected',
                        parameters: {
                          'option': option['title']!,
                          'is_delete': isDelete,
                        },
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(16.w),
                      margin: EdgeInsets.only(bottom: 12.h),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDarkMode ? Colors.grey[700] : Colors.grey[100])
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: isSelected
                              ? (isDarkMode
                                    ? Colors.grey[600]!
                                    : Colors.grey[300]!)
                              : (isDarkMode
                                    ? Colors.grey[800]!
                                    : Colors.grey[200]!),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 20.w,
                            height: 20.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? (isDelete ? Colors.red : Colors.blue)
                                    : (isDarkMode
                                          ? Colors.grey[600]!
                                          : Colors.grey[400]!),
                                width: 2,
                              ),
                              color: isSelected
                                  ? (isDelete ? Colors.red : Colors.blue)
                                  : Colors.transparent,
                            ),
                            child: isSelected
                                ? Icon(
                                    Icons.check,
                                    size: 12.w,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  option['title']!,
                                  style: appStyle(
                                    15.sp,
                                    isDelete ? Colors.red : textColor,
                                    FontWeight.w600,
                                  ),
                                ),
                                if (option['description']!.isNotEmpty) ...[
                                  SizedBox(height: 4.h),
                                  Text(
                                    option['description']!,
                                    style: appStyle(
                                      13.sp,
                                      isDarkMode
                                          ? Colors.grey[400]!
                                          : Colors.grey[600]!,
                                      FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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
                  onPressed: selectedOption != null && !isDeleting
                      ? _handleContinue
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedOption == 'Delete your account'
                        ? Colors.red
                        : Colors.black,
                    disabledBackgroundColor: Colors.grey[400],
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                  ),
                  child: isDeleting
                      ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
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

  Future<void> _handleContinue() async {
    if (selectedOption == null || isDeleting) {
      return;
    }

    setState(() {
      isDeleting = true;
    });

    HapticFeedback.mediumImpact();

    try {
      if (selectedOption == 'Delete your account') {
        // Track deletion attempt
        AnalyticsService.trackFeatureUsage(
          featureName: 'account_deletion_attempted',
          parameters: {
            'reason': widget.selectedReason,
            'other_text': widget.otherReasonText,
          },
        );

        // Call delete account API
        await ref
            .read(profileProvider.notifier)
            .deleteAccount(
              reason: widget.selectedReason,
              otherReason: widget.otherReasonText,
            );

        if (mounted) {
          // Logout user after successful deletion
          await ref.read(authProvider.notifier).logout();

          // Close all bottom sheets and navigate to login
          if(mounted){
            Navigator.of(context).popUntil((route) => route.isFirst);
            CustomSnackbar.show(context,
             type: SnackbarType.success,
             message: 'Account deleted successfully');
          }
              
          
        
        }
      } else {
        // Handle other options (hide account, clear activity, etc.)
        await _handleAlternativeOption(selectedOption!);

        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);

          CustomSnackbar.show(
            context,
            type: SnackbarType.success,
            message: _getSuccessMessage(selectedOption!),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.show(
          context,
          type: SnackbarType.error,
          message: 'Something went wrong. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isDeleting = false;
        });
      }
    }
  }

  Future<void> _handleAlternativeOption(String option) async {
    // Track alternative option selection
    AnalyticsService.trackFeatureUsage(
      featureName: 'deletion_alternative_selected',
      parameters: {'option': option, 'original_reason': widget.selectedReason},
    );

    switch (option) {
      case 'Hide your account, so you won\'t be shown':
        // Implement hide account logic
        break;
      case 'Clear all activity':
        // Implement clear activity logic
        break;
      case 'Turn off notifications':
        // Implement turn off notifications logic
        break;
      case 'Just log out instead':
        // Implement logout logic
        break;
      default:
        // Handle other options
        break;
    }
  }

  String _getSuccessMessage(String option) {
    switch (option) {
      case 'Hide your account, so you won\'t be shown':
        return 'Account hidden successfully';
      case 'Clear all activity':
        return 'Activity cleared successfully';
      case 'Turn off notifications':
        return 'Notifications turned off';
      case 'Just log out instead':
        return 'Logged out successfully';
      default:
        return 'Settings updated successfully';
    }
  }
}
