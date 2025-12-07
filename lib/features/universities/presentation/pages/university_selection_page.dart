import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/app_style.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/onboarding_progress.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../providers/university_provider.dart';

class UniversitySelectionPage extends ConsumerStatefulWidget {
  const UniversitySelectionPage({super.key});

  @override
  ConsumerState<UniversitySelectionPage> createState() =>
      _UniversitySelectionPageState();
}

class _UniversitySelectionPageState
    extends ConsumerState<UniversitySelectionPage> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Load universities when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(universitiesProvider.notifier).loadUniversities();
    });
  }

  void _handleContinue() {
    final selectedUniversity = ref
        .read(universitiesProvider)
        .selectedUniversity;
    if (selectedUniversity != null) {
      HapticFeedback.mediumImpact();
      // Save university ID to onboarding provider
      ref
          .read(onboardingProvider.notifier)
          .setUniversity(selectedUniversity.id);
      // Navigate to gender selection (step 2)
      context.push('/onboarding/gender');
    }
  }

  @override
  Widget build(BuildContext context) {
    final universitiesState = ref.watch(universitiesProvider);
    final filteredUniversities = universitiesState.universities
        .where(
          (uni) => uni.name.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress indicator
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            child: const OnboardingProgress(currentStep: 1, totalSteps: 10),
          ),
          // Title and subtitle
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8.h),
                Text(
                  'Select \nUniversity',
                  style: appStyle(
                    28,
                    Colors.black,
                    FontWeight.w900,
                  ).copyWith(letterSpacing: -0.3, height: 1.2),
                ),
                SizedBox(height: 12.h),
                Text(
                  'Choose your university to connect\nwith students on your campus.',
                  style: appStyle(
                    15,
                    Colors.grey[600]!,
                    FontWeight.w400,
                  ).copyWith(letterSpacing: -0.2, height: 1.4),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // Universities list
          Expanded(
            child: universitiesState.isLoading
                ? _buildShimmerLoading()
                : universitiesState.error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          universitiesState.error!,
                          style: appStyle(
                            14,
                            Colors.grey[600]!,
                            FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16.h),
                        TextButton(
                          onPressed: () {
                            ref
                                .read(universitiesProvider.notifier)
                                .loadUniversities();
                          },
                          child: Text(
                            'Retry',
                            style: appStyle(14, Colors.black, FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  )
                : filteredUniversities.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.school_outlined,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                        ),
                        SizedBox(height: 24.h),
                        Text(
                          'No universities found',
                          style: appStyle(
                            18,
                            Colors.black,
                            FontWeight.w700,
                          ).copyWith(letterSpacing: -0.3),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Try adjusting your search',
                          style: appStyle(
                            14,
                            Colors.grey[600]!,
                            FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    itemCount: filteredUniversities.length,
                    itemBuilder: (context, index) {
                      final university = filteredUniversities[index];
                      final isSelected =
                          universitiesState.selectedUniversity?.id ==
                          university.id;

                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          ref
                              .read(universitiesProvider.notifier)
                              .selectUniversity(university);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: EdgeInsets.only(bottom: 16.h),
                          padding: EdgeInsets.all(20.w),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.black : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.black
                                  : Colors.grey.shade300,
                              width: isSelected ? 2 : 1.5,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Row(
                            children: [
                              // University logo
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: university.logo != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: CachedNetworkImage(
                                          imageUrl: university.logo!,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Center(
                                            child: Icon(
                                              Icons.school,
                                              color: Colors.grey[400],
                                              size: 28,
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Center(
                                                child: Icon(
                                                  Icons.school,
                                                  color: Colors.grey[400],
                                                  size: 28,
                                                ),
                                              ),
                                        ),
                                      )
                                    : Center(
                                        child: Icon(
                                          Icons.school,
                                          color: isSelected
                                              ? Colors.black
                                              : Colors.grey[400],
                                          size: 28,
                                        ),
                                      ),
                              ),

                              SizedBox(width: 16.w),

                              // University name
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      university.name,
                                      style: appStyle(
                                        18,
                                        isSelected
                                            ? Colors.white
                                            : Colors.black,
                                        FontWeight.w700,
                                      ).copyWith(letterSpacing: -0.3),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      'Campus Community',
                                      style: appStyle(
                                        14,
                                        isSelected
                                            ? Colors.white70
                                            : Colors.grey[600]!,
                                        FontWeight.w400,
                                      ).copyWith(letterSpacing: -0.2),
                                    ),
                                  ],
                                ),
                              ),

                              // Checkmark
                              if (isSelected)
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.black,
                                    size: 20,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Continue button
          if (universitiesState.selectedUniversity != null)
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 20.h),
              child: CustomButton(text: 'Continue', onTap: _handleContinue),
            ),
          SizedBox(
            height: MediaQuery.of(context).padding.bottom,
          ), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: EdgeInsets.only(bottom: 16.h),
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade300, width: 1.5),
            ),
            child: Row(
              children: [
                // Logo placeholder
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                SizedBox(width: 16.w),
                // Text placeholders
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 18,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        width: 120,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
