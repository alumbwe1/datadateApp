import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconly/iconly.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_style.dart';

class ChatSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isSearching;
  final VoidCallback onTap;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const ChatSearchBar({
    super.key,
    required this.controller,
    required this.isSearching,
    required this.onTap,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDarkMode ? const Color(0xFF1A1625) : Colors.white,
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF2A1F35) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: TextField(
          controller: controller,
          onTap: onTap,
          onChanged: onChanged,
          style: appStyle(
            15,
            isDarkMode ? Colors.white : Colors.black87,
            FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: 'Search conversations...',
            hintStyle: appStyle(
              15,
              isDarkMode ? Colors.grey[400]! : Colors.grey[600]!,
              FontWeight.w400,
            ).copyWith(letterSpacing: -0.3),
            prefixIcon: Icon(
              IconlyLight.search,
              color: isSearching ? AppColors.secondaryLight : Colors.grey[600],
              size: 22,
            ),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.close,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      size: 20,
                    ),
                    onPressed: () {
                      controller.clear();
                      onClear();
                      HapticFeedback.lightImpact();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }
}
