import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class LikesPage extends StatelessWidget {
  const LikesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_fire_department,
              color: Color(0xFFFF6B6B),
              size: 32,
            ),
            SizedBox(width: 4),
            Text(
              'tinder',
              style: TextStyle(
                color: Color(0xFFFF6B6B),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(
              'https://randomuser.me/api/portraits/men/32.jpg',
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search ${_matches.length} matches',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'New matches',
              style: TextStyle(
                color: Color(0xFFFF6B6B),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _newMatches.length,
              itemBuilder: (context, index) {
                final match = _newMatches[index];
                return _buildNewMatchCard(match);
              },
            ),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Messages',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: _matches.length,
              itemBuilder: (context, index) {
                final match = _matches[index];
                return _buildMessageTile(context, match);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewMatchCard(Map<String, dynamic> match) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: match['isSpecial'] == true
                        ? const Color(0xFF00D9A3)
                        : Colors.grey[300]!,
                    width: 3,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: match['image'],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              if (match['likesCount'] != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${match['likesCount']} Likes',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            match['name'],
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageTile(BuildContext context, Map<String, dynamic> match) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: CachedNetworkImageProvider(match['image']),
          ),
          if (match['isOnline'] == true)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: const Color(0xFF00D9A3),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Text(
            match['name'],
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          if (match['isVerified'] == true) ...[
            const SizedBox(width: 4),
            const Icon(Icons.verified, color: Color(0xFF00D9A3), size: 16),
          ],
          if (match['hasBoost'] == true) ...[
            const SizedBox(width: 4),
            const Icon(Icons.bolt, color: Color(0xFFFF6B6B), size: 16),
          ],
        ],
      ),
      subtitle: Text(
        match['lastMessage'],
        style: TextStyle(color: Colors.grey[600], fontSize: 14),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: match['unreadCount'] != null
          ? Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFFFF6B6B),
                shape: BoxShape.circle,
              ),
              child: Text(
                '${match['unreadCount']}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChatDetailPage(match: match)),
        );
      },
    );
  }
}

final List<Map<String, dynamic>> _newMatches = [
  {
    'name': 'Sarah',
    'image': 'https://randomuser.me/api/portraits/women/44.jpg',
    'likesCount': 2,
    'isSpecial': true,
  },
  {
    'name': 'Vaccine',
    'image': 'https://i.imgur.com/8YvQRVZ.png',
    'isSpecial': false,
  },
];

final List<Map<String, dynamic>> _matches = [
  {
    'name': 'Lexa',
    'image': 'https://randomuser.me/api/portraits/women/65.jpg',
    'lastMessage': 'Hi',
    'isVerified': true,
    'hasBoost': true,
    'isOnline': true,
  },
  {
    'name': 'Team Tinder',
    'image': 'https://randomuser.me/api/portraits/women/1.jpg',
    'lastMessage': 'Ready to get vaxed? Add a stick...',
    'isVerified': true,
    'isOnline': false,
  },
  {
    'name': 'Emma',
    'image': 'https://randomuser.me/api/portraits/women/32.jpg',
    'lastMessage': 'See you tonight! 😊',
    'unreadCount': 2,
    'isOnline': true,
  },
  {
    'name': 'Sophie',
    'image': 'https://randomuser.me/api/portraits/women/47.jpg',
    'lastMessage': 'That sounds great!',
    'isOnline': false,
  },
];

// Chat Detail Page
class ChatDetailPage extends StatefulWidget {
  final Map<String, dynamic> match;

  const ChatDetailPage({super.key, required this.match});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: CachedNetworkImageProvider(
                widget.match['image'],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.match['name'],
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.match['isOnline'] == true)
                    const Text(
                      'Active now',
                      style: TextStyle(color: Color(0xFF00D9A3), fontSize: 12),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam_outlined, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.call_outlined, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isSent = message['isSent'] as bool;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isSent
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isSent)
            CircleAvatar(
              radius: 16,
              backgroundImage: CachedNetworkImageProvider(
                widget.match['image'],
              ),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSent ? const Color(0xFFFF6B6B) : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                message['text'],
                style: TextStyle(
                  color: isSent ? Colors.white : Colors.black,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFF6B6B),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: () {
                  if (_messageController.text.isNotEmpty) {
                    setState(() {
                      _messages.add({
                        'text': _messageController.text,
                        'isSent': true,
                        'time': 'Now',
                      });
                      _messageController.clear();
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
