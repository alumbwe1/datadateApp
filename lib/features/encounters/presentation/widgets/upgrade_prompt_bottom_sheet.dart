import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/constants/app_style.dart';

class UpgradePromptBottomSheet extends StatelessWidget {
  final VoidCallback onUpgrade;

  const UpgradePromptBottomSheet({super.key, required this.onUpgrade});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(32, 20, 32, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.purpleAccent.withOpacity(0.1),
                            Colors.deepPurpleAccent.withOpacity(0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purpleAccent.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Iconsax.diamonds,
                          color: Colors.purpleAccent,
                          size: 36,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Out of Swipes!',
                      style: appStyle(
                        30,
                        Colors.black,
                        FontWeight.w900,
                      ).copyWith(letterSpacing: -0.8),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Upgrade to Standard for unlimited swipes\nand exclusive features',
                      style: appStyle(
                        15,
                        Colors.grey[600]!,
                        FontWeight.w500,
                      ).copyWith(height: 1.6, letterSpacing: -0.2),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black, Colors.grey[900]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onUpgrade();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Upgrade Now',
                          style: appStyle(
                            16,
                            Colors.white,
                            FontWeight.w700,
                          ).copyWith(letterSpacing: 0.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 24,
                        ),
                      ),
                      child: Text(
                        'Maybe Later',
                        style: appStyle(15, Colors.grey[600]!, FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
