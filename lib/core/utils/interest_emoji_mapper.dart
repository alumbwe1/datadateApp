class InterestEmojiMapper {
  static const Map<String, String> _emojiMap = {
    // Hobbies & Activities
    'hiking': '🥾',
    'running': '🏃',
    'cycling': '🚴',
    'swimming': '🏊',
    'yoga': '🧘',
    'gym': '💪',
    'fitness': '💪',
    'dancing': '💃',
    'sports': '⚽',
    'basketball': '🏀',
    'football': '⚽',
    'tennis': '🎾',
    'golf': '⛳',
    'skiing': '⛷️',
    'surfing': '🏄',
    'climbing': '🧗',

    // Food & Drink
    'coffee': '☕',
    'cooking': '🍳',
    'food': '🍕',
    'wine': '🍷',
    'beer': '🍺',
    'baking': '🧁',
    'foodie': '🍽️',
    'vegan': '🥗',
    'vegetarian': '🥗',

    // Arts & Entertainment
    'music': '🎵',
    'guitar': '🎸',
    'piano': '🎹',
    'singing': '🎤',
    'art': '🎨',
    'painting': '🖼️',
    'drawing': '✏️',
    'photography': '📸',
    'movies': '🎬',
    'cinema': '🎬',
    'theater': '🎭',
    'reading': '📚',
    'books': '📖',
    'writing': '✍️',
    'poetry': '📝',

    // Technology
    'coding': '💻',
    'programming': '💻',
    'tech': '💻',
    'ai': '🤖',
    'gaming': '🎮',
    'video games': '🎮',
    'esports': '🎮',

    // Travel & Adventure
    'travel': '✈️',
    'adventure': '🗺️',
    'backpacking': '🎒',
    'camping': '⛺',
    'road trips': '🚗',
    'exploring': '🧭',

    // Nature & Animals
    'nature': '🌿',
    'gardening': '🌱',
    'plants': '🪴',
    'pets': '🐾',
    'dogs': '🐕',
    'cats': '🐈',
    'animals': '🐾',
    'birds': '🐦',
    'wildlife': '🦁',

    // Lifestyle
    'fashion': '👗',
    'shopping': '🛍️',
    'beauty': '💄',
    'meditation': '🧘',
    'mindfulness': '🧘',
    'wellness': '🌟',
    'self-care': '💆',

    // Social & Entertainment
    'parties': '🎉',
    'nightlife': '🌃',
    'concerts': '🎸',
    'festivals': '🎪',
    'karaoke': '🎤',

    // Intellectual
    'science': '🔬',
    'astronomy': '🔭',
    'history': '📜',
    'philosophy': '🤔',
    'learning': '📚',
    'languages': '🗣️',

    // Creative
    'crafts': '🎨',
    'diy': '🔨',
    'knitting': '🧶',
    'sewing': '🪡',
    'pottery': '🏺',

    // Miscellaneous
    'volunteering': '🤝',
    'charity': '❤️',
    'environment': '🌍',
    'sustainability': '♻️',
    'anime': '🎌',
    'manga': '📚',
    'comics': '📚',
    'board games': '🎲',
    'chess': '♟️',
    'puzzles': '🧩',
  };

  /// Get emoji for an interest. Returns a default emoji if not found.
  static String getEmoji(String interest) {
    final normalizedInterest = interest.toLowerCase().trim();
    return _emojiMap[normalizedInterest] ?? '✨';
  }

  /// Get emoji and interest text combined
  static String getEmojiWithText(String interest) {
    return '${getEmoji(interest)} $interest';
  }

  /// Check if an interest has a specific emoji mapping
  static bool hasEmoji(String interest) {
    final normalizedInterest = interest.toLowerCase().trim();
    return _emojiMap.containsKey(normalizedInterest);
  }

  /// Get all available interests with emojis
  static Map<String, String> getAllInterests() {
    return Map.unmodifiable(_emojiMap);
  }
}
