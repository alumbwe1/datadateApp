import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_style.dart';
import '../../data/models/chat_room_model.dart';

class PremiumEmptyState extends StatelessWidget {
  final ChatRoomModel? room;
  final Function(String)? onSuggestionTap;

  const PremiumEmptyState({super.key, this.room, this.onSuggestionTap});

  final List<String> _starters = const [
    'Hey! 👋',
    'How\'s your day going?',
    'What music are you into? 🎵',
    'Coffee or tea? ☕',
    'What made you smile today? 😊',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final otherParticipant = room?.otherParticipant;
    final name = otherParticipant?.displayName ?? 'there';

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
      child: Column(
        children: [
          // Avatar
          _buildAvatar(otherParticipant, isDark),
          SizedBox(height: 24.h),

          // Welcome text
          Text(
            'Say hello to $name! 👋',
            style: appStyle(
              26.sp,
              isDark ? Colors.white : Colors.black,
              FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),

          Text(
            'Start a conversation',
            style: appStyle(
              14.sp,
              isDark ? Colors.grey[400]! : Colors.grey[600]!,
              FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.h),

          // Conversation starters
          Wrap(
            spacing: 5.w,
            runSpacing: 8.h,
            alignment: WrapAlignment.center,
            children: _starters.map((starter) {
              return _StarterChip(
                text: starter,
                isDark: isDark,
                onTap: () => onSuggestionTap?.call(starter),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(dynamic otherParticipant, bool isDark) {
    return Container(
      width: 100.w,
      height: 100.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? Colors.grey[800] : Colors.grey[200],
      ),
      child: otherParticipant?.profilePhoto != null
          ? ClipOval(
              child: Image.network(
                otherParticipant!.profilePhoto!,
                width: 100.w,
                height: 100.h,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildDefaultAvatar(isDark),
              ),
            )
          : _buildDefaultAvatar(isDark),
    );
  }

  Widget _buildDefaultAvatar(bool isDark) {
    return Icon(
      Icons.person,
      size: 40.sp,
      color: isDark ? Colors.grey[600] : Colors.grey[400],
    );
  }
}

class _StarterChip extends StatelessWidget {
  final String text;
  final bool isDark;
  final VoidCallback? onTap;

  const _StarterChip({
    required this.text,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 14.w,
          vertical: 10.h,
        ),
        decoration: BoxDecoration(
          color: isDark 
              ? Colors.grey[800]!.withValues(alpha: 0.5)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(40.r),
          border: Border.all(
            color: isDark 
                ? Colors.grey[700]! 
                : Colors.grey[100]!,
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: appStyle(
            13.sp,
            isDark ? Colors.grey[300]! : Colors.grey[700]!,
            FontWeight.w400,
          ),
        ),
      ),
    );
  }
}