import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_style.dart';
import '../providers/chat_detail_provider.dart';

class PremiumTypingIndicator extends ConsumerStatefulWidget {
  final int roomId;

  const PremiumTypingIndicator({super.key, required this.roomId});

  @override
  ConsumerState<PremiumTypingIndicator> createState() =>
      _PremiumTypingIndicatorState();
}

class _PremiumTypingIndicatorState extends ConsumerState<PremiumTypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatDetailProvider(widget.roomId));
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Don't show if no one is typing
    if (!chatState.isTyping) {
      return const SizedBox.shrink();
    }

    final otherParticipant = chatState.room?.otherParticipant;
    final firstName =
        otherParticipant?.displayName.split(' ').first ?? 'Someone';
    final typingText = '$firstName is typing';

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      builder: (context, slideValue, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - slideValue)),
          child: Opacity(
            opacity: slideValue,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF2A1F35) : Colors.grey[50],
                border: Border(
                  bottom: BorderSide(
                    color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: isDarkMode ? 0.1 : 0.02,
                    ),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDarkMode ? Colors.grey[700] : Colors.grey[200],
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDarkMode ? 0.2 : 0.05,
                          ),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 1.0 + (0.2 * _controller.value),
                            child: Icon(
                              Icons.more_horiz,
                              size: 16,
                              color: isDarkMode
                                  ? Colors.grey[300]
                                  : Colors.grey[600],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      typingText,
                      style: appStyle(
                        13,
                        isDarkMode ? Colors.grey[300]! : Colors.grey[600]!,
                        FontWeight.w500,
                      ).copyWith(fontStyle: FontStyle.italic),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  _buildTypingDots(isDarkMode),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTypingDots(bool isDarkMode) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final animValue = (_controller.value + delay) % 1.0;
            final opacity =
                0.3 + (0.7 * (animValue > 0.5 ? 1 - animValue : animValue) * 2);

            final dotColor = isDarkMode ? Colors.grey[300]! : Colors.grey[600]!;

            return Container(
              width: 4,
              height: 4,
              margin: const EdgeInsets.only(right: 3),
              decoration: BoxDecoration(
                color: dotColor.withValues(alpha: opacity),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: dotColor.withValues(alpha: opacity * 0.3),
                    blurRadius: 2,
                    spreadRadius: 0.5,
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }
}
