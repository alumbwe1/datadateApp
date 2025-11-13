import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconly/iconly.dart';
import '../../../../core/constants/app_style.dart';
import 'chat_detail_page.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: Text(
          'Messages',
          style: appStyle(
            26,
            Colors.black,
            FontWeight.w800,
          ).copyWith(letterSpacing: -0.5),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Hero(
            tag: 'user_avatar',
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.tune_rounded,
                size: 22,
                color: Colors.black87,
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
              },
            ),
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
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isSearching ? Colors.black : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: TextField(
                controller: _searchController,
                onTap: () {
                  setState(() => _isSearching = true);
                  HapticFeedback.selectionClick();
                },
                onChanged: (value) {
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: 'Search conversations',
                  hintStyle: appStyle(
                    15,
                    Colors.grey.shade400,
                    FontWeight.w400,
                  ).copyWith(letterSpacing: -0.2),
                  prefixIcon: Icon(
                    IconlyLight.search,
                    color: _isSearching ? Colors.black : Colors.grey[400],
                    size: 22,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                            HapticFeedback.lightImpact();
                          },
                        )
                      : null,
                  filled: false,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF000000), Color(0xFF2a2a2a)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.favorite,
                    size: 15,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'New Matches',
                  style: appStyle(
                    17,
                    Colors.black,
                    FontWeight.w700,
                  ).copyWith(letterSpacing: -0.4),
                ),
                const Spacer(),
                Text(
                  '${_newMatches.length}',
                  style: appStyle(14, Colors.grey.shade500, FontWeight.w600),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              itemCount: _newMatches.length,
              itemBuilder: (context, index) {
                return FadeTransition(
                  opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: Interval(index * 0.1, 1.0, curve: Curves.easeOut),
                    ),
                  ),
                  child: _buildNewMatchCard(_newMatches[index]),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Row(
              children: [
                Text(
                  'Messages',
                  style: appStyle(
                    17,
                    Colors.black,
                    FontWeight.w700,
                  ).copyWith(letterSpacing: -0.4),
                ),
                const Spacer(),
                Text(
                  '${_matches.length}',
                  style: appStyle(14, Colors.grey.shade500, FontWeight.w600),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: _matches.length,
                itemBuilder: (context, index) {
                  return FadeTransition(
                    opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: Interval(
                          0.3 + (index * 0.05),
                          1.0,
                          curve: Curves.easeOut,
                        ),
                      ),
                    ),
                    child: _buildMessageTile(context, _matches[index], index),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewMatchCard(Map<String, dynamic> match) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChatDetailPage(match: match)),
        );
      },
      child: Container(
        width: 90,
        margin: const EdgeInsets.only(right: 16, bottom: 8),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: match['isSpecial'] == true
                        ? const LinearGradient(
                            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    border: Border.all(
                      color: match['isSpecial'] == true
                          ? Colors.transparent
                          : Colors.grey.shade300,
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: match['isSpecial'] == true
                            ? const Color(0xFF667eea).withValues(alpha: 0.3)
                            : Colors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: match['image'],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                if (match['likesCount'] != null)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF000000), Color(0xFF2a2a2a)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '${match['likesCount']}',
                        style: appStyle(11, Colors.white, FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              match['name'],
              style: appStyle(
                13,
                Colors.black87,
                FontWeight.w600,
              ).copyWith(letterSpacing: -0.2),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageTile(
    BuildContext context,
    Map<String, dynamic> match,
    int index,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  ChatDetailPage(match: match),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOutCubic;
                    var tween = Tween(
                      begin: begin,
                      end: end,
                    ).chain(CurveTween(curve: curve));
                    return SlideTransition(
                      position: animation.drive(tween),
                      child: child,
                    );
                  },
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Stack(
                children: [
                  Hero(
                    tag: 'avatar_${match['name']}',
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundImage: CachedNetworkImageProvider(
                          match['image'],
                        ),
                      ),
                    ),
                  ),
                  if (match['isOnline'] == true)
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                        if (match['isVerified'] == true) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified,
                            color: Color(0xFF2196F3),
                            size: 18,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      match['lastMessage'],
                      style: appStyle(
                        14,
                        match['unreadCount'] != null
                            ? Colors.black87
                            : Colors.grey.shade600,
                        match['unreadCount'] != null
                            ? FontWeight.w500
                            : FontWeight.w400,
                      ).copyWith(letterSpacing: -0.2),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (match['unreadCount'] != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF000000), Color(0xFF2a2a2a)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '${match['unreadCount']}',
                        style: appStyle(
                          12,
                          Colors.white,
                          FontWeight.bold,
                        ).copyWith(letterSpacing: -0.2),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
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
