import 'package:datadate/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/constants/app_style.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/password_error_bottom_sheet.dart';
import '../../../../core/utils/validators.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../providers/auth_provider.dart';

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

    setState(() => _isLoading = true);

    try {
      // Create account and login immediately
      final username = _nameController.text.trim().toLowerCase().replaceAll(
        ' ',
        '_',
      );
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      // Register user (Step 1: POST /auth/users/)
      final registerSuccess = await ref
          .read(authProvider.notifier)
          .register(username: username, email: email, password: password);

      if (!registerSuccess) {
        if (mounted) {
          final authState = ref.read(authProvider);
          final errorMessage =
              authState.error ?? 'Registration failed. Please try again.';

          CustomSnackbar.show(
            context,
            message: errorMessage,
            type: SnackbarType.error,
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      // Auto-login (Step 2: POST /auth/jwt/create/)
      // Use username (not email) for login as backend requires it
      final loginSuccess = await ref
          .read(authProvider.notifier)
          .login(username: username, password: password);

      if (!loginSuccess) {
        if (mounted) {
          final authState = ref.read(authProvider);
          final errorMessage =
              authState.error ?? 'Login failed. Please try again.';

          CustomSnackbar.show(
            context,
            message: errorMessage,
            type: SnackbarType.error,
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      // Store name for profile update later
      ref
          .read(onboardingProvider.notifier)
          .setRegistrationData(
            name: _nameController.text.trim(),
            email: email,
            password: password,
          );

      // Navigate to onboarding flow (Step 3: Complete profile)
      if (mounted) {
        context.go('/onboarding/university');
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.show(
          context,
          message: 'An unexpected error occurred. Please try again.',
          type: SnackbarType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
                    'assets/images/HeartLink1.png',
                    height: 80.h,
                    width: 80.w,
                    color: AppColors.primaryLight,
                    fit: BoxFit.cover,
                  ),
                ),

                SizedBox(height: 10.h),

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
                  label: 'User Name',
                  hintText: 'Enter your user name',
                  controller: _nameController,
                  validator: (value) => Validators.required(value, 'User Name'),
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

                _isLoading
                    ? Container(
                        height: 58.h,
                        alignment: Alignment.center,
                        child: LottieLoadingIndicator(),
                      )
                    : CustomButton(
                        text: _isLoading ? 'Creating Account...' : 'Continue',
                        onTap: _handleRegister,
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
