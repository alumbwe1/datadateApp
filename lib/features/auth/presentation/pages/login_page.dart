import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconly/iconly.dart';
import '../../../../core/constants/app_style.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final success = await ref
          .read(authProvider.notifier)
          .login(
            username: _usernameController.text.trim(),
            password: _passwordController.text,
          );

      if (mounted) {
        if (success) {
          context.go('/encounters');
        } else {
          final authState = ref.read(authProvider);
          CustomSnackbar.show(
            context,
            message: authState.error ?? 'Login failed. Please try again.',
            type: SnackbarType.error,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 40.h),

                // Logo
                Center(
                  child: Image.asset(
                    'assets/images/dataDate.png',
                    height: 60.h,
                    width: 60.w,
                    color: Colors.black,
                    fit: BoxFit.cover,
                  ),
                ),

                SizedBox(height: 24.h),

                // Welcome back text
                Text(
                  'Welcome Back',
                  style: appStyle(
                    32,
                    Colors.black,
                    FontWeight.w900,
                  ).copyWith(letterSpacing: -0.3),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 8.h),

                Text(
                  'Sign in to continue your journey',
                  style: appStyle(
                    15,
                    Colors.grey[600]!,
                    FontWeight.w400,
                  ).copyWith(letterSpacing: -0.3),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 48.h),

                // Username field
                CustomTextField(
                  label: 'Username',
                  hintText: 'Enter your username',
                  controller: _usernameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Username is required';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.text,
                  prefixIcon: Icon(
                    IconlyLight.profile,
                    color: Colors.grey[600],
                  ),
                ),

                SizedBox(height: 20.h),

                // Password field
                CustomTextField(
                  label: 'Password',
                  hintText: 'Enter your password',
                  controller: _passwordController,
                  validator: Validators.password,
                  obscureText: _obscurePassword,
                  prefixIcon: Icon(IconlyLight.lock, color: Colors.grey[600]),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? IconlyLight.show : IconlyLight.hide,
                      color: Colors.grey[600],
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),

                SizedBox(height: 12.h),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Implement forgot password
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                    ),
                    child: Text(
                      'Forgot Password?',
                      style: appStyle(
                        14,
                        Colors.black,
                        FontWeight.w600,
                      ).copyWith(letterSpacing: -0.3),
                    ),
                  ),
                ),

                SizedBox(height: 32.h),

                // Login button
                CustomButton(
                  text: 'Sign In',
                  onPressed: _handleLogin,
                  isLoading: authState.isLoading,
                ),

                SizedBox(height: 24.h),

                // Divider with OR
                Row(
                  children: [
                    Expanded(
                      child: Divider(color: Colors.grey[300], thickness: 1),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text(
                        'OR',
                        style: appStyle(12, Colors.grey[600]!, FontWeight.w600),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: Colors.grey[300], thickness: 1),
                    ),
                  ],
                ),

                SizedBox(height: 24.h),

                // Sign up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don\'t have an account? ',
                      style: appStyle(
                        15,
                        Colors.grey[600]!,
                        FontWeight.w400,
                      ).copyWith(letterSpacing: -0.2),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/register'),
                      child: Text(
                        'Sign Up',
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
