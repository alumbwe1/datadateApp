import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_style.dart';
import '../../../../core/widgets/custom_button.dart';
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
      // Navigate back with the selected university
      context.pop(selectedUniversity);
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Select University',
          style: appStyle(20, Colors.black, FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.all(16.w),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search universities...',
                hintStyle: appStyle(14, Colors.grey[400]!, FontWeight.w400),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
            ),
          ),

          // Universities list
          Expanded(
            child: universitiesState.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.black),
                  )
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
                        Icon(
                          Icons.school_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'No universities found',
                          style: appStyle(
                            16,
                            Colors.grey[600]!,
                            FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: filteredUniversities.length,
                    itemBuilder: (context, index) {
                      final university = filteredUniversities[index];
                      final isSelected =
                          universitiesState.selectedUniversity?.id ==
                          university.id;

                      return GestureDetector(
                        onTap: () {
                          ref
                              .read(universitiesProvider.notifier)
                              .selectUniversity(university);
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: 12.h),
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.black : Colors.white,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.black
                                  : Colors.grey[300]!,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            children: [
                              // University logo
                              if (university.logo != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.r),
                                  child: CachedNetworkImage(
                                    imageUrl: university.logo!,
                                    width: 48.w,
                                    height: 48.h,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      width: 48.w,
                                      height: 48.h,
                                      color: Colors.grey[200],
                                      child: Icon(
                                        Icons.school,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                          width: 48.w,
                                          height: 48.h,
                                          color: Colors.grey[200],
                                          child: Icon(
                                            Icons.school,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                  ),
                                )
                              else
                                Container(
                                  width: 48.w,
                                  height: 48.h,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white.withOpacity(0.2)
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Icon(
                                    Icons.school,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey[400],
                                  ),
                                ),

                              SizedBox(width: 16.w),

                              // University name
                              Expanded(
                                child: Text(
                                  university.name,
                                  style: appStyle(
                                    16,
                                    isSelected ? Colors.white : Colors.black,
                                    FontWeight.w600,
                                  ),
                                ),
                              ),

                              // Checkmark
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                  size: 24.sp,
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
              padding: EdgeInsets.all(16.w),
              child: CustomButton(text: 'Continue', onPressed: _handleContinue),
            ),
        ],
      ),
    );
  }
}
