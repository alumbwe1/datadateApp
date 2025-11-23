import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconly/iconly.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/constants/app_style.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/chat_detail_provider.dart';

class ChatDetailPage extends ConsumerStatefulWidget {
  final int roomId;

  const ChatDetailPage({super.key, required this.roomId});

  @override
  ConsumerState<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends ConsumerState<ChatDetailPage>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_onTextChanged);

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 300), () {
          _scrollToBottom();
        });
      }
    });

    // Load more messages when scrolling to top
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        ref
            .read(chatDetailProvider(widget.roomId).notifier)
            .loadMessages(isLoadMore: true);
      }
    });

    // Explicitly load messages when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🔄 ChatDetailPage opened for room ${widget.roomId}');
      print('🔄 Explicitly calling loadMessages...');
      ref.read(chatDetailProvider(widget.roomId).notifier).loadMessages();
    });
  }

  void _onTextChanged() {
    final newIsTyping = _messageController.text.isNotEmpty;
    if (newIsTyping != _isTyping) {
      setState(() {
        _isTyping = newIsTyping;
      });
      // Send typing indicator
      ref
          .read(chatDetailProvider(widget.roomId).notifier)
          .sendTypingIndicator(newIsTyping);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    print('🔵 _sendMessage called with content: "$content"');

    if (content.isEmpty) {
      print('⚠️ Message content is empty, aborting send');
      return;
    }

    print('📤 Sending message to room ${widget.roomId}');
    ref.read(chatDetailProvider(widget.roomId).notifier).sendMessage(content);
    _messageController.clear();
    _scrollToBottom();
    HapticFeedback.lightImpact();
    print('✅ Message send initiated');
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatDetailProvider(widget.roomId));
    final room = chatState.room;
    final currentUser = ref.watch(authProvider).user;

    if (chatState.isLoading && room == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
          ),
        ),
      );
    }

    if (chatState.error != null && room == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Text(
            chatState.error!,
            style: appStyle(15, Colors.red, FontWeight.w500),
          ),
        ),
      );
    }

    // Get current user ID as int
    final currentUserId = currentUser != null
        ? int.tryParse(currentUser.id)
        : null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(room),
      body: Column(
        children: [
          if (chatState.isTyping) _buildTypingIndicator(),
          Expanded(
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
                HapticFeedback.selectionClick();
              },
              child: chatState.messages.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      physics: const BouncingScrollPhysics(),
                      reverse: true,
                      itemCount:
                          chatState.messages.length +
                          (chatState.isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == chatState.messages.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.black,
                                ),
                              ),
                            ),
                          );
                        }

                        final message = chatState.messages[index];
                        // Check if message is sent by current user
                        final isSent =
                            currentUserId != null &&
                            message.sender == currentUserId;
                        final showAvatar =
                            index == 0 ||
                            chatState.messages[index - 1].sender !=
                                message.sender;

                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                          builder: (context, value, child) {
                            return Opacity(opacity: value, child: child);
                          },
                          child: _buildMessageBubble(
                            message,
                            isSent,
                            showAvatar,
                            room,
                          ),
                        );
                      },
                    ),
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(room) {
    final otherUser = room?.otherParticipant;
    final imageUrl = otherUser?.profilePhoto;
    final isOnline = otherUser?.isOnline ?? false;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.white,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      leadingWidth: 56,
      leading: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, size: 22, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
            HapticFeedback.lightImpact();
          },
        ),
      ),
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isOnline ? Colors.black : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            child: ClipOval(
              child: imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Container(color: Colors.grey[100]),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[100],
                        child: Center(
                          child: Text(
                            otherUser?.displayName[0].toUpperCase() ?? '?',
                            style: appStyle(
                              16,
                              Colors.grey[700]!,
                              FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey[100],
                      child: Center(
                        child: Text(
                          otherUser?.displayName[0].toUpperCase() ?? '?',
                          style: appStyle(
                            16,
                            Colors.grey[700]!,
                            FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  otherUser?.displayName ?? 'Chat',
                  style: appStyle(
                    16,
                    Colors.black,
                    FontWeight.w600,
                  ).copyWith(letterSpacing: -0.2),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (isOnline)
                  Text(
                    'Active now',
                    style: appStyle(12, Colors.grey[600]!, FontWeight.w400),
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_horiz, size: 24, color: Colors.black),
          onPressed: () {
            HapticFeedback.lightImpact();
            _showOptionsBottomSheet();
          },
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[100]!, width: 1)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            height: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(3, (index) {
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(
                        0,
                        -3 * (value > 0.5 ? 1 - value : value) * 2,
                      ),
                      child: child,
                    );
                  },
                  onEnd: () {
                    if (mounted) setState(() {});
                  },
                  child: Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(message, bool isSent, bool showAvatar, room) {
    final imageUrl = room?.otherParticipant?.profilePhoto;

    return Padding(
      padding: EdgeInsets.only(
        bottom: 2,
        left: isSent ? 80 : 0,
        right: isSent ? 0 : 80,
      ),
      child: Row(
        mainAxisAlignment: isSent
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isSent && showAvatar)
            Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(right: 8, bottom: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
              child: ClipOval(
                child: imageUrl != null
                    ? CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover)
                    : Container(
                        color: Colors.grey[100],
                        child: Center(
                          child: Text(
                            room?.otherParticipant?.displayName[0]
                                    .toUpperCase() ??
                                '?',
                            style: appStyle(
                              12,
                              Colors.grey[700]!,
                              FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
              ),
            )
          else if (!isSent)
            const SizedBox(width: 36),
          Flexible(
            child: GestureDetector(
              onLongPress: () {
                HapticFeedback.mediumImpact();
                _showMessageOptions(message, isSent);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                margin: const EdgeInsets.only(bottom: 2),
                decoration: BoxDecoration(
                  color: isSent ? Colors.black : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: isSent
                      ? null
                      : Border.all(color: Colors.grey[200]!, width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.content,
                      style: appStyle(
                        15,
                        isSent ? Colors.white : Colors.black,
                        FontWeight.w400,
                      ).copyWith(height: 1.35, letterSpacing: -0.1),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          timeago.format(
                            DateTime.parse(message.createdAt),
                            locale: 'en_short',
                          ),
                          style: appStyle(
                            11,
                            isSent
                                ? Colors.white.withValues(alpha: 0.6)
                                : Colors.grey[600]!,
                            FontWeight.w400,
                          ),
                        ),
                        if (isSent) ...[
                          const SizedBox(width: 4),
                          Icon(
                            message.isRead ? Icons.done_all : Icons.check,
                            size: 14,
                            color: message.isRead
                                ? Colors.blue[400]
                                : Colors.white.withValues(alpha: 0.6),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMessageOptions(message, bool isSent) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.copy, color: Colors.black87),
                title: Text(
                  'Copy',
                  style: appStyle(15, Colors.black, FontWeight.w500),
                ),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: message.content));
                  Navigator.pop(context);
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Message copied',
                        style: appStyle(14, Colors.white, FontWeight.w600),
                      ),
                      backgroundColor: Colors.black,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
              ),
              if (isSent) ...[
                Divider(height: 1, color: Colors.grey[200]),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: Text(
                    'Delete',
                    style: appStyle(15, Colors.red, FontWeight.w500),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmDeleteMessage(message);
                  },
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteMessage(message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Message',
          style: appStyle(18, Colors.black, FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to delete this message?',
          style: appStyle(14, Colors.grey[700]!, FontWeight.w400),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: appStyle(15, Colors.grey[600]!, FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement delete message API call
              Navigator.pop(context);
              HapticFeedback.mediumImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Message deleted',
                    style: appStyle(14, Colors.white, FontWeight.w600),
                  ),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            child: Text(
              'Delete',
              style: appStyle(15, Colors.red, FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!, width: 0.5)),
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                constraints: const BoxConstraints(minHeight: 40),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.grey[300]!, width: 1),
                ),
                child: TextField(
                  controller: _messageController,
                  focusNode: _focusNode,
                  maxLines: 5,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Message...',
                    hintStyle: appStyle(15, Colors.grey[500]!, FontWeight.w400),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: appStyle(15, Colors.black, FontWeight.w400),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _isTyping ? _sendMessage : null,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _isTyping ? Colors.black : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    IconlyBold.send,
                    color: _isTyping ? Colors.white : Colors.grey[400],
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[200]!, width: 1),
              ),
              child: const Center(
                child: Text('💬', style: TextStyle(fontSize: 40)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No messages yet',
              style: appStyle(20, Colors.black, FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Send a message to start the conversation',
              style: appStyle(14, Colors.grey[600]!, FontWeight.w400),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 4,
                ),
                leading: Icon(
                  Icons.block_outlined,
                  color: Colors.grey[800],
                  size: 24,
                ),
                title: Text(
                  'Block',
                  style: appStyle(16, Colors.black, FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(context);
                  HapticFeedback.lightImpact();
                },
              ),
              Divider(height: 1, color: Colors.grey[200]),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 4,
                ),
                leading: Icon(
                  Icons.report_outlined,
                  color: Colors.grey[800],
                  size: 24,
                ),
                title: Text(
                  'Report',
                  style: appStyle(16, Colors.black, FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(context);
                  HapticFeedback.lightImpact();
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
