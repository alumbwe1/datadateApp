import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconly/iconly.dart';
import '../../../../core/constants/app_style.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../chat/presentation/pages/chat_detail_page.dart';
import '../../../chat/presentation/providers/chat_detail_provider.dart';

class MatchPage extends ConsumerStatefulWidget {
  final String profileName;
  final String profilePhoto;
  final int roomId;

  const MatchPage({
    super.key,
    required this.profileName,
    required this.profilePhoto,
    required this.roomId,
  });

  @override
  ConsumerState<MatchPage> createState() => _MatchPageState();
}

class _MatchPageState extends ConsumerState<MatchPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  final TextEditingController _messageController = TextEditingController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
  }

  Future<void> _sendMessageAndNavigate() async {
    final message = _messageController.text.trim();

    if (message.isEmpty) {
      // Navigate to chat without sending a message
      _navigateToChat();
      return;
    }

    setState(() => _isSending = true);
    HapticFeedback.mediumImpact();

    try {
      // Send the message using chat provider
      await ref
          .read(chatDetailProvider(widget.roomId).notifier)
          .sendMessage(message);

      if (mounted) {
        // Navigate to chat detail page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailPage(roomId: widget.roomId),
          ),
        );
      }
    } catch (e) {
      setState(() => _isSending = false);
      if (mounted) {
        CustomSnackbar.show(
          context,
          message: 'Failed to send message. Try again.',
          type: SnackbarType.error,
        );
      }
    }
  }

  void _navigateToChat() {
    HapticFeedback.lightImpact();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailPage(roomId: widget.roomId),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: CachedNetworkImageProvider(widget.profilePhoto),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.7),
                Colors.black.withValues(alpha: 0.5),
                Colors.black.withValues(alpha: 0.9),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Close button
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.white, size: 30.sp),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),

                const Spacer(),

                // Match content
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.w),
                  child: Column(
                    children: [
                      // Animated hearts
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Text('💕', style: TextStyle(fontSize: 80.sp)),
                      ),

                      SizedBox(height: 24.h),

                      // Match text
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          'It\'s a match!',
                          style: appStyle(42, Colors.white, FontWeight.w900)
                              .copyWith(
                                letterSpacing: -1,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    offset: const Offset(0, 4),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      SizedBox(height: 12.h),

                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          '${widget.profileName} likes you back – get those sparks flying ✨',
                          style: appStyle(16, Colors.white, FontWeight.w500)
                              .copyWith(
                                height: 1.5,
                                letterSpacing: -0.3,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    offset: const Offset(0, 2),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Message input and quick replies
                Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    children: [
                      // Message input with send button
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _messageController,
                                  enabled: !_isSending,
                                  decoration: InputDecoration(
                                    hintText: 'Write a message',
                                    hintStyle: appStyle(
                                      16,
                                      Colors.grey[500]!,
                                      FontWeight.w400,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30.r),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 24.w,
                                      vertical: 16.h,
                                    ),
                                  ),
                                  style: appStyle(
                                    16,
                                    Colors.black,
                                    FontWeight.w400,
                                  ),
                                  onSubmitted: (_) => _sendMessageAndNavigate(),
                                ),
                              ),
                              if (_messageController.text.isNotEmpty ||
                                  _isSending)
                                Padding(
                                  padding: EdgeInsets.only(right: 8.w),
                                  child: GestureDetector(
                                    onTap: _isSending
                                        ? null
                                        : _sendMessageAndNavigate,
                                    child: Container(
                                      padding: EdgeInsets.all(12.w),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.pink[400]!,
                                            Colors.pink[600]!,
                                          ],
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: _isSending
                                          ? SizedBox(
                                              width: 20.w,
                                              height: 20.w,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.white),
                                              ),
                                            )
                                          : Icon(
                                              Icons.send_rounded,
                                              color: Colors.white,
                                              size: 20.w,
                                            ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // Quick reply buttons
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Row(
                          children: [
                            Expanded(
                              child: _QuickReplyButton(
                                text: 'How are you?',
                                onTap: () {
                                  setState(() {
                                    _messageController.text = 'How are you?';
                                  });
                                },
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: _QuickReplyButton(
                                text: 'How\'s your day going?',
                                onTap: () {
                                  setState(() {
                                    _messageController.text =
                                        'How\'s your day going?';
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // Send message button
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSending
                                ? null
                                : _sendMessageAndNavigate,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink[500],
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.r),
                              ),
                              elevation: 4,
                            ),
                            child: _isSending
                                ? SizedBox(
                                    height: 20.h,
                                    width: 20.w,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Send Message',
                                    style: appStyle(
                                      16,
                                      Colors.white,
                                      FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      SizedBox(height: 12.h),

                      // Keep swiping button
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Keep Swiping',
                            style: appStyle(16, Colors.white, FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickReplyButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _QuickReplyButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(IconlyBold.send, size: 18, color: Colors.black),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(
                text,
                style: appStyle(
                  14,
                  Colors.black,
                  FontWeight.w600,
                ).copyWith(letterSpacing: -0.2),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
