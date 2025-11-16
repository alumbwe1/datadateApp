import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/constants/app_style.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../../../universities/domain/entities/university.dart';
import '../../../universities/presentation/pages/university_selection_page.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();

  String _selectedGender = 'male';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  University? _selectedUniversity;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _selectUniversity() async {
    final result = await Navigator.of(context).push<University>(
      MaterialPageRoute(builder: (context) => const UniversitySelectionPage()),
    );

    if (result != null) {
      setState(() {
        _selectedUniversity = result;
      });
    }
  }

  void _handleContinue() {
    if (_formKey.currentState!.validate()) {
      if (_selectedUniversity == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please select your university',
              style: appStyle(14, Colors.white, FontWeight.w600),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        );
        return;
      }

      // Store basic info in onboarding provider
      ref
          .read(onboardingProvider.notifier)
          .setBasicInfo(
            name: _nameController.text,
            email: _emailController.text,
            password: _passwordController.text,
            age: int.parse(_ageController.text),
            gender: _selectedGender,
          );

      // Store university ID
      ref
          .read(onboardingProvider.notifier)
          .setUniversity(_selectedUniversity!.id);

      // Navigate to gender preference
      context.push('/onboarding/gender-preference');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(color: Colors.white),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo
                Center(
                  child: Image.asset(
                    'assets/images/dataDate.png',
                    height: 50.h,
                    width: 50.w,
                    color: Colors.black,
                    fit: BoxFit.cover,
                  ),
                ),

                SizedBox(height: 24.h),

                Text(
                  'Create Account',
                  style: appStyle(
                    32,
                    Colors.black,
                    FontWeight.w900,
                  ).copyWith(letterSpacing: -0.5),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 8.h),

                Text(
                  'Join the elite dating community',
                  style: appStyle(
                    15,
                    Colors.grey[600]!,
                    FontWeight.w400,
                  ).copyWith(letterSpacing: -0.2),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 40.h),

                CustomTextField(
                  label: 'Full Name',
                  hintText: 'Enter your full name',
                  controller: _nameController,
                  validator: (value) => Validators.required(value, 'Name'),
                  prefixIcon: const Icon(Iconsax.user_copy),
                ),

                SizedBox(height: 20.h),

                CustomTextField(
                  label: 'Email',
                  hintText: 'Enter your email',
                  controller: _emailController,
                  validator: Validators.email,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Iconsax.sms_copy),
                ),

                SizedBox(height: 20.h),

                CustomTextField(
                  label: 'Password',
                  hintText: 'Create a strong password',
                  controller: _passwordController,
                  validator: Validators.password,
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Iconsax.lock_copy),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.grey[600],
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),

                SizedBox(height: 20.h),

                CustomTextField(
                  label: 'Confirm Password',
                  hintText: 'Re-enter your password',
                  controller: _confirmPasswordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  obscureText: _obscureConfirmPassword,
                  prefixIcon: const Icon(Iconsax.lock_copy),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.grey[600],
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),

                SizedBox(height: 20.h),

                CustomTextField(
                  label: 'Age',
                  hintText: 'Enter your age',
                  controller: _ageController,
                  validator: Validators.age,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.cake_outlined),
                ),

                SizedBox(height: 20.h),

                // University selector
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Optional: Add a label above the selector
                    Padding(
                      padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
                      child: Text(
                        'University',
                        style: appStyle(
                          14,
                          Colors.black,
                          FontWeight.w600,
                        ).copyWith(letterSpacing: -0.2),
                      ),
                    ),

                    GestureDetector(
                      onTap: _selectUniversity,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 14.h,
                        ),
                        decoration: BoxDecoration(
                          color: _selectedUniversity != null
                              ? Colors.blue.withOpacity(0.05)
                              : Colors.grey[50],
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: _selectedUniversity != null
                                ? Colors.blue.withOpacity(0.4)
                                : Colors.grey[300]!,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Icon with background
                            Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: _selectedUniversity != null
                                    ? Colors.blue.withOpacity(0.1)
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Icon(
                                Icons.school_rounded,
                                size: 20.sp,
                                color: _selectedUniversity != null
                                    ? Colors.blue
                                    : Colors.grey[400],
                              ),
                            ),

                            SizedBox(width: 12.w),

                            // Text content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedUniversity?.name ??
                                        'Select your university',
                                    style: appStyle(
                                      15,
                                      _selectedUniversity != null
                                          ? Colors.black87
                                          : Colors.grey[500]!,
                                      _selectedUniversity != null
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  // Optional: Add subtitle when university is selected
                                  if (_selectedUniversity != null) ...[
                                    SizedBox(height: 2.h),
                                    Text(
                                      'Tap to change',
                                      style: appStyle(
                                        11,
                                        Colors.grey[500]!,
                                        FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            SizedBox(width: 8.w),

                            // Arrow indicator
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 20.sp,
                              color: _selectedUniversity != null
                                  ? Colors.blue
                                  : Colors.grey[400],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Optional: Add helper text below
                    if (_selectedUniversity == null)
                      Padding(
                        padding: EdgeInsets.only(left: 4.w, top: 6.h),
                        child: Text(
                          'Choose your university to continue',
                          style: appStyle(
                            11,
                            Colors.grey[500]!,
                            FontWeight.w400,
                          ),
                        ),
                      ),
                  ],
                ),

                SizedBox(height: 24.h),

                Text(
                  'Gender',
                  style: appStyle(
                    14,
                    Colors.black,
                    FontWeight.w600,
                  ).copyWith(letterSpacing: -0.2),
                ),

                SizedBox(height: 12.h),

                Row(
                  children: [
                    Expanded(
                      child: _GenderOption(
                        label: 'Male',
                        icon: Icons.male,
                        isSelected: _selectedGender == 'male',
                        onTap: () => setState(() => _selectedGender = 'male'),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _GenderOption(
                        label: 'Female',
                        icon: Icons.female,
                        isSelected: _selectedGender == 'female',
                        onTap: () => setState(() => _selectedGender = 'female'),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 40.h),

                CustomButton(text: 'Continue', onPressed: _handleContinue),

                SizedBox(height: 24.h),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: appStyle(
                        15,
                        Colors.grey[600]!,
                        FontWeight.w400,
                      ).copyWith(letterSpacing: -0.2),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: Text(
                        'Sign In',
                        style: appStyle(
                          15,
                          Colors.black,
                          FontWeight.w700,
                        ).copyWith(letterSpacing: -0.2),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GenderOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade600,
              size: 32,
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: appStyle(
                14,
                isSelected ? Colors.white : Colors.grey[600]!,
                FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
