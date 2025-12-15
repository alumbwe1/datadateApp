import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_style.dart';

class EnhancedFilterBottomSheet extends StatefulWidget {
  final Map<String, dynamic> initialFilters;
  final Function(Map<String, dynamic>) onApply;
  final VoidCallback onClear;

  const EnhancedFilterBottomSheet({
    super.key,
    required this.initialFilters,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<EnhancedFilterBottomSheet> createState() =>
      _EnhancedFilterBottomSheetState();
}

class _EnhancedFilterBottomSheetState extends State<EnhancedFilterBottomSheet>
    with SingleTickerProviderStateMixin {
  late double _minAge;
  late double _maxAge;
  String? _selectedGender;
  String? _selectedIntent;
  String? _selectedOccupationType;
  bool _onlineOnly = false;
  bool _hasPhotos = false;
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _compoundController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _minAge = (widget.initialFilters['minAge'] ?? 18).toDouble();
    _maxAge = (widget.initialFilters['maxAge'] ?? 35).toDouble();
    _selectedGender = widget.initialFilters['gender'];
    _selectedIntent = widget.initialFilters['intent'];
    _selectedOccupationType = widget.initialFilters['occupationType'];
    _onlineOnly = widget.initialFilters['onlineOnly'] ?? false;
    _hasPhotos = widget.initialFilters['hasPhotos'] ?? false;

    if (widget.initialFilters['city'] != null) {
      _cityController.text = widget.initialFilters['city'];
    }
    if (widget.initialFilters['compound'] != null) {
      _compoundController.text = widget.initialFilters['compound'];
    }
    if (widget.initialFilters['course'] != null) {
      _courseController.text = widget.initialFilters['course'];
    }

    _animController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _cityController.dispose();
    _compoundController.dispose();
    _courseController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
          .animate(
            CurvedAnimation(parent: _animController, curve: Curves.easeOut),
          ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 16.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAgeRangeSection(),
                      SizedBox(height: 24.h),
                      _buildGenderSection(),
                      SizedBox(height: 24.h),
                      _buildIntentSection(),
                      SizedBox(height: 24.h),
                      _buildOccupationSection(),
                      SizedBox(height: 24.h),
                      _buildLocationSection(),
                      SizedBox(height: 24.h),
                      _buildCourseSection(),
                      SizedBox(height: 24.h),
                      _buildToggleSection(),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryLight.withValues(alpha: 0.1),
                  AppColors.primaryLight.withValues(alpha: 0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.tune_rounded,
              color: AppColors.primaryLight,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            'Advanced Filters',
            style: appStyle(20, Colors.black, FontWeight.w700),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(Icons.close, size: 24.sp),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Age Range', style: appStyle(16, Colors.black, FontWeight.w600)),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_minAge.round()} years',
              style: appStyle(14, AppColors.primaryLight, FontWeight.w600),
            ),
            Text(
              '${_maxAge.round()} years',
              style: appStyle(14, AppColors.primaryLight, FontWeight.w600),
            ),
          ],
        ),
        RangeSlider(
          values: RangeValues(_minAge, _maxAge),
          min: 18,
          max: 60,
          divisions: 42,
          activeColor: AppColors.primaryLight,
          inactiveColor: AppColors.primaryLight.withValues(alpha: 0.2),
          onChanged: (values) {
            setState(() {
              _minAge = values.start;
              _maxAge = values.end;
            });
            HapticFeedback.selectionClick();
          },
        ),
      ],
    );
  }

  Widget _buildGenderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gender', style: appStyle(16, Colors.black, FontWeight.w600)),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          children: [
            _buildChip('All', _selectedGender == null, () {
              setState(() => _selectedGender = null);
            }),
            _buildChip('Male', _selectedGender == 'male', () {
              setState(() => _selectedGender = 'male');
            }),
            _buildChip('Female', _selectedGender == 'female', () {
              setState(() => _selectedGender = 'female');
            }),
            _buildChip('Other', _selectedGender == 'other', () {
              setState(() => _selectedGender = 'other');
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildIntentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Looking For', style: appStyle(16, Colors.black, FontWeight.w600)),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          children: [
            _buildChip('All', _selectedIntent == null, () {
              setState(() => _selectedIntent = null);
            }),
            _buildChip('Dating', _selectedIntent == 'dating', () {
              setState(() => _selectedIntent = 'dating');
            }),
            _buildChip('Relationship', _selectedIntent == 'relationship', () {
              setState(() => _selectedIntent = 'relationship');
            }),
            _buildChip('Friends', _selectedIntent == 'friends', () {
              setState(() => _selectedIntent = 'friends');
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildOccupationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Occupation', style: appStyle(16, Colors.black, FontWeight.w600)),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          children: [
            _buildChip('All', _selectedOccupationType == null, () {
              setState(() => _selectedOccupationType = null);
            }),
            _buildChip('Student', _selectedOccupationType == 'student', () {
              setState(() => _selectedOccupationType = 'student');
            }),
            _buildChip('Working', _selectedOccupationType == 'working', () {
              setState(() => _selectedOccupationType = 'working');
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Location', style: appStyle(16, Colors.black, FontWeight.w600)),
        SizedBox(height: 12.h),
        TextField(
          controller: _cityController,
          decoration: InputDecoration(
            hintText: 'City (e.g., Lusaka)',
            prefixIcon: const Icon(
              Icons.location_city,
              color: AppColors.primaryLight,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(
                color: AppColors.primaryLight,
                width: 2,
              ),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        TextField(
          controller: _compoundController,
          decoration: InputDecoration(
            hintText: 'Compound (e.g., Meanwood)',
            prefixIcon: const Icon(Icons.home, color: AppColors.primaryLight),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(
                color: AppColors.primaryLight,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCourseSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Course/Field',
          style: appStyle(16, Colors.black, FontWeight.w600),
        ),
        SizedBox(height: 12.h),
        TextField(
          controller: _courseController,
          decoration: InputDecoration(
            hintText: 'e.g., Computer Science',
            prefixIcon: const Icon(Icons.school, color: AppColors.primaryLight),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(
                color: AppColors.primaryLight,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleSection() {
    return Column(
      children: [
        _buildToggleTile(
          'Online Only',
          'Show only users who are currently online',
          Icons.circle,
          Colors.green,
          _onlineOnly,
          (value) => setState(() => _onlineOnly = value),
        ),
        SizedBox(height: 12.h),
        _buildToggleTile(
          'Has Photos',
          'Show only profiles with photos',
          Icons.photo_camera,
          AppColors.primaryLight,
          _hasPhotos,
          (value) => setState(() => _hasPhotos = value),
        ),
      ],
    );
  }

  Widget _buildToggleTile(
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: (val) {
          HapticFeedback.lightImpact();
          onChanged(val);
        },
        title: Row(
          children: [
            Icon(icon, color: iconColor, size: 20.sp),
            SizedBox(width: 8.w),
            Text(title, style: appStyle(15, Colors.black, FontWeight.w600)),
          ],
        ),
        subtitle: Text(
          subtitle,
          style: appStyle(13, Colors.grey[600]!, FontWeight.w400),
        ),
        activeThumbColor: AppColors.primaryLight,
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppColors.primaryLight,
                    AppColors.primaryLight.withValues(alpha: 0.8),
                  ],
                )
              : null,
          color: isSelected ? null : Colors.grey[100],
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? AppColors.primaryLight : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: appStyle(
            14,
            isSelected ? Colors.white : Colors.black87,
            FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                widget.onClear();
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                side: BorderSide(color: Colors.grey[400]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Clear All',
                style: appStyle(16, Colors.black87, FontWeight.w600),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                final filters = {
                  'minAge': _minAge.round(),
                  'maxAge': _maxAge.round(),
                  'gender': _selectedGender,
                  'intent': _selectedIntent,
                  'occupationType': _selectedOccupationType,
                  'city': _cityController.text.trim().isEmpty
                      ? null
                      : _cityController.text.trim(),
                  'compound': _compoundController.text.trim().isEmpty
                      ? null
                      : _compoundController.text.trim(),
                  'course': _courseController.text.trim().isEmpty
                      ? null
                      : _courseController.text.trim(),
                  'onlineOnly': _onlineOnly,
                  'hasPhotos': _hasPhotos,
                };
                widget.onApply(filters);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'Apply Filters',
                style: appStyle(16, Colors.white, FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
