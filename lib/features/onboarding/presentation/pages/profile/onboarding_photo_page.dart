import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/constants/app_style.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/widgets/onboarding_progress.dart';
import '../../providers/onboarding_provider.dart';

class OnboardingPhotoPage extends ConsumerStatefulWidget {
  const OnboardingPhotoPage({super.key});

  @override
  ConsumerState<OnboardingPhotoPage> createState() =>
      _OnboardingPhotoPageState();
}

class _OnboardingPhotoPageState extends ConsumerState<OnboardingPhotoPage> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final photos = ref.read(onboardingProvider).photos;
      if (photos.length >= 4) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Maximum 4 photos allowed')),
          );
        }
        return;
      }

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        ref.read(onboardingProvider.notifier).addPhoto(File(image.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: Colors.black),
                title: Text(
                  'Take Photo',
                  style: appStyle(16, Colors.black, FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: Colors.black),
                title: Text(
                  'Choose from Gallery',
                  style: appStyle(16, Colors.black, FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final photos = ref.watch(
      onboardingProvider.select((state) => state.photos),
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
              SizedBox(height: 12.h),
              const OnboardingProgress(currentStep: 7, totalSteps: 8),
              SizedBox(height: 24.h),
              Text(
                'Add your\nphotos',
                style: appStyle(
                  32,
                  Colors.black,
                  FontWeight.w900,
                ).copyWith(letterSpacing: -0.5, height: 1.2),
              ),
              SizedBox(height: 12.h),
              Text(
                'Add 2-4 clear photos of yourself.\nFirst photo will be your profile picture.',
                style: appStyle(
                  15,
                  Colors.grey[600]!,
                  FontWeight.w400,
                ).copyWith(letterSpacing: -0.2, height: 1.4),
              ),
              SizedBox(height: 40.h),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.w,
                    mainAxisSpacing: 16.h,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: photos.length < 4 ? photos.length + 1 : 4,
                  itemBuilder: (context, index) {
                    if (index < photos.length) {
                      return _buildPhotoCard(photos[index], index);
                    } else {
                      return _buildAddPhotoCard();
                    }
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: photos.length >= 2
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      photos.length >= 2
                          ? Icons.check_circle_outline
                          : Icons.info_outline,
                      color: photos.length >= 2
                          ? Colors.green.shade700
                          : Colors.orange.shade700,
                      size: 20,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        photos.length >= 2
                            ? '${photos.length} photos added. You can add up to 4.'
                            : 'Add at least 2 photos to continue (${photos.length}/2)',
                        style: appStyle(
                          13,
                          photos.length >= 2
                              ? Colors.green.shade700
                              : Colors.orange.shade700,
                          FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              CustomButton(
                text: 'Continue',
                onPressed: photos.length >= 2
                    ? () {
                        HapticFeedback.mediumImpact();
                        context.push('/onboarding/profile/dob');
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

  Widget _buildPhotoCard(File photo, int index) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: index == 0 ? Colors.black : Colors.grey.shade300,
              width: index == 0 ? 2 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              photo,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
        if (index == 0)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Profile',
                style: appStyle(10, Colors.white, FontWeight.w700),
              ),
            ),
          ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              ref.read(onboardingProvider.notifier).removePhoto(index);
            },
            child: Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddPhotoCard() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showImageSourceDialog();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey[400]),
            SizedBox(height: 8.h),
            Text(
              'Add Photo',
              style: appStyle(14, Colors.grey[600]!, FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
