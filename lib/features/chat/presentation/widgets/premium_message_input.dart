import 'package:datadate/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconly/iconly.dart';
import '../../../../core/constants/app_style.dart';
import '../../../../core/providers/connectivity_provider.dart';
import '../providers/chat_detail_provider.dart';

class PremiumMessageInput extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;
  final int? editingMessageId;
  final String? editingOriginalContent;
  final VoidCallback? onCancelEditing;
  final int roomId;

  const PremiumMessageInput({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSend,
    required this.roomId,
    this.editingMessageId,
    this.editingOriginalContent,
    this.onCancelEditing,
  });

  @override
  ConsumerState<PremiumMessageInput> createState() =>
      _PremiumMessageInputState();
}

class _PremiumMessageInputState extends ConsumerState<PremiumMessageInput>
    with SingleTickerProviderStateMixin {
  bool _isTyping = false;
  bool _wasTyping = false;
  late AnimationController _sendButtonController;

  @override
  void initState() {
    super.initState();
    _sendButtonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final newIsTyping = widget.controller.text.isNotEmpty;
    final hasTextChanged = widget.controller.text != _getLastText();

    if (newIsTyping != _isTyping) {
      setState(() {
        _isTyping = newIsTyping;
      });
      if (_isTyping) {
        _sendButtonController.forward();
      } else {
        _sendButtonController.reverse();
      }
    }

    // Send typing indicator when user starts typing
    if (hasTextChanged && newIsTyping && !_wasTyping) {
      _sendTypingIndicator(true);
      _wasTyping = true;
    } else if (!newIsTyping && _wasTyping) {
      _sendTypingIndicator(false);
      _wasTyping = false;
    }
  }

  String _getLastText() {
    // Simple way to track if text actually changed
    return widget.controller.text;
  }

  void _sendTypingIndicator(bool isTyping) {
    ref
        .read(chatDetailProvider(widget.roomId).notifier)
        .sendTypingIndicator(isTyping);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _sendButtonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatDetailProvider(widget.roomId));
    final connectionAsync = ref.watch(connectionInfoProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Show editing banner if editing
            if (widget.editingMessageId != null) _buildEditingBanner(),

            // Connection status banner (only show if offline)
            connectionAsync.when(
              data: (connection) => _buildConnectionBanner(connection),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: _buildTextField(chatState)),
                const SizedBox(width: 10),
                _buildSendButton(chatState),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditingBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.edit, size: 16, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Editing message',
              style: appStyle(12.sp, Colors.blue, FontWeight.w600),
            ),
          ),
          GestureDetector(
            onTap: widget.onCancelEditing,
            child: const Icon(Icons.close, size: 16, color: Colors.blue),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionBanner(connection) {
    if (connection.isConnected && !connection.isSlow) {
      return const SizedBox.shrink();
    }

    Color bannerColor;
    IconData bannerIcon;
    String bannerText;

    if (!connection.isConnected) {
      bannerColor = Colors.red;
      bannerIcon = Icons.signal_wifi_off;
      bannerText = 'No internet connection. Messages will be queued.';
    } else if (connection.isSlow) {
      bannerColor = Colors.orange;
      bannerIcon = Icons.signal_wifi_bad;
      bannerText = 'Slow connection. Messages may be delayed.';
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bannerColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: bannerColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(bannerIcon, size: 16, color: bannerColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              bannerText,
              style: appStyle(12.sp, bannerColor, FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(ChatDetailState chatState) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return TextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      maxLines: 5,
      minLines: 1,
      textCapitalization: TextCapitalization.sentences,
      enabled: true, // Always enabled, we handle offline in the send logic
      decoration: InputDecoration(
        hintText: widget.editingMessageId != null
            ? 'Edit your message...'
            : chatState.isOnline
            ? 'Type a message...'
            : 'Type a message (will be queued)...',
        hintStyle: appStyle(
          15.sp,
          isDarkMode ? Colors.grey[400]! : Colors.grey,
          FontWeight.w400,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40.r),
          borderSide: BorderSide(
            color: chatState.isOnline ? AppColors.primaryLight : Colors.orange,
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40.r),
          borderSide: BorderSide(
            color: chatState.isOnline
                ? (isDarkMode ? Colors.grey[600]! : Colors.grey.shade300)
                : Colors.orange.withValues(alpha: 0.5),
            width: 0.7.w,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40.r),
          borderSide: BorderSide(color: Colors.grey.shade400, width: 0.7.w),
        ),
        border: const OutlineInputBorder(),
        isDense: true,
        filled: true,
        fillColor: isDarkMode
            ? Colors.grey[800]
            : chatState.isOnline
            ? Colors.white
            : Colors.orange.withValues(alpha: 0.05),
      ),
      style: appStyle(
        15,
        isDarkMode ? Colors.white : Colors.black,
        FontWeight.w400,
      ).copyWith(height: 1.4),
    );
  }

  Widget _buildSendButton(ChatDetailState chatState) {
    final canSend = _isTyping;
    final buttonColor = canSend
        ? (chatState.isOnline ? Colors.blueAccent : Colors.orange)
        : Colors.grey[300];

    return ScaleTransition(
      scale: Tween<double>(begin: 0.9, end: 1.0).animate(
        CurvedAnimation(
          parent: _sendButtonController,
          curve: Curves.elasticOut,
        ),
      ),
      child: GestureDetector(
        onTap: canSend ? widget.onSend : null,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: buttonColor,
            shape: BoxShape.circle,
            boxShadow: canSend
                ? [
                    BoxShadow(
                      color: (chatState.isOnline ? Colors.blue : Colors.orange)
                          .withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  scale: animation,
                  child: RotationTransition(
                    turns: Tween<double>(
                      begin: 0.5,
                      end: 1.0,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: Icon(
                widget.editingMessageId != null ? Icons.check : IconlyBold.send,
                key: ValueKey(widget.editingMessageId != null),
                color: canSend ? Colors.white : Colors.grey[500],
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
