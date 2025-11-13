import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconly/iconly.dart';
import '../../../../core/constants/app_style.dart';
import 'chat_detail_page.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        title: Text(
          'Messages',
          style: appStyle(
            22,
            Colors.black,
            FontWeight.bold,
          ).copyWith(letterSpacing: -0.3),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300, width: 2),
            ),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.tune_rounded,
                size: 20,
                color: Colors.black87,
              ),
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search  conversations',
                hintStyle: appStyle(
                  14,
                  Colors.grey.shade400,
                  FontWeight.w400,
                ).copyWith(letterSpacing: -0.2),
                prefixIcon: Icon(IconlyLight.search, color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'New Matches',
                  style: appStyle(
                    16,
                    Colors.black,
                    FontWeight.w700,
                  ).copyWith(letterSpacing: -0.3),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            height: 130,
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
          const SizedBox(height: 8),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Text(
              'Recent Conversations',
              style: appStyle(
                16,
                Colors.black,
                FontWeight.w700,
              ).copyWith(letterSpacing: -0.3),
            ),
          ),
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
      width: 85,
      margin: const EdgeInsets.only(right: 16, bottom: 8),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 85,
                height: 85,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: match['isSpecial'] == true
                        ? Colors.blue
                        : Colors.grey.shade300,
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: match['image'],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              if (match['likesCount'] != null)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Text(
                      '${match['likesCount']}',
                      style: appStyle(10, Colors.white, FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            match['name'],
            style: appStyle(12, Colors.black87, FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageTile(BuildContext context, Map<String, dynamic> match) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 1),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 28,
                backgroundImage: CachedNetworkImageProvider(match['image']),
              ),
            ),
            if (match['isOnline'] == true)
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                match['name'],
                style: appStyle(
                  16,
                  Colors.black,
                  FontWeight.w600,
                ).copyWith(letterSpacing: -0.3),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (match['isVerified'] == true)
              const Icon(Icons.verified, color: Colors.blue, size: 18),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            match['lastMessage'],
            style: appStyle(
              14,
              Colors.grey.shade600,
              FontWeight.w400,
            ).copyWith(letterSpacing: -0.2),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (match['unreadCount'] != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                child: Text(
                  '${match['unreadCount']}',
                  style: appStyle(
                    11,
                    Colors.white,
                    FontWeight.bold,
                  ).copyWith(letterSpacing: -0.3),
                ),
              ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatDetailPage(match: match),
            ),
          );
        },
      ),
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
    'name': 'Jessica',
    'image': 'https://randomuser.me/api/portraits/women/50.jpg',
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
  {
    'name': 'Olivia',
    'image': 'https://randomuser.me/api/portraits/women/28.jpg',
    'lastMessage': 'What are you up to?',
    'isOnline': true,
  },
];
