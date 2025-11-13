import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/constants/app_style.dart';

class ChatDetailPage extends StatefulWidget {
  final Map<String, dynamic> match;

  const ChatDetailPage({super.key, required this.match});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _isTyping = false;

  final List<Map<String, dynamic>> _messages = [
    {'text': 'Hey! How are you?', 'isSent': false, 'time': '10:30 AM'},
    {
      'text': 'Hi! I\'m doing great, thanks! How about you?',
      'isSent': true,
      'time': '10:32 AM',
    },
    {
      'text': 'Pretty good! Want to grab coffee sometime?',
      'isSent': false,
      'time': '10:35 AM',
    },
    {
      'text': 'That sounds perfect! When are you free?',
      'isSent': true,
      'time': '10:37 AM',
    },
  ];

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_onTextChanged);

    // Auto-scroll to bottom on keyboard open
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });
  }

  void _onTextChanged() {
    if (_messageController.text.isNotEmpty != _isTyping) {
      setState(() {
        _isTyping = _messageController.text.isNotEmpty;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildDateDivider(),
          Expanded(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                physics: const BouncingScrollPhysics(),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final showAvatar =
                      index == _messages.length - 1 ||
                      _messages[index + 1]['isSent'] != message['isSent'];

                  return TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 300 + (index * 50)),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: Opacity(opacity: value, child: child),
                      );
                    },
                    child: _buildMessageBubble(message, showAvatar),
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

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      surfaceTintColor: Colors.white,
      shadowColor: Colors.black.withOpacity(0.05),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
        onPressed: () => Navigator.pop(context),
        padding: EdgeInsets.zero,
      ),
      title: InkWell(
        onTap: () {
          // Navigate to profile
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Hero(
                    tag: 'avatar_${widget.match['name']}',
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundImage: CachedNetworkImageProvider(
                          widget.match['image'],
                        ),
                      ),
                    ),
                  ),
                  if (widget.match['isOnline'] == true)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.match['name'],
                      style: appStyle(
                        16,
                        Colors.black,
                        FontWeight.w600,
                      ).copyWith(letterSpacing: -0.3),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.match['isOnline'] == true)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF4CAF50),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Active now',
                            style: appStyle(
                              12,
                              const Color(0xFF4CAF50),
                              FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      centerTitle: false,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 4),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(IconlyBold.call, color: Colors.black87, size: 22),
            onPressed: () {
              HapticFeedback.lightImpact();
            },
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black87, size: 22),
            onPressed: () {
              HapticFeedback.lightImpact();
              _showOptionsBottomSheet();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateDivider() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300, width: 0.7),
            borderRadius: BorderRadius.circular(40),
          ),
          child: Text(
            'Today',
            style: appStyle(
              12,
              Colors.grey.shade600,
              FontWeight.w500,
            ).copyWith(letterSpacing: 0.3),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool showAvatar) {
    final isSent = message['isSent'] as bool;

    return Padding(
      padding: EdgeInsets.only(
        bottom: showAvatar ? 16 : 2,
        left: isSent ? 60 : 0,
        right: isSent ? 0 : 60,
      ),
      child: Row(
        mainAxisAlignment: isSent
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isSent) ...[
            AnimatedOpacity(
              opacity: showAvatar ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: showAvatar
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: showAvatar
                    ? CircleAvatar(
                        radius: 16,
                        backgroundImage: CachedNetworkImageProvider(
                          widget.match['image'],
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isSent
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onLongPress: () {
                    HapticFeedback.mediumImpact();
                    _showMessageOptions(message);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: isSent
                          ? const LinearGradient(
                              colors: [Color(0xFF000000), Color(0xFF1a1a1a)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isSent ? null : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: Radius.circular(isSent ? 20 : 4),
                        bottomRight: Radius.circular(isSent ? 4 : 20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSent
                              ? Colors.black.withOpacity(0.15)
                              : Colors.black.withOpacity(0.06),
                          blurRadius: isSent ? 12 : 8,
                          offset: Offset(0, isSent ? 3 : 2),
                        ),
                      ],
                    ),
                    child: Text(
                      message['text'],
                      style: appStyle(
                        15,
                        isSent ? Colors.white : Colors.black87,
                        FontWeight.w400,
                      ).copyWith(height: 1.4, letterSpacing: -0.1),
                    ),
                  ),
                ),
                if (showAvatar) ...[
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      message['time'],
                      style: appStyle(
                        11,
                        Colors.grey.shade500,
                        FontWeight.w500,
                      ).copyWith(letterSpacing: 0.1),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.add, color: Colors.grey[700], size: 26),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _showAttachmentOptions();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 120),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _focusNode.hasFocus
                          ? Colors.grey.shade400
                          : Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _messageController,
                    focusNode: _focusNode,
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    style: appStyle(
                      15,
                      Colors.black87,
                      FontWeight.w400,
                    ).copyWith(height: 1.4),
                    decoration: InputDecoration(
                      hintText: 'Message...',
                      hintStyle: appStyle(
                        15,
                        Colors.grey.shade400,
                        FontWeight.w400,
                      ),
                      filled: false,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              AnimatedScale(
                scale: _isTyping ? 1.0 : 0.8,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    gradient: _isTyping
                        ? const LinearGradient(
                            colors: [Color(0xFF000000), Color(0xFF2a2a2a)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: _isTyping ? null : Colors.grey[300],
                    shape: BoxShape.circle,
                    boxShadow: _isTyping
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: IconButton(
                    icon: Icon(
                      _isTyping ? Icons.arrow_upward_rounded : Iconsax.heart,
                      color: _isTyping ? Colors.white : Colors.grey[600],
                      size: 22,
                    ),
                    onPressed: _isTyping
                        ? () {
                            HapticFeedback.mediumImpact();
                            _sendMessage();
                          }
                        : () {
                            HapticFeedback.lightImpact();
                            _sendQuickReaction();
                          },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'text': _messageController.text.trim(),
        'isSent': true,
        'time': 'Now',
      });
      _messageController.clear();
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _sendQuickReaction() {
    setState(() {
      _messages.add({'text': '❤️', 'isSent': true, 'time': 'Now'});
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,

      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAttachmentOption(
                Icons.image,
                'Photo & Video',
                Colors.purple,
              ),
              _buildAttachmentOption(Icons.camera_alt, 'Camera', Colors.red),
              _buildAttachmentOption(
                Icons.insert_drive_file,
                'Document',
                Colors.blue,
              ),
              _buildAttachmentOption(
                IconlyBold.location,
                'Location',
                Colors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentOption(IconData icon, String label, Color color) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        label,
        style: appStyle(
          15,
          Colors.black87,
          FontWeight.w500,
        ).copyWith(letterSpacing: -0.3),
      ),
      onTap: () {
        Navigator.pop(context);
        HapticFeedback.lightImpact();
      },
    );
  }

  void _showMessageOptions(Map<String, dynamic> message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Copy'),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: message['text']));
                  Navigator.pop(context);
                  HapticFeedback.lightImpact();
                },
              ),
              ListTile(
                leading: const Icon(Icons.reply),
                title: const Text('Reply'),
                onTap: () => Navigator.pop(context),
              ),
              if (message['isSent'])
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () => Navigator.pop(context),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Iconsax.user),
                title: Text(
                  'View Profile',
                  style: appStyle(
                    15,
                    Colors.black87,
                    FontWeight.w500,
                  ).copyWith(letterSpacing: -0.3),
                ),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.notifications_off),
                title: Text(
                  'Mute Notifications',
                  style: appStyle(
                    15,
                    Colors.black87,
                    FontWeight.w500,
                  ).copyWith(letterSpacing: -0.3),
                ),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.block, color: Colors.red),
                title: Text(
                  'Block',
                  style: appStyle(15, Colors.red, FontWeight.w500),
                ),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
