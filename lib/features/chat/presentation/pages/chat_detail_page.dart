import 'package:datadate/core/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_style.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/connectivity_status_banner.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/chat_detail_provider.dart';
import '../widgets/chat_error_banner.dart';
import '../widgets/chat_options_sheet.dart';
import '../widgets/message_options_sheet.dart';
import '../widgets/premium_app_bar.dart';
import '../widgets/premium_dialog.dart';
import '../widgets/premium_empty_state.dart';
import '../widgets/premium_message_bubble.dart';
import '../widgets/premium_message_input.dart';
import '../widgets/premium_typing_indicator.dart';

class ChatDetailPage extends ConsumerStatefulWidget {
  final int roomId;

  const ChatDetailPage({super.key, required this.roomId});

  @override
  ConsumerState<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends ConsumerState<ChatDetailPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  int? _editingMessageId;
  String? _editingOriginalContent;
  late AnimationController _fabController;

  @override
  void initState() {
    super.initState();

    _fabController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 300), _scrollToBottom);
      }
    });

    _scrollController.addListener(() {
      // Load more when scrolling to the top (older messages)
      if (_scrollController.position.pixels == 0) {
        ref
            .read(chatDetailProvider(widget.roomId).notifier)
            .loadMessages(isLoadMore: true);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatDetailProvider(widget.roomId).notifier).loadMessages();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    if (_editingMessageId != null) {
      try {
        await ref
            .read(chatDetailProvider(widget.roomId).notifier)
            .editMessage(_editingMessageId!, content);

        _cancelEditing();
        HapticFeedback.lightImpact();

        if (mounted) {
          CustomSnackbar.show(
            context,
            message: 'Message updated successfully',
            type: SnackbarType.success,
            duration: const Duration(seconds: 2),
          );
        }
      } catch (e) {
        if (mounted) {
          CustomSnackbar.show(
            context,
            message: 'Failed to update message',
            type: SnackbarType.error,
            duration: const Duration(seconds: 2),
          );
        }
      }
    } else {
      ref.read(chatDetailProvider(widget.roomId).notifier).sendMessage(content);
      _messageController.clear();
      _scrollToBottom();
      HapticFeedback.lightImpact();
    }
  }

  void _startEditing(message) {
    setState(() {
      _editingMessageId = message.id;
      _editingOriginalContent = message.content;
      _messageController.text = message.content;
    });
    _focusNode.requestFocus();
    HapticFeedback.lightImpact();
  }

  void _cancelEditing() {
    if (_editingMessageId != null) {
      setState(() {
        _editingMessageId = null;
        _editingOriginalContent = null;
        _messageController.clear();
      });
    }
  }

  void _showMessageOptions(message, bool isSent) {
    MessageOptionsSheet.show(
      context: context,
      message: message,
      isSent: isSent,
      onEdit: _startEditing,
      onDelete: _confirmDeleteMessage,
    );
  }

  void _confirmDeleteMessage(message) {
    final scaffoldContext = context;

    PremiumDialog.show(
      context: context,
      icon: Icons.warning_amber_rounded,
      iconColor: Colors.white,
      title: 'Delete Message',
      message:
          'This message will be permanently deleted. This action cannot be undone.',
      confirmText: 'Delete',
      confirmColor: Colors.red,
      onConfirm: () async {
        HapticFeedback.mediumImpact();

        try {
          await ref
              .read(chatDetailProvider(widget.roomId).notifier)
              .deleteMessage(message.id);

          if (context.mounted) {
            CustomSnackbar.show(
              scaffoldContext,
              message: 'Message deleted successfully',
              type: SnackbarType.success,
              duration: const Duration(seconds: 2),
            );
          }
        } catch (e) {
          if (context.mounted) {
            CustomSnackbar.show(
              scaffoldContext,
              message: 'Failed to delete message',
              type: SnackbarType.error,
              duration: const Duration(seconds: 2),
            );
          }
        }
      },
    );
  }

  void _showOptionsBottomSheet() {
    ChatOptionsSheet.show(
      context: context,
      onViewProfile: () {
        // TODO: Navigate to profile
      },
      onMuteNotifications: () {
        CustomSnackbar.show(
          context,
          message: 'Notifications muted',
          type: SnackbarType.info,
          duration: const Duration(seconds: 2),
        );
      },
      onBlockUser: _confirmBlockUser,
      onReportUser: _showReportDialog,
    );
  }

  void _confirmBlockUser() {
    PremiumDialog.show(
      context: context,
      icon: Icons.block_outlined,
      iconColor: Colors.white,
      title: 'Block User',
      message:
          'Are you sure you want to block this user? They won\'t be able to message you.',
      confirmText: 'Block',
      confirmColor: Colors.orange,
      onConfirm: () {
        HapticFeedback.mediumImpact();
        CustomSnackbar.show(
          context,
          message: 'User blocked',
          type: SnackbarType.info,
          duration: const Duration(seconds: 2),
        );
      },
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Report User',
          style: appStyle(18, Colors.black, FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Why are you reporting this user?',
              style: appStyle(14, Colors.grey[700]!, FontWeight.w400),
            ),
            const SizedBox(height: 16),
            _buildReportOption('Inappropriate messages'),
            _buildReportOption('Spam or scam'),
            _buildReportOption('Harassment'),
            _buildReportOption('Fake profile'),
            _buildReportOption('Other'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: appStyle(15, Colors.grey[600]!, FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportOption(String reason) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        HapticFeedback.lightImpact();
        CustomSnackbar.show(
          context,
          message: 'Report submitted. We\'ll review it shortly.',
          type: SnackbarType.info,
          duration: const Duration(seconds: 3),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              Icons.report_problem_outlined,
              size: 20,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Text(reason, style: appStyle(15, Colors.black, FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  bool _shouldShowDateSeparator(int index, List messages) {
    if (index == 0) return true; // Always show for first message

    final currentMessage = messages[index];
    final previousMessage = messages[index - 1];

    return DateTimeUtils.shouldShowDateSeparator(
      currentMessage.createdAt,
      previousMessage.createdAt,
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatDetailProvider(widget.roomId));
    final room = chatState.room;
    final currentUser = ref.watch(authProvider).user;

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (chatState.isLoading && room == null) {
      return Scaffold(
        backgroundColor: isDarkMode ? const Color(0xFF1A1625) : Colors.white,
        body: const Center(child: LottieLoadingIndicator()),
      );
    }

    if (chatState.error != null && room == null) {
      return Scaffold(
        backgroundColor: isDarkMode ? const Color(0xFF1A1625) : Colors.white,
        body: Center(
          child: Text(
            chatState.error!,
            style: appStyle(15, Colors.red, FontWeight.w500),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1A1625) : Colors.white,
      appBar: PremiumChatAppBar(
        room: room,
        onBackPressed: () => Navigator.pop(context),
        onOptionsPressed: _showOptionsBottomSheet,
        onProfileTap: () {
          // TODO: Navigate to profile
        },
      ),
      body: Column(
        children: [
          const ConnectivityStatusBanner(showOnlyWhenPoor: true),
          ChatErrorBanner(roomId: widget.roomId),
          if (chatState.isTyping) PremiumTypingIndicator(roomId: widget.roomId),
          Expanded(
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
                HapticFeedback.selectionClick();
              },
              child: chatState.messages.isEmpty
                  ? const PremiumEmptyState()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      physics: const BouncingScrollPhysics(),
                      reverse:
                          false, // Changed to false - newest messages at bottom
                      itemCount:
                          chatState.messages.length +
                          (chatState.isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        // Show loading indicator at the top when loading more
                        if (chatState.isLoadingMore && index == 0) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: LottieLoadingIndicator(),
                            ),
                          );
                        }

                        final messageIndex = chatState.isLoadingMore
                            ? index - 1
                            : index;
                        final message = chatState.messages[messageIndex];
                        final currentUserId = currentUser != null
                            ? int.tryParse(currentUser.id)
                            : null;
                        final isSent =
                            currentUserId != null &&
                            message.sender == currentUserId;

                        // Check if we should show avatar (first message from sender in a group)
                        final showAvatar =
                            messageIndex == chatState.messages.length - 1 ||
                            (messageIndex < chatState.messages.length - 1 &&
                                chatState.messages[messageIndex + 1].sender !=
                                    message.sender);

                        return PremiumMessageBubble(
                          key: ValueKey('message_${message.id}'),
                          message: message,
                          isSent: isSent,
                          showAvatar: showAvatar,
                          avatarUrl: room?.otherParticipant.profilePhoto,
                          senderName: room?.otherParticipant.displayName,
                          onLongPress: () =>
                              _showMessageOptions(message, isSent),
                          showDateSeparator: _shouldShowDateSeparator(
                            messageIndex,
                            chatState.messages,
                          ),
                        );
                      },
                    ),
            ),
          ),
          PremiumMessageInput(
            controller: _messageController,
            focusNode: _focusNode,
            onSend: _sendMessage,
            roomId: widget.roomId,
            editingMessageId: _editingMessageId,
            editingOriginalContent: _editingOriginalContent,
            onCancelEditing: _cancelEditing,
          ),
        ],
      ),
    );
  }
}
