import 'package:flutter/material.dart';
import '../../../../core/constants/app_style.dart';

class LikesEmptyState extends StatelessWidget {
  final bool isReceived;

  const LikesEmptyState({super.key, required this.isReceived});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFF6B9D).withOpacity(0.1),
                      const Color(0xFFFF8FB3).withOpacity(0.05),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    isReceived ? '💝' : '💌',
                    style: const TextStyle(fontSize: 70),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                isReceived ? 'No Likes Yet' : 'No Likes Sent',
                style: appStyle(26, Colors.black, FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  isReceived
                      ? 'When someone likes you, they\'ll appear here.\nKeep your profile updated to get more likes!'
                      : 'Start swiping right on profiles you like.\nYour likes will appear here.',
                  style: appStyle(
                    15,
                    Colors.grey[600]!,
                    FontWeight.w500,
                  ).copyWith(height: 1.6),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
