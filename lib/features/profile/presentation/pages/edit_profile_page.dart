import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconly/iconly.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_style.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../providers/profile_provider.dart';
import '../widgets/custom_switcher.dart';

// Available interests with emojis
const List<Map<String, String>> availableInterests = [
  {'name': 'hiking', 'emoji': '🥾'},
  {'name': 'coffee', 'emoji': '☕'},
  {'name': 'coding', 'emoji': '💻'},
  {'name': 'AI', 'emoji': '🤖'},
  {'name': 'reading', 'emoji': '📚'},
  {'name': 'music', 'emoji': '🎵'},
  {'name': 'travel', 'emoji': '✈️'},
  {'name': 'fitness', 'emoji': '💪'},
  {'name': 'photography', 'emoji': '📸'},
  {'name': 'cooking', 'emoji': '🍳'},
  {'name': 'gaming', 'emoji': '🎮'},
  {'name': 'art', 'emoji': '🎨'},
  {'name': 'movies', 'emoji': '🎬'},
  {'name': 'sports', 'emoji': '⚽'},
  {'name': 'yoga', 'emoji': '🧘'},
  {'name': 'dancing', 'emoji': '💃'},
  {'name': 'nature', 'emoji': '🌿'},
  {'name': 'pets', 'emoji': '🐾'},
  {'name': 'fashion', 'emoji': '👗'},
  {'name': 'food', 'emoji': '🍕'},
];

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _courseController;

  bool _hasChanges = false;
  List<String> _selectedInterests = [];
  String _selectedGender = 'male';
  List<String> _selectedPreferredGenders = ['female'];
  String _selectedIntent = 'dating';
  bool _isPrivate = false;
  bool _showRealNameOnMatch = true;
  bool _isUploadingPhoto = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider).profile;
    _nameController = TextEditingController(text: profile?.realName ?? '');
    _bioController = TextEditingController(text: profile?.bio ?? '');
    _courseController = TextEditingController(text: profile?.course ?? '');

    // Initialize from profile
    _selectedInterests = List.from(profile?.interests ?? []);
    _selectedGender = profile?.gender ?? 'male';
    _selectedPreferredGenders = List.from(
      profile?.preferredGenders ?? ['female'],
    );
    _selectedIntent = profile?.intent ?? 'dating';
    _isPrivate = profile?.isPrivate ?? false;
    _showRealNameOnMatch = profile?.showRealNameOnMatch ?? true;

    _nameController.addListener(() => setState(() => _hasChanges = true));
    _bioController.addListener(() => setState(() => _hasChanges = true));
    _courseController.addListener(() => setState(() => _hasChanges = true));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _courseController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) return;

      final profile = ref.read(profileProvider).profile;
      final currentPhotos = profile?.imageUrls ?? [];

      if (currentPhotos.length >= 6) {
        if (mounted) {
          CustomSnackbar.show(
            context,
            message: 'Maximum 6 photos allowed',
            type: SnackbarType.error,
          );
        }
        return;
      }

      setState(() => _isUploadingPhoto = true);

      // Upload photo using profile provider
      final success = await ref
          .read(profileProvider.notifier)
          .uploadPhoto(image.path);

      if (mounted) {
        setState(() => _isUploadingPhoto = false);

        if (success) {
          CustomSnackbar.show(
            context,
            message: 'Photo uploaded successfully!',
            type: SnackbarType.success,
          );
        } else {
          final error = ref.read(profileProvider).error;
          CustomSnackbar.show(
            context,
            message: error ?? 'Failed to upload photo',
            type: SnackbarType.error,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingPhoto = false);
        CustomSnackbar.show(
          context,
          message: 'Failed to pick image: $e',
          type: SnackbarType.error,
        );
      }
    }
  }

  Future<void> _deletePhoto(int index) async {
    final profile = ref.read(profileProvider).profile;
    if (profile == null) return;

    final currentUrls = List<String>.from(profile.imageUrls);
    if (index >= currentUrls.length) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        contentPadding: EdgeInsets.all(24.w),
        title: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.delete_outline, color: Colors.red, size: 32.sp),
            ),
            SizedBox(height: 16.h),
            Text(
              'Delete Photo?',
              style: appStyle(20.sp, Colors.black, FontWeight.w700),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete this photo?',
          style: appStyle(14.sp, Colors.grey[700]!, FontWeight.w400),
          textAlign: TextAlign.center,
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    backgroundColor: Colors.grey[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: appStyle(15.sp, Colors.black, FontWeight.w600),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Delete',
                    style: appStyle(15.sp, Colors.white, FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
        actionsPadding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
      ),
    );

    if (confirmed != true) return;

    setState(() => _isUploadingPhoto = true);

    // Remove photo from list
    currentUrls.removeAt(index);

    final success = await ref.read(profileProvider.notifier).updateProfile({
      'imageUrls': currentUrls,
    });

    if (mounted) {
      setState(() => _isUploadingPhoto = false);

      if (success) {
        CustomSnackbar.show(
          context,
          message: 'Photo deleted successfully!',
          type: SnackbarType.success,
        );
      } else {
        final error = ref.read(profileProvider).error;
        CustomSnackbar.show(
          context,
          message: error ?? 'Failed to delete photo',
          type: SnackbarType.error,
        );
      }
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    HapticFeedback.mediumImpact();

    // Prepare update data
    final updateData = <String, dynamic>{
      'real_name': _nameController.text.trim(),
      'bio': _bioController.text.trim(),
      'course': _courseController.text.trim(),
      'interests': _selectedInterests,
      'gender': _selectedGender,
      'preferred_genders': _selectedPreferredGenders,
      'intent': _selectedIntent,
      'is_private': _isPrivate,
      'show_real_name_on_match': _showRealNameOnMatch,
    };

    final success = await ref
        .read(profileProvider.notifier)
        .updateProfile(updateData);

    if (mounted) {
      if (success) {
        CustomSnackbar.show(
          context,
          message: 'Profile updated successfully!',
          type: SnackbarType.success,
        );
        Navigator.pop(context);
      } else {
        final error = ref.read(profileProvider).error;
        CustomSnackbar.show(
          context,
          message: error ?? 'Failed to update profile',
          type: SnackbarType.error,
        );
      }
    }
  }

  void _showDiscardDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        contentPadding: EdgeInsets.all(24.w),
        title: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_rounded,
                color: Colors.red,
                size: 32.sp,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Discard Changes?',
              style: appStyle(20.sp, Colors.black, FontWeight.w700),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Text(
          'You have unsaved changes. Are you sure you want to discard them?',
          style: appStyle(14.sp, Colors.grey[700]!, FontWeight.w400),
          textAlign: TextAlign.center,
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    backgroundColor: Colors.grey[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: appStyle(15.sp, Colors.black, FontWeight.w600),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Discard',
                    style: appStyle(15.sp, Colors.white, FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
        actionsPadding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
      ),
    );
  }

  void _showInterestsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
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
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(height: 20.h),

                // Header
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Select Interests',
                            style: appStyle(
                              22.sp,
                              Colors.black,
                              FontWeight.w800,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              '${_selectedInterests.length}/10',
                              style: appStyle(
                                13.sp,
                                Colors.white,
                                FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Choose up to 10 interests that represent you',
                          style: appStyle(
                            13.sp,
                            Colors.grey[600]!,
                            FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                // Interests grid
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Wrap(
                      spacing: 5.w,
                      runSpacing: 10.h,
                      children: availableInterests.map((interest) {
                        final isSelected = _selectedInterests.contains(
                          interest['name'],
                        );
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            setModalState(() {
                              if (isSelected) {
                                _selectedInterests.remove(interest['name']);
                              } else {
                                if (_selectedInterests.length < 10) {
                                  _selectedInterests.add(interest['name']!);
                                }
                              }
                            });
                            setState(() => _hasChanges = true);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(
                              horizontal: 18.w,
                              vertical: 7.h,
                            ),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? const LinearGradient(
                                      colors: [
                                        Color(0xFF1a1a1a),
                                        Color(0xFF000000),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : null,
                              color: isSelected ? null : Colors.grey[100],
                              borderRadius: BorderRadius.circular(28.r),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.black
                                    : Colors.grey[200]!,
                                width: 0.1.w,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.15),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  interest['emoji']!,
                                  style: TextStyle(fontSize: 20.sp),
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  interest['name']!,
                                  style: appStyle(
                                    14.sp,
                                    isSelected ? Colors.white : Colors.black,
                                    FontWeight.w600,
                                  ),
                                ),
                                if (isSelected) ...[
                                  SizedBox(width: 6.w),
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 16.sp,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // Done button
                Container(
                  padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 15,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      height: 56.h,
                      child: ElevatedButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Done (${_selectedInterests.length})',
                          style: appStyle(16.sp, Colors.white, FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final profile = profileState.profile;
    final isLoading = profileState.isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 20.sp),
          onPressed: isLoading
              ? null
              : () {
                  if (_hasChanges) {
                    _showDiscardDialog();
                  } else {
                    Navigator.pop(context);
                  }
                },
        ),
        title: Text(
          'Edit Profile',
          style: appStyle(
            20.sp,
            Colors.black,
            FontWeight.w800,
          ).copyWith(letterSpacing: isLoading ? 0 : -0.3),
        ),
        actions: [
          if (isLoading)
            Padding(
              padding: EdgeInsets.all(16.w),
              child: SizedBox(
                width: 24.w,
                height: 24.h,
                child: const LottieLoadingIndicator(),
              ),
            )
          else
            Container(
              margin: EdgeInsets.only(right: 12.w),
              child: TextButton(
                onPressed: _hasChanges ? _saveChanges : null,
                style: TextButton.styleFrom(
                  backgroundColor: _hasChanges
                      ? Colors.black
                      : Colors.grey[200],
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 10.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                ),
                child: Text(
                  'Save',
                  style: appStyle(
                    14.sp,
                    _hasChanges ? Colors.white : Colors.grey[500]!,
                    FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: profileState.isLoading && profile == null
          ? const Center(child: LottieLoadingIndicator())
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8.h),
                      _buildPhotosSection(),
                      SizedBox(height: 12.h),
                      _buildBasicInfoSection(),
                      SizedBox(height: 12.h),
                      _buildInterestsSection(),
                      SizedBox(height: 12.h),
                      _buildPreferencesSection(),
                      SizedBox(height: 12.h),
                      _buildPrivacySection(),
                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildPhotosSection() {
    final profile = ref.watch(profileProvider).profile;
    final photos = profile?.imageUrls ?? [];

    // Debug logging
    print('📸 Edit Profile - Photos count: ${photos.length}');
    if (photos.isNotEmpty) {
      print('📸 Edit Profile - Photos: $photos');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Profile Photos',
              style: appStyle(
                18.sp,
                Colors.black,
                FontWeight.w800,
              ).copyWith(letterSpacing: -0.3),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: photos.length >= 6 ? Colors.red : Colors.black,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                '${photos.length}/6',
                style: appStyle(12.sp, Colors.white, FontWeight.w600),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          'Add up to 6 photos to your profile',
          style: appStyle(
            13.sp,
            Colors.grey[600]!,
            FontWeight.w400,
          ).copyWith(letterSpacing: -0.3),
        ),
        SizedBox(height: 20.h),

        // Photos Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 0.75,
          ),
          itemCount: photos.length < 6 ? photos.length + 1 : 6,
          itemBuilder: (context, index) {
            if (index == photos.length && photos.length < 6) {
              // Add photo button
              return GestureDetector(
                onTap: _isUploadingPhoto ? null : _pickAndUploadImage,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 1.5,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: _isUploadingPhoto
                      ? const Center(child: LottieLoadingIndicator())
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 32.sp,
                              color: Colors.grey[600],
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'Add Photo',
                              style: appStyle(
                                11.sp,
                                Colors.grey[700]!,
                                FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                ),
              );
            }

            // Photo item
            return Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: CachedNetworkImage(
                    imageUrl: photos[index],
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) {
                      print('🔄 Loading image: $url');
                      return Container(
                        color: Colors.grey[200],
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        ),
                      );
                    },
                    errorWidget: (context, url, error) {
                      print('❌ Failed to load image: $url');
                      print('❌ Error: $error');
                      return Container(
                        color: Colors.grey[300],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image_outlined,
                              size: 32.sp,
                              color: Colors.grey[600],
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Failed to load',
                              style: appStyle(
                                9.sp,
                                Colors.grey[600]!,
                                FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                // Delete button
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: GestureDetector(
                    onTap: () => _deletePhoto(index),
                    child: Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16.sp,
                      ),
                    ),
                  ),
                ),
                // Primary badge
                if (index == 0)
                  Positioned(
                    bottom: 8.h,
                    left: 8.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        'Primary',
                        style: appStyle(10.sp, Colors.white, FontWeight.w600),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Basic Information',
              style: appStyle(
                18.sp,
                Colors.black,
                FontWeight.w800,
              ).copyWith(letterSpacing: -0.3),
            ),
          ],
        ),
        SizedBox(height: 24.h),
        CustomTextField(
          label: 'Full Name',
          hintText: 'Enter your full name',
          controller: _nameController,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Name is required';
            }
            return null;
          },
          keyboardType: TextInputType.text,
          prefixIcon: Icon(IconlyLight.profile, color: Colors.grey[600]),
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          label: 'Course',
          hintText: 'e.g., Computer Science',
          controller: _courseController,
          keyboardType: TextInputType.text,
          prefixIcon: Icon(Icons.school_outlined, color: Colors.grey[600]),
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          label: 'Bio',
          hintText: 'Tell us about yourself...',
          controller: _bioController,
          validator: (value) {
            if (value != null && value.length > 500) {
              return 'Bio must be 500 characters or less';
            }
            return null;
          },
          keyboardType: TextInputType.multiline,
          maxLines: 4,
          prefixIcon: Icon(Icons.edit_outlined, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildInterestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'Interests',
                  style: appStyle(
                    18.sp,
                    Colors.black,
                    FontWeight.w800,
                  ).copyWith(letterSpacing: -0.3),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                '${_selectedInterests.length}/10',
                style: appStyle(12.sp, Colors.white, FontWeight.w600),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          'Share what you love to do',
          style: appStyle(
            13.sp,
            Colors.grey[600]!,
            FontWeight.w400,
          ).copyWith(letterSpacing: -0.3),
        ),
        SizedBox(height: 20.h),

        if (_selectedInterests.isEmpty)
          GestureDetector(
            onTap: _showInterestsBottomSheet,
            child: Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey[50]!, Colors.grey[100]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.grey[300]!, width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    color: Colors.black,
                    size: 24.sp,
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Add Your Interests',
                    style: appStyle(15.sp, Colors.black, FontWeight.w600),
                  ),
                ],
              ),
            ),
          )
        else
          Column(
            children: [
              Wrap(
                spacing: 10.w,
                runSpacing: 10.h,
                children: _selectedInterests.map((interest) {
                  final interestData = availableInterests.firstWhere(
                    (i) => i['name'] == interest,
                    orElse: () => {'name': interest, 'emoji': '✨'},
                  );
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1a1a1a), Color(0xFF000000)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(25.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          interestData['emoji']!,
                          style: TextStyle(fontSize: 18.sp),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          interest,
                          style: appStyle(
                            13.sp,
                            Colors.white,
                            FontWeight.w600,
                          ).copyWith(letterSpacing: -0.3),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 16.h),
              GestureDetector(
                onTap: _showInterestsBottomSheet,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 14.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(30.r),
                    border: Border.all(color: Colors.grey[300]!, width: 1.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        color: Colors.black,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Edit Interests',
                        style: appStyle(
                          14.sp,
                          Colors.black,
                          FontWeight.w600,
                        ).copyWith(letterSpacing: -0.3),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildPreferencesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Preferences',
              style: appStyle(
                18.sp,
                Colors.black,
                FontWeight.w800,
              ).copyWith(letterSpacing: -0.3),
            ),
          ],
        ),
        SizedBox(height: 24.h),

        // Gender
        _buildDropdownField(
          label: 'Gender',
          value: _selectedGender,
          items: const ['male', 'female', 'other'],
          onChanged: (value) {
            setState(() {
              _selectedGender = value!;
              _hasChanges = true;
            });
          },
        ),
        SizedBox(height: 16.h),

        // Intent
        _buildDropdownField(
          label: 'Looking For',
          value: _selectedIntent,
          items: const ['dating', 'relationship', 'friends'],
          onChanged: (value) {
            setState(() {
              _selectedIntent = value!;
              _hasChanges = true;
            });
          },
        ),
        SizedBox(height: 20.h),

        // Preferred Genders
        Text(
          'Interested In',
          style: appStyle(
            14.sp,
            Colors.grey[700]!,
            FontWeight.w600,
          ).copyWith(letterSpacing: -0.3),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: ['male', 'female', 'other'].map((gender) {
            final isSelected = _selectedPreferredGenders.contains(gender);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    if (_selectedPreferredGenders.length > 1) {
                      _selectedPreferredGenders.remove(gender);
                    }
                  } else {
                    _selectedPreferredGenders.add(gender);
                  }
                  _hasChanges = true;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black : Colors.grey[50],
                  borderRadius: BorderRadius.circular(25.r),
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.grey[300]!,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected)
                      Padding(
                        padding: EdgeInsets.only(right: 6.w),
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 16.sp,
                        ),
                      ),
                    Text(
                      gender[0].toUpperCase() + gender.substring(1),
                      style: appStyle(
                        13.sp,
                        isSelected ? Colors.white : Colors.black,
                        FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: appStyle(
            14.sp,
            Colors.grey[700]!,
            FontWeight.w600,
          ).copyWith(letterSpacing: -0.3),
        ),
        SizedBox(height: 10.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.grey[300]!, width: 1.3),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.grey[600],
                size: 24.sp,
              ),
              items: items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(
                    item[0].toUpperCase() + item.substring(1),
                    style: appStyle(
                      14.sp,
                      Colors.black,
                      FontWeight.w500,
                    ).copyWith(letterSpacing: -0.3),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Privacy Settings',
              style: appStyle(
                18.sp,
                Colors.black,
                FontWeight.w800,
              ).copyWith(letterSpacing: -0.3),
            ),
          ],
        ),
        SizedBox(height: 20.h),

        // Private profile toggle
        _buildSwitchTile(
          title: 'Private Profile',
          subtitle: 'Hide your real name and bio until you match',
          value: _isPrivate,
          onChanged: (value) {
            setState(() {
              _isPrivate = value;
              _hasChanges = true;
            });
          },
        ),
        SizedBox(height: 12.h),

        // Show real name on match toggle
        _buildSwitchTile(
          title: 'Show Real Name on Match',
          subtitle: 'Reveal your real name when you match with someone',
          value: _showRealNameOnMatch,
          onChanged: (value) {
            setState(() {
              _showRealNameOnMatch = value;
              _hasChanges = true;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required void Function(bool) onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: value
                ? [
                    Colors.black.withOpacity(0.08),
                    Colors.black.withOpacity(0.03),
                  ]
                : [Colors.grey[50]!, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: value ? Colors.black.withOpacity(0.15) : Colors.grey[300]!,
            width: 1.0,
          ),
          boxShadow: value
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: appStyle(
                      14.sp,
                      value ? Colors.black : Colors.black87,
                      value ? FontWeight.w700 : FontWeight.w600,
                    ),
                    child: Text(title),
                  ),
                  SizedBox(height: 6.h),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: appStyle(
                      12.sp,
                      value ? Colors.grey[700]! : Colors.grey[600]!,
                      FontWeight.w400,
                    ),
                    child: Text(subtitle),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16.w),
            CustomSwitch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}
