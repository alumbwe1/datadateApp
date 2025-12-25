import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_style.dart';

class PremiumBottomSheet extends StatefulWidget {
  final List<BottomSheetOption> options;
  final String? title;
  final String? subtitle;

  const PremiumBottomSheet({
    super.key,
    required this.options,
    this.title,
    this.subtitle,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required List<BottomSheetOption> options,
    String? title,
    String? subtitle,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) => PremiumBottomSheet(
        options: options,
        title: title,
        subtitle: subtitle,
      ),
    );
  }

  @override
  State<PremiumBottomSheet> createState() => _PremiumBottomSheetState();
}

class _PremiumBottomSheetState extends State<PremiumBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            if (widget.title != null) _buildTitleSection(),
            _buildOptionsList(),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(top: 12.h, bottom: 8.h),
      child: Container(
        width: 40.w,
        height: 4.h,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2.r),
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.title != null)
            Text(
              widget.title!,
              style: appStyle(
                20.sp,
                Colors.black,
                FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          if (widget.subtitle != null) ...[
            SizedBox(height: 6.h),
            Text(
              widget.subtitle!,
              style: appStyle(
                14.sp,
                Colors.grey[600]!,
                FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOptionsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: widget.options.length,
      itemBuilder: (context, index) {
        final option = widget.options[index];
        return _BottomSheetOptionTile(
          option: option,
          index: index,
        );
      },
    );
  }
}

class _BottomSheetOptionTile extends StatefulWidget {
  final BottomSheetOption option;
  final int index;

  const _BottomSheetOptionTile({
    required this.option,
    required this.index,
  });

  @override
  State<_BottomSheetOptionTile> createState() => _BottomSheetOptionTileState();
}

class _BottomSheetOptionTileState extends State<_BottomSheetOptionTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        HapticFeedback.selectionClick();
      },
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pop(context);
        Future.delayed(const Duration(milliseconds: 100), () {
          widget.option.onTap();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: EdgeInsets.only(bottom: 8.h),
        decoration: BoxDecoration(
          color: _isPressed ? Colors.grey[100] : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            _buildIcon(),
            SizedBox(width: 14.w),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    final iconColor = widget.option.isDestructive
        ? Colors.red[600]!
        : Colors.grey[700]!;

    return Icon(widget.option.icon, color: iconColor, size: 24.sp);
  }

  Widget _buildContent() {
    final textColor = widget.option.isDestructive
        ? Colors.red[600]!
        : Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.option.title,
          style: appStyle(16.sp, textColor, FontWeight.w500),
        ),
        if (widget.option.subtitle != null) ...[
          SizedBox(height: 2.h),
          Text(
            widget.option.subtitle!,
            style: appStyle(
              13.sp,
              Colors.grey[600]!,
              FontWeight.w400,
            ),
          ),
        ],
      ],
    );
  }
}

class BottomSheetOption {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const BottomSheetOption({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });
}