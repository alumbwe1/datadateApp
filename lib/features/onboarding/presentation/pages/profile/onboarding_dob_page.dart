import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_style.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../providers/onboarding_provider.dart';

class OnboardingDobPage extends ConsumerStatefulWidget {
  const OnboardingDobPage({super.key});

  @override
  ConsumerState<OnboardingDobPage> createState() => _OnboardingDobPageState();
}

class _OnboardingDobPageState extends ConsumerState<OnboardingDobPage> {
  DateTime? _selectedDate;
  String? _errorMessage;

  int _selectedDay = 1;
  int _selectedMonth = 1;
  int _selectedYear = DateTime.now().year - 18;

  final FixedExtentScrollController _dayController =
      FixedExtentScrollController();
  final FixedExtentScrollController _monthController =
      FixedExtentScrollController();
  final FixedExtentScrollController _yearController =
      FixedExtentScrollController();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    // Set to 18 years and 1 day ago to ensure user is definitely 18+
    final eighteenYearsAgo = DateTime(now.year - 18, now.month, now.day);
    _selectedYear = eighteenYearsAgo.year;
    _selectedMonth = eighteenYearsAgo.month;
    _selectedDay = eighteenYearsAgo.day;
  }

  @override
  void dispose() {
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _showCustomDatePicker() {
    HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _CustomDatePickerBottomSheet(
        initialDay: _selectedDay,
        initialMonth: _selectedMonth,
        initialYear: _selectedYear,
        onDateSelected: (day, month, year) {
          final selectedDate = DateTime(year, month, day);
          final age = _calculateAge(selectedDate);

          if (age < 18) {
            setState(() {
              _errorMessage =
                  'You must be at least 18 years old to use this platform.';
              _selectedDate = null;
            });
          } else {
            setState(() {
              _selectedDay = day;
              _selectedMonth = month;
              _selectedYear = year;
              _selectedDate = selectedDate;
              _errorMessage = null;
            });
            ref.read(onboardingProvider.notifier).setDateOfBirth(selectedDate);
          }
        },
      ),
    );
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final dateOfBirth = ref.watch(
      onboardingProvider.select((state) => state.dateOfBirth),
    );

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
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              Text(
                'When\'s your\nbirthday?',
                style: appStyle(
                  32,
                  Colors.black,
                  FontWeight.w900,
                ).copyWith(letterSpacing: -0.5, height: 1.2),
              ),
              SizedBox(height: 12.h),
              Text(
                'You must be 18 or older to use this app.\nYour age will be visible on your profile.',
                style: appStyle(
                  15,
                  Colors.grey[600]!,
                  FontWeight.w400,
                ).copyWith(letterSpacing: -0.2, height: 1.4),
              ),
              SizedBox(height: 60.h),
              GestureDetector(
                onTap: _showCustomDatePicker,
                child: Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _selectedDate != null
                          ? Colors.black
                          : Colors.grey.shade300,
                      width: _selectedDate != null ? 2 : 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: _selectedDate != null
                              ? Colors.black
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.cake_outlined,
                          size: 32,
                          color: _selectedDate != null
                              ? Colors.white
                              : Colors.grey[400],
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedDate != null
                                  ? _formatDate(_selectedDate!)
                                  : 'Select your birthday',
                              style: appStyle(
                                16,
                                _selectedDate != null
                                    ? Colors.black
                                    : Colors.grey[600]!,
                                FontWeight.w700,
                              ).copyWith(letterSpacing: -0.3),
                            ),
                            if (_selectedDate != null) ...[
                              SizedBox(height: 4.h),
                              Text(
                                'Age: ${_calculateAge(_selectedDate!)}',
                                style: appStyle(
                                  14,
                                  Colors.grey[600]!,
                                  FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 20,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ),
              ),
              if (_errorMessage != null) ...[
                SizedBox(height: 24.h),
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red.shade700,
                        size: 20,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: appStyle(
                            13,
                            Colors.red.shade700,
                            FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey[700], size: 20),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'Your birthday will be used to calculate your age, which will be shown on your profile.',
                        style: appStyle(13, Colors.grey[700]!, FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              CustomButton(
                text: 'Continue',
                onPressed:
                    dateOfBirth != null && _calculateAge(dateOfBirth!) >= 18
                    ? () {
                        HapticFeedback.mediumImpact();
                        // Double-check age before navigation
                        final age = _calculateAge(dateOfBirth!);
                        if (age >= 18) {
                          print(
                            '✅ Age validated: $age years old (DOB: ${dateOfBirth!.year}-${dateOfBirth!.month.toString().padLeft(2, '0')}-${dateOfBirth!.day.toString().padLeft(2, '0')})',
                          );
                          context.push('/onboarding/profile/bio');
                        } else {
                          print('❌ Age validation failed: $age years old');
                          setState(() {
                            _errorMessage =
                                'You must be at least 18 years old to use this platform.';
                            _selectedDate = null;
                          });
                        }
                      }
                    : null,
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomDatePickerBottomSheet extends StatefulWidget {
  final int initialDay;
  final int initialMonth;
  final int initialYear;
  final Function(int day, int month, int year) onDateSelected;

  const _CustomDatePickerBottomSheet({
    required this.initialDay,
    required this.initialMonth,
    required this.initialYear,
    required this.onDateSelected,
  });

  @override
  State<_CustomDatePickerBottomSheet> createState() =>
      _CustomDatePickerBottomSheetState();
}

class _CustomDatePickerBottomSheetState
    extends State<_CustomDatePickerBottomSheet> {
  late int _selectedDay;
  late int _selectedMonth;
  late int _selectedYear;

  late FixedExtentScrollController _dayController;
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _yearController;

  final List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.initialDay;
    _selectedMonth = widget.initialMonth;
    _selectedYear = widget.initialYear;

    final now = DateTime.now();
    final minYear = now.year - 100;
    final maxYear = now.year - 18;

    _dayController = FixedExtentScrollController(initialItem: _selectedDay - 1);
    _monthController = FixedExtentScrollController(
      initialItem: _selectedMonth - 1,
    );
    _yearController = FixedExtentScrollController(
      initialItem: maxYear - _selectedYear,
    );
  }

  @override
  void dispose() {
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  int _getDaysInMonth(int month, int year) {
    return DateTime(year, month + 1, 0).day;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final minYear = now.year - 100;
    final maxYear = now.year - 18;
    final daysInMonth = _getDaysInMonth(_selectedMonth, _selectedYear);

    return Container(
      height: 420.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Birthday',
                  style: appStyle(20, Colors.black, FontWeight.w700),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          // Date picker wheels
          Expanded(
            child: Row(
              children: [
                // Day
                Expanded(
                  child: _buildWheel(
                    controller: _dayController,
                    itemCount: daysInMonth,
                    itemBuilder: (index) => (index + 1).toString(),
                    onSelectedItemChanged: (index) {
                      setState(() => _selectedDay = index + 1);
                      HapticFeedback.selectionClick();
                    },
                  ),
                ),

                // Month
                Expanded(
                  flex: 2,
                  child: _buildWheel(
                    controller: _monthController,
                    itemCount: 12,
                    itemBuilder: (index) => _monthNames[index],
                    onSelectedItemChanged: (index) {
                      setState(() {
                        _selectedMonth = index + 1;
                        final newDaysInMonth = _getDaysInMonth(
                          _selectedMonth,
                          _selectedYear,
                        );
                        if (_selectedDay > newDaysInMonth) {
                          _selectedDay = newDaysInMonth;
                        }
                      });
                      HapticFeedback.selectionClick();
                    },
                  ),
                ),

                // Year
                Expanded(
                  child: _buildWheel(
                    controller: _yearController,
                    itemCount: maxYear - minYear + 1,
                    itemBuilder: (index) => (maxYear - index).toString(),
                    onSelectedItemChanged: (index) {
                      setState(() {
                        _selectedYear = maxYear - index;
                        final newDaysInMonth = _getDaysInMonth(
                          _selectedMonth,
                          _selectedYear,
                        );
                        if (_selectedDay > newDaysInMonth) {
                          _selectedDay = newDaysInMonth;
                        }
                      });
                      HapticFeedback.selectionClick();
                    },
                  ),
                ),
              ],
            ),
          ),

          // Confirm button
          Padding(
            padding: EdgeInsets.all(20.w),
            child: CustomButton(
              text: 'Confirm',
              onPressed: () {
                HapticFeedback.mediumImpact();
                widget.onDateSelected(
                  _selectedDay,
                  _selectedMonth,
                  _selectedYear,
                );
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWheel({
    required FixedExtentScrollController controller,
    required int itemCount,
    required String Function(int) itemBuilder,
    required ValueChanged<int> onSelectedItemChanged,
  }) {
    return Stack(
      children: [
        // Selection highlight
        Center(
          child: Container(
            height: 50.h,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        // Wheel
        ListWheelScrollView.useDelegate(
          controller: controller,
          itemExtent: 50.h,
          perspective: 0.005,
          diameterRatio: 1.5,
          physics: const FixedExtentScrollPhysics(),
          onSelectedItemChanged: onSelectedItemChanged,
          childDelegate: ListWheelChildBuilderDelegate(
            childCount: itemCount,
            builder: (context, index) {
              return Center(
                child: Text(
                  itemBuilder(index),
                  style: appStyle(16, Colors.black, FontWeight.w600),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
