import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconly/iconly.dart';
import 'package:google_fonts/google_fonts.dart';
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
          padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 40.h),

              // Logo
              Center(
                child: Image.asset(
                  'assets/images/HeartLink1.png',
                  height: 70.h,
                  width: 70.w,
                  color: const Color(0xFF6C5CE7), // Premium purple
                  fit: BoxFit.cover,
                ),
              ),

              SizedBox(height: 24.h),

              // Welcome text
              Text(
                'Welcome Back',
                style: GoogleFonts.poppins(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  letterSpacing: -0.3,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 8.h),

              Text(
                'Sign in to continue your journey',
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[600],
                  letterSpacing: -0.3,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 48.h),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Username
                    CustomTextField(
                      label: 'Username',
                      hintText: 'Enter your username',
                      controller: _usernameController,
                      validator: (value) =>
                          value!.isEmpty ? 'Username is required' : null,
                      keyboardType: TextInputType.text,
                      prefixIcon: Icon(
                        IconlyLight.profile,
                        color: Colors.grey[600],
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Password
                    CustomTextField(
                      label: 'Password',
                      hintText: 'Enter your password',
                      controller: _passwordController,
                      validator: Validators.password,
                      obscureText: _obscurePassword,
                      prefixIcon: Icon(
                        IconlyLight.lock,
                        color: Colors.grey[600],
                      ),
                      suffixIcon: IconButton(
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            _obscurePassword
                                ? IconlyLight.show
                                : IconlyLight.hide,
                            key: ValueKey(_obscurePassword),
                            color: Colors.grey[600],
                          ),
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
                        onPressed: () {},
                        child: Text(
                          'Forgot Password?',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 32.h),

                    // Sign In button
                    CustomButton(
                      text: 'Sign In',
                      onPressed: _handleLogin,
                      isLoading: authState.isLoading,

                      // gradient: const LinearGradient(
                      //   colors: [Color(0xFF6C5CE7), Color(0xFF341F97)],
                      // ),
                    ),

                    SizedBox(height: 24.h),

                    // Divider OR
                    Row(
                      children: [
                        Expanded(
                          child: Divider(color: Colors.grey[300], thickness: 1),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Text(
                            'OR',
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(color: Colors.grey[300], thickness: 1),
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    // Sign up
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Don\'t have an account? ',
                          style: GoogleFonts.poppins(
                            fontSize: 15.sp,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.push('/register'),
                          child: Text(
                            'Sign Up',
                            style: GoogleFonts.poppins(
                              fontSize: 15.sp,
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
