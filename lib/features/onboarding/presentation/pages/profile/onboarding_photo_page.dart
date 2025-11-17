import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/constants/app_style.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../providers/onboarding_provider.dart';

class OnboardingPhotoPage extends ConsumerStatefulWidget {
  const OnboardingPhotoPage({super.key});

  @override
  ConsumerState<OnboardingPhotoPage> createState() =>
      _OnboardingPhotoPageState();
}

class _OnboardingPhotoPageState extends ConsumerState<OnboardingPhotoPage> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        ref.read(onboardingProvider.notifier).setProfilePhoto(_selectedImage!);
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
    final profilePhoto = ref.watch(
      onboardingProvider.select((state) => state.profilePhoto),
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
                'Add your\nprofile photo',
                style: appStyle(
                  32,
                  Colors.black,
                  FontWeight.w900,
                ).copyWith(letterSpacing: -0.5, height: 1.2),
              ),
              SizedBox(height: 12.h),
              Text(
                'Choose a clear photo of yourself.\nThis helps others recognize you.',
                style: appStyle(
                  15,
                  Colors.grey[600]!,
                  FontWeight.w400,
                ).copyWith(letterSpacing: -0.2, height: 1.4),
              ),
              SizedBox(height: 60.h),
              Center(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _showImageSourceDialog();
                  },
                  child: Container(
                    width: 200.w,
                    height: 200.w,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedImage != null
                            ? Colors.blue
                            : Colors.grey.shade300,
                        width: 3,
                      ),
                      boxShadow: _selectedImage != null
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ]
                          : [],
                    ),
                    child: _selectedImage != null
                        ? ClipOval(
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(
                            Icons.add_a_photo,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                  ),
                ),
              ),
              SizedBox(height: 30.h),
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _showImageSourceDialog();
                  },
                  icon: Icon(Icons.camera_alt, color: Colors.black),
                  label: Text(
                    _selectedImage != null ? 'Change Photo' : 'Add Photo',
                    style: appStyle(16, Colors.black, FontWeight.w600),
                  ),
                ),
              ),
              const Spacer(),
              if (_selectedImage != null)
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'Your photo will be uploaded after completing onboarding',
                          style: appStyle(
                            13,
                            Colors.blue.shade700,
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
                onPressed: profilePhoto != null
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
}
