import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconly/iconly.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/constants/app_style.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/chat_detail_provider.dart';

class ChatDetailPage extends ConsumerStatefulWidget {
  final int roomId;

  const ChatDetailPage({super.key, required this.roomId});

  @override
  ConsumerState<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends ConsumerState<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _isTyping = false;
  int? _editingMessageId;
  String? _editingOriginalContent;

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
    if (!mounted) return;
    final newIsTyping = _messageController.text.isNotEmpty;
    if (newIsTyping != _isTyping) {
      setState(() {
        _isTyping = newIsTyping;
      });
      // Send typing indicator only if not editing
      if (_editingMessageId == null) {
        ref
            .read(chatDetailProvider(widget.roomId).notifier)
            .sendTypingIndicator(newIsTyping);
      }
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

  void _sendMessage() async {
    final content = _messageController.text.trim();

    if (content.isEmpty) {
      return;
    }

    if (_editingMessageId != null) {
      // Update existing message
      try {
        await ref
            .read(chatDetailProvider(widget.roomId).notifier)
            .editMessage(_editingMessageId!, content);

        _cancelEditing();
        HapticFeedback.lightImpact();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'Message updated',
                    style: appStyle(14, Colors.white, FontWeight.w600),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'Failed to update message',
                    style: appStyle(14, Colors.white, FontWeight.w600),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    } else {
      // Send new message
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

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
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

                        return _buildMessageBubble(
                          message,
                          isSent,
                          showAvatar,
                          room,
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
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
            HapticFeedback.lightImpact();
          },
        ),
      ),
      title: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          // TODO: Navigate to profile
        },
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade200, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
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
                                  otherUser?.displayName[0].toUpperCase() ??
                                      '?',
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
                if (isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    otherUser?.displayName ?? 'Chat',
                    style: appStyle(
                      17,
                      Colors.black,
                      FontWeight.w700,
                    ).copyWith(letterSpacing: -0.3),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (isOnline)
                    Text(
                      'Active now',
                      style: appStyle(12, Colors.green, FontWeight.w600),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.more_horiz, size: 20, color: Colors.black),
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            _showOptionsBottomSheet();
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildTypingIndicator() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200],
            ),
            child: Center(
              child: Icon(Icons.more_horiz, size: 16, color: Colors.grey[600]),
            ),
          ),
          Text(
            'typing',
            style: appStyle(
              13,
              Colors.grey[600]!,
              FontWeight.w500,
            ).copyWith(fontStyle: FontStyle.italic),
          ),
          const SizedBox(width: 4),
          _buildTypingDots(),
        ],
      ),
    );
  }

  Widget _buildTypingDots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return TweenAnimationBuilder<double>(
          key: ValueKey('dot_$index'),
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 600 + (index * 100)),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: 0.3 + (0.7 * (value > 0.5 ? 1 - value : value) * 2),
              child: child,
            );
          },
          onEnd: () {
            if (mounted) setState(() {});
          },
          child: Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.only(right: 3),
            decoration: BoxDecoration(
              color: Colors.grey[600],
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMessageBubble(message, bool isSent, bool showAvatar, room) {
    final imageUrl = room?.otherParticipant?.profilePhoto;

    return Padding(
      padding: EdgeInsets.only(
        bottom: showAvatar ? 12 : 2,
        left: isSent ? 60 : 0,
        right: isSent ? 0 : 60,
      ),
      child: Row(
        mainAxisAlignment: isSent
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isSent && showAvatar)
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8, bottom: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
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
                              room?.otherParticipant?.displayName[0]
                                      .toUpperCase() ??
                                  '?',
                              style: appStyle(
                                14,
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
                            room?.otherParticipant?.displayName[0]
                                    .toUpperCase() ??
                                '?',
                            style: appStyle(
                              14,
                              Colors.grey[700]!,
                              FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
              ),
            )
          else if (!isSent)
            const SizedBox(width: 40),
          Flexible(
            child: GestureDetector(
              onLongPress: () {
                HapticFeedback.mediumImpact();
                _showMessageOptions(message, isSent);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                margin: const EdgeInsets.only(bottom: 2),
                decoration: BoxDecoration(
                  color: isSent ? Colors.black : Colors.grey[100],
                  borderRadius: BorderRadius.only(
                    bottomLeft: const Radius.circular(18),
                    bottomRight: const Radius.circular(18),
                    topLeft: isSent
                        ? const Radius.circular(18)
                        : const Radius.circular(4),
                    topRight: isSent
                        ? const Radius.circular(4)
                        : const Radius.circular(18),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.content,
                      style: appStyle(
                        15,
                        isSent ? Colors.white : Colors.black87,
                        FontWeight.w400,
                      ).copyWith(height: 1.4, letterSpacing: -0.15),
                    ),
                    const SizedBox(height: 4),
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
                                ? Colors.white.withValues(alpha: 0.65)
                                : Colors.grey[500]!,
                            FontWeight.w500,
                          ),
                        ),
                        if (isSent) ...[
                          const SizedBox(width: 5),
                          Icon(
                            message.isRead ? Icons.done_all : Icons.check,
                            size: 15,
                            color: message.isRead
                                ? Colors.blue[300]
                                : Colors.white.withValues(alpha: 0.65),
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
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.copy, color: Colors.blue, size: 20),
                ),
                title: Text(
                  'Copy Message',
                  style: appStyle(15, Colors.black, FontWeight.w600),
                ),
                onTap: () {
                  final currentContext = context;
                  Clipboard.setData(ClipboardData(text: message.content));
                  Navigator.pop(context);
                  HapticFeedback.lightImpact();

                  CustomSnackbar.show(
                    currentContext,
                    message: 'Message copied to clipboard',
                    type: SnackbarType.info,
                    duration: const Duration(seconds: 2),
                  );
                },
              ),
              if (isSent) ...[
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.edit_outlined,
                      color: Colors.orange,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    'Edit Message',
                    style: appStyle(15, Colors.black, FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _startEditing(message);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    'Delete Message',
                    style: appStyle(15, Colors.red, FontWeight.w600),
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
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Delete Message',
              style: appStyle(18, Colors.black, FontWeight.w700),
            ),
          ],
        ),
        content: Text(
          'This message will be permanently deleted. This action cannot be undone.',
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
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              HapticFeedback.mediumImpact();

              try {
                await ref
                    .read(chatDetailProvider(widget.roomId).notifier)
                    .deleteMessage(message.id);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Message deleted',
                            style: appStyle(14, Colors.white, FontWeight.w600),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(
                            Icons.error,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Failed to delete message',
                            style: appStyle(14, Colors.white, FontWeight.w600),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Delete',
              style: appStyle(15, Colors.white, FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_editingMessageId != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18, color: Colors.orange[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Editing message',
                            style: appStyle(
                              12,
                              Colors.orange[700]!,
                              FontWeight.w600,
                            ),
                          ),
                          Text(
                            _editingOriginalContent ?? '',
                            style: appStyle(
                              13,
                              Colors.grey[700]!,
                              FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        size: 20,
                        color: Colors.grey[600],
                      ),
                      onPressed: _cancelEditing,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 44),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: _editingMessageId != null
                            ? Colors.orange.withValues(alpha: 0.5)
                            : _focusNode.hasFocus
                            ? Colors.grey[400]!
                            : Colors.grey[200]!,
                        width: 1.5,
                      ),
                    ),
                    child: TextField(
                      controller: _messageController,
                      focusNode: _focusNode,
                      maxLines: 5,
                      minLines: 1,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: _editingMessageId != null
                            ? 'Edit your message...'
                            : 'Type a message...',
                        hintStyle: appStyle(
                          15,
                          Colors.grey[500]!,
                          FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: appStyle(
                        15,
                        Colors.black,
                        FontWeight.w400,
                      ).copyWith(height: 1.4),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                AnimatedScale(
                  scale: _isTyping ? 1.0 : 0.9,
                  duration: const Duration(milliseconds: 150),
                  child: GestureDetector(
                    onTap: _isTyping ? _sendMessage : null,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _isTyping
                            ? (_editingMessageId != null
                                  ? Colors.orange
                                  : Colors.black)
                            : Colors.grey[300],
                        shape: BoxShape.circle,
                        boxShadow: _isTyping
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Icon(
                          _editingMessageId != null
                              ? Icons.check
                              : IconlyBold.send,
                          color: _isTyping ? Colors.white : Colors.grey[500],
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
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
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[200]!, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text('💬', style: TextStyle(fontSize: 48)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No messages yet',
              style: appStyle(
                22,
                Colors.black,
                FontWeight.w700,
              ).copyWith(letterSpacing: -0.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Send a message to start\nthe conversation',
              style: appStyle(
                15,
                Colors.grey[600]!,
                FontWeight.w400,
              ).copyWith(height: 1.5),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 4,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: Colors.blue,
                    size: 22,
                  ),
                ),
                title: Text(
                  'View Profile',
                  style: appStyle(16, Colors.black, FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(context);
                  HapticFeedback.lightImpact();
                  // TODO: Navigate to profile
                },
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 4,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.notifications_off_outlined,
                    color: Colors.purple,
                    size: 22,
                  ),
                ),
                title: Text(
                  'Mute Notifications',
                  style: appStyle(16, Colors.black, FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(context);
                  HapticFeedback.lightImpact();
                },
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 4,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.block_outlined,
                    color: Colors.orange,
                    size: 22,
                  ),
                ),
                title: Text(
                  'Block User',
                  style: appStyle(16, Colors.black, FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(context);
                  HapticFeedback.lightImpact();
                  _confirmBlockUser();
                },
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 4,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.report_outlined,
                    color: Colors.red,
                    size: 22,
                  ),
                ),
                title: Text(
                  'Report User',
                  style: appStyle(16, Colors.red, FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(context);
                  HapticFeedback.lightImpact();
                  _showReportDialog();
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmBlockUser() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Block User',
          style: appStyle(18, Colors.black, FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to block this user? They won\'t be able to message you.',
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
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              HapticFeedback.mediumImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'User blocked',
                    style: appStyle(14, Colors.white, FontWeight.w600),
                  ),
                  backgroundColor: Colors.orange,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Block',
              style: appStyle(15, Colors.white, FontWeight.w700),
            ),
          ),
        ],
      ),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Report submitted. We\'ll review it shortly.',
              style: appStyle(14, Colors.white, FontWeight.w600),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
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
}
