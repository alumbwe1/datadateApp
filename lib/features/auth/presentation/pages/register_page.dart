import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/constants/app_style.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/password_error_bottom_sheet.dart';
import '../../../../core/utils/validators.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';

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

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    // Additional password validation
    final passwordError = Validators.password(
      _passwordController.text,
      email: _emailController.text.trim(),
      username: _nameController.text.trim().toLowerCase().replaceAll(' ', '_'),
    );

    if (passwordError != null) {
      PasswordErrorBottomSheet.show(
        context,
        errorMessage: passwordError,
        onRetry: () {
          // Focus on password field
          FocusScope.of(context).requestFocus(FocusNode());
        },
      );
      return;
    }

    // Store registration data in onboarding provider
    ref
        .read(onboardingProvider.notifier)
        .setRegistrationData(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    // Navigate to gender selection first
    context.push('/onboarding/gender');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
                  hintText: 'At least 8 characters',
                  controller: _passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
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

                SizedBox(height: 40.h),

                CustomButton(
                  text: _isLoading ? 'Creating Account...' : 'Continue',
                  onPressed: _isLoading ? null : _handleRegister,
                ),

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
