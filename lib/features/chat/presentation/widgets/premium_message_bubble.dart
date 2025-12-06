import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/constants/app_style.dart';

class PremiumMessageBubble extends StatefulWidget {
  final dynamic message;
  final bool isSent;
  final bool showAvatar;
  final String? avatarUrl;
  final String? senderName;
  final VoidCallback onLongPress;
  final bool isAudioMessage;

  const PremiumMessageBubble({
    super.key,
    required this.message,
    required this.isSent,
    required this.showAvatar,
    this.avatarUrl,
    this.senderName,
    required this.onLongPress,
    this.isAudioMessage = false,
  });

  @override
  State<PremiumMessageBubble> createState() => _PremiumMessageBubbleState();
}

class _PremiumMessageBubbleState extends State<PremiumMessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: Offset(widget.isSent ? 0.5 : -0.5, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          alignment: widget.isSent
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: widget.showAvatar ? 16 : 4,
              left: widget.isSent ? 50 : 0,
              right: widget.isSent ? 0 : 50,
              top: 4,
            ),
            child: Row(
              mainAxisAlignment: widget.isSent
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!widget.isSent && widget.showAvatar)
                  _buildAvatar()
                else if (!widget.isSent)
                  const SizedBox(width: 40),
                Flexible(
                  child: GestureDetector(
                    onLongPress: () {
                      HapticFeedback.mediumImpact();
                      widget.onLongPress();
                    },
                    child: _buildMessageContent(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageContent() {
    return Hero(
      tag: 'message_${widget.message.id}',
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: widget.isAudioMessage ? 12 : 16,
            vertical: widget.isAudioMessage ? 10 : 12,
          ),
          decoration: BoxDecoration(
            color: widget.isSent
                ? const Color(0xFF2B7EF5)
                : const Color(0xFFF0F0F0),
            borderRadius: _buildBorderRadius(),
            boxShadow: [
              BoxShadow(
                color: widget.isSent
                    ? Colors.pinkAccent.withValues(alpha: 0.25)
                    : Colors.black.withValues(alpha: 0.06),
                blurRadius: widget.isSent ? 12 : 8,
                offset: Offset(0, widget.isSent ? 3 : 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.isAudioMessage)
                _buildAudioContent()
              else
                Text(
                  widget.message.content,
                  style: appStyle(
                    15,
                    widget.isSent ? Colors.white : const Color(0xFF333333),
                    FontWeight.w500,
                  ).copyWith(height: 1.5, letterSpacing: -0.1),
                ),
              const SizedBox(height: 2),
              _buildTimestampRow(),
            ],
          ),
        ),
      ),
    );
  }

  BorderRadius _buildBorderRadius() {
    if (widget.isSent) {
      return BorderRadius.only(
        bottomLeft: Radius.circular(30.r),
        bottomRight: Radius.circular(2.r),
        topLeft: Radius.circular(30.r),
        topRight: Radius.circular(30.r),
      );
    } else {
      return BorderRadius.only(
        bottomLeft: Radius.circular(2.r),
        bottomRight: Radius.circular(30.r),
        topLeft: Radius.circular(30.r),
        topRight: Radius.circular(30.r),
      );
    }
  }

  Widget _buildAudioContent() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.isSent
                ? Colors.white.withValues(alpha: 0.25)
                : const Color(0xFFE5E5E5),
          ),
          child: Icon(
            Icons.play_arrow,
            size: 16,
            color: widget.isSent ? Colors.white : const Color(0xFF666666),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWaveform(),
              const SizedBox(height: 4),
              Text(
                '0:32',
                style: appStyle(
                  10,
                  widget.isSent
                      ? Colors.white.withValues(alpha: 0.75)
                      : const Color(0xFF999999),
                  FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWaveform() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        20,
        (i) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.5),
          child: Container(
            width: 2,
            height: 2 + (i % 4) * 4,
            decoration: BoxDecoration(
              color: widget.isSent
                  ? Colors.white.withValues(alpha: 0.6)
                  : const Color(0xFFCCCCCC),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimestampRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          timeago.format(
            DateTime.parse(widget.message.createdAt),
            locale: 'en_short',
            allowFromNow: true,
          ),
          style: appStyle(
            9.sp,
            widget.isSent
                ? Colors.white.withValues(alpha: 0.7)
                : const Color(0xFFAAAAAA),
            FontWeight.w500,
          ),
        ),
        if (widget.isSent) ...[
          const SizedBox(width: 6),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 500),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Icon(
                  widget.message.isRead ? Icons.done_all : Icons.check,
                  size: 14,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 40.w,
      height: 40.h,
      margin: const EdgeInsets.only(right: 10, bottom: 2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: widget.avatarUrl != null
            ? CachedNetworkImage(
                imageUrl: widget.avatarUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(color: const Color(0xFFF5F5F5)),
                errorWidget: (context, url, error) => _buildAvatarFallback(),
              )
            : _buildAvatarFallback(),
      ),
    );
  }

  Widget _buildAvatarFallback() {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: Center(
        child: Text(
          widget.senderName?[0].toUpperCase() ?? '?',
          style: appStyle(16, const Color(0xFF888888), FontWeight.w600),
        ),
      ),
    );
  }
}
