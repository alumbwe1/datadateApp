import 'package:datadate/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconly/iconly.dart';
import '../../../../core/constants/app_style.dart';

class PremiumMessageInput extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;
  final int? editingMessageId;
  final String? editingOriginalContent;
  final VoidCallback? onCancelEditing;

  const PremiumMessageInput({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSend,
    this.editingMessageId,
    this.editingOriginalContent,
    this.onCancelEditing,
  });

  @override
  State<PremiumMessageInput> createState() => _PremiumMessageInputState();
}

class _PremiumMessageInputState extends State<PremiumMessageInput>
    with SingleTickerProviderStateMixin {
  bool _isTyping = false;
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
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _sendButtonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: _buildTextField()),
                const SizedBox(width: 10),
                _buildSendButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField() {
    return TextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      maxLines: 5,
      minLines: 1,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        hintText: widget.editingMessageId != null
            ? 'Edit your message...'
            : 'Type a message...',
        hintStyle: appStyle(15.sp, Colors.grey, FontWeight.w400),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40.r),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40.r),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 0.7.w),
        ),
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      style: appStyle(15, Colors.black, FontWeight.w400).copyWith(height: 1.4),
    );
  }

  Widget _buildSendButton() {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.9, end: 1.0).animate(
        CurvedAnimation(
          parent: _sendButtonController,
          curve: Curves.elasticOut,
        ),
      ),
      child: GestureDetector(
        onTap: _isTyping ? widget.onSend : null,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _isTyping ? Colors.blueAccent : Colors.grey[300],
            shape: BoxShape.circle,
            boxShadow: _isTyping
                ? [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.2),
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
                color: _isTyping ? Colors.white : Colors.grey[500],
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
