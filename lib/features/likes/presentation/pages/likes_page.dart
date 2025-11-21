import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_style.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../providers/likes_provider.dart';

class LikesPage extends ConsumerStatefulWidget {
  const LikesPage({super.key});

  @override
  ConsumerState<LikesPage> createState() => _LikesPageState();
}

class _LikesPageState extends ConsumerState<LikesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load likes when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(likesProvider.notifier).loadAllLikes();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final likesState = ref.watch(likesProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Likes',
          style: appStyle(
            24,
            Colors.black,
            FontWeight.w700,
          ).copyWith(letterSpacing: -0.5),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          labelStyle: appStyle(15, Colors.black, FontWeight.w600),
          unselectedLabelStyle: appStyle(15, Colors.grey, FontWeight.w500),
          indicatorColor: Colors.black,
          indicatorWeight: 3,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Received'),
                  if (likesState.receivedLikes.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${likesState.receivedLikes.length}',
                        style: appStyle(12, Colors.white, FontWeight.w600),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Sent'),
                  if (likesState.sentLikes.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${likesState.sentLikes.length}',
                        style: appStyle(12, Colors.black87, FontWeight.w600),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: likesState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : likesState.error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    likesState.error!,
                    style: appStyle(14, Colors.grey, FontWeight.w500),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(likesProvider.notifier).loadAllLikes();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Retry',
                      style: appStyle(14, Colors.white, FontWeight.w600),
                    ),
                  ),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildLikesList(likesState.receivedLikes, isReceived: true),
                _buildLikesList(likesState.sentLikes, isReceived: false),
              ],
            ),
    );
  }

  Widget _buildLikesList(List likes, {required bool isReceived}) {
    if (likes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  isReceived ? '💝' : '💌',
                  style: const TextStyle(fontSize: 60),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isReceived ? 'No Likes Yet' : 'No Likes Sent',
              style: appStyle(
                24,
                Colors.black,
                FontWeight.w700,
              ).copyWith(letterSpacing: -0.5),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                isReceived
                    ? 'When someone likes you,\nthey\'ll appear here'
                    : 'Start swiping to like profiles\nand find your match',
                style: appStyle(
                  14,
                  Colors.grey[600]!,
                  FontWeight.w400,
                ).copyWith(height: 1.5),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(likesProvider.notifier).loadAllLikes();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: likes.length,
        itemBuilder: (context, index) {
          final like = likes[index];
          final profileInfo = like.profileInfo;

          if (profileInfo == null) {
            return const SizedBox.shrink();
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey[200],
                backgroundImage: profileInfo.profilePhoto != null
                    ? CachedNetworkImageProvider(profileInfo.profilePhoto!)
                    : null,
                child: profileInfo.profilePhoto == null
                    ? Text(
                        profileInfo.displayName[0].toUpperCase(),
                        style: appStyle(20, Colors.black, FontWeight.w600),
                      )
                    : null,
              ),
              title: Text(
                profileInfo.displayName,
                style: appStyle(16, Colors.black, FontWeight.w600),
              ),
              subtitle: Text(
                '@${profileInfo.username}',
                style: appStyle(13, Colors.grey[600]!, FontWeight.w400),
              ),
              trailing: isReceived
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.favorite,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Like Back',
                            style: appStyle(12, Colors.white, FontWeight.w600),
                          ),
                        ],
                      ),
                    )
                  : Icon(Icons.favorite, color: Colors.grey[400], size: 24),
              onTap: () {
                // TODO: Navigate to profile detail
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'View ${profileInfo.displayName}\'s profile',
                      style: appStyle(14, Colors.white, FontWeight.w600),
                    ),
                    backgroundColor: Colors.black,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
