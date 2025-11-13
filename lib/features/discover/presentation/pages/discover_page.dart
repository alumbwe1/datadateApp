import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '3 Likes',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 20),
            Container(width: 2, height: 20, color: Colors.grey[300]),
            const SizedBox(width: 20),
            const Text(
              'Top Picks',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
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
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Featured profiles of the day,\npicked just for you',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _topPicks.length,
              itemBuilder: (context, index) {
                final pick = _topPicks[index];
                return _buildProfileCard(context, pick);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, Map<String, dynamic> pick) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(imageUrl: pick['image'], fit: BoxFit.cover),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${pick['name']}, ${pick['age']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (pick['timeLeft'] != null)
                    Text(
                      pick['timeLeft'],
                      style: TextStyle(color: Colors.grey[300], fontSize: 12),
                    ),
                  if (pick['tag'] != null)
                    Text(
                      pick['tag'],
                      style: const TextStyle(
                        color: Color(0xFFFFD700),
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.star,
                  color: Color(0xFF00D9A3),
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final List<Map<String, dynamic>> _topPicks = [
  {
    'name': 'Bekah',
    'age': 20,
    'timeLeft': '20h left',
    'image': 'https://randomuser.me/api/portraits/women/44.jpg',
  },
  {
    'name': 'Fashionista',
    'age': 23,
    'tag': 'Fashionista',
    'image': 'https://randomuser.me/api/portraits/women/65.jpg',
  },
  {
    'name': 'Sabrina',
    'age': 24,
    'image': 'https://randomuser.me/api/portraits/women/68.jpg',
  },
  {
    'name': 'Rachel',
    'age': 22,
    'image': 'https://randomuser.me/api/portraits/women/90.jpg',
  },
  {
    'name': 'Emma',
    'age': 21,
    'image': 'https://randomuser.me/api/portraits/women/32.jpg',
  },
  {
    'name': 'Sophie',
    'age': 25,
    'image': 'https://randomuser.me/api/portraits/women/47.jpg',
  },
];
