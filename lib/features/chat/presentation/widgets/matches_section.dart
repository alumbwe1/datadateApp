import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_style.dart';
import 'match_card.dart';

class MatchesSection extends StatelessWidget {
  final List matches;

  const MatchesSection({super.key, required this.matches});

  @override
  Widget build(BuildContext context) {
    if (matches.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'New Matches',
                      style: appStyle(
                        12.sp,
                        Colors.grey.shade500,
                        FontWeight.w700,
                      ).copyWith(letterSpacing: -0.3, height: 1.2),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondaryLight.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${matches.length}',
                  style: appStyle(
                    12.sp,
                    AppColors.secondaryLight,
                    FontWeight.w700,
                  ).copyWith(letterSpacing: -0.3),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 160.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            physics: const BouncingScrollPhysics(),
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final match = matches[index];
              return MatchCard(match: match, index: index);
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
