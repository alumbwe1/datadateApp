import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ChatPageShimmer extends StatelessWidget {
  const ChatPageShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search bar shimmer
        _buildSearchShimmer(context),
        // New matches section shimmer
        _buildMatchesSectionShimmer(context),
        // Messages title shimmer
        _buildMessagesTitleShimmer(context),
        // Conversations shimmer
        Expanded(child: _buildConversationsShimmer(context)),
      ],
    );
  }

  Widget _buildSearchShimmer(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDarkMode ? const Color(0xFF1A1625) : Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Shimmer.fromColors(
        baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
        highlightColor: isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[900] : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildMatchesSectionShimmer(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Container(
          color: isDarkMode ? const Color(0xFF1A1625) : Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Row(
            children: [
              Shimmer.fromColors(
                baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                highlightColor: isDarkMode
                    ? Colors.grey[700]!
                    : Colors.grey[100]!,
                child: Container(
                  height: 16,
                  width: 100,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[900] : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              const Spacer(),
              Shimmer.fromColors(
                baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                highlightColor: isDarkMode
                    ? Colors.grey[700]!
                    : Colors.grey[100]!,
                child: Container(
                  height: 24,
                  width: 40,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[900] : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Matches horizontal list
        Container(
          color: isDarkMode ? const Color(0xFF1A1625) : Colors.white,
          height: 135,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            itemBuilder: (context, index) {
              return Container(
                width: 105,
                margin: const EdgeInsets.only(right: 16),
                child: Column(
                  children: [
                    Shimmer.fromColors(
                      baseColor: isDarkMode
                          ? Colors.grey[800]!
                          : Colors.grey[300]!,
                      highlightColor: isDarkMode
                          ? Colors.grey[700]!
                          : Colors.grey[100]!,
                      child: Container(
                        width: 109,
                        height: 109,
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.grey[900] : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Shimmer.fromColors(
                      baseColor: isDarkMode
                          ? Colors.grey[800]!
                          : Colors.grey[300]!,
                      highlightColor: isDarkMode
                          ? Colors.grey[700]!
                          : Colors.grey[100]!,
                      child: Container(
                        height: 14,
                        width: 60,
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.grey[900] : Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildMessagesTitleShimmer(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDarkMode ? const Color(0xFF1A1625) : Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Shimmer.fromColors(
        baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
        highlightColor: isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
        child: Container(
          height: 16,
          width: 80,
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[900] : Colors.white,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }

  Widget _buildConversationsShimmer(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDarkMode ? const Color(0xFF1A1625) : Colors.white,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 8,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
            child: Row(
              children: [
                // Avatar shimmer
                Shimmer.fromColors(
                  baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                  highlightColor: isDarkMode
                      ? Colors.grey[700]!
                      : Colors.grey[100]!,
                  child: Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[900] : Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Content shimmer
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Shimmer.fromColors(
                              baseColor: isDarkMode
                                  ? Colors.grey[800]!
                                  : Colors.grey[300]!,
                              highlightColor: isDarkMode
                                  ? Colors.grey[700]!
                                  : Colors.grey[100]!,
                              child: Container(
                                height: 16,
                                decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? Colors.grey[900]
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Shimmer.fromColors(
                            baseColor: isDarkMode
                                ? Colors.grey[800]!
                                : Colors.grey[300]!,
                            highlightColor: isDarkMode
                                ? Colors.grey[700]!
                                : Colors.grey[100]!,
                            child: Container(
                              height: 24,
                              width: 50,
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? Colors.grey[900]
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Shimmer.fromColors(
                        baseColor: isDarkMode
                            ? Colors.grey[800]!
                            : Colors.grey[300]!,
                        highlightColor: isDarkMode
                            ? Colors.grey[700]!
                            : Colors.grey[100]!,
                        child: Container(
                          height: 14,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isDarkMode ? Colors.grey[900] : Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
