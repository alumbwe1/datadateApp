import 'message_model.dart';

class ChatRoomModel {
  final int id;
  final ParticipantInfo participant1;
  final ParticipantInfo participant2;
  final int? matchId;
  final ParticipantInfo otherParticipant;
  final MessageModel? lastMessage;
  final int unreadCount;
  final String createdAt;

  ChatRoomModel({
    required this.id,
    required this.participant1,
    required this.participant2,
    this.matchId,
    required this.otherParticipant,
    this.lastMessage,
    required this.unreadCount,
    required this.createdAt,
  });

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomModel(
      id: json['id'] as int,
      participant1: ParticipantInfo.fromJson(
        json['participant1'] as Map<String, dynamic>,
      ),
      participant2: ParticipantInfo.fromJson(
        json['participant2'] as Map<String, dynamic>,
      ),
      matchId: json['match'] as int?,
      otherParticipant: ParticipantInfo.fromJson(
        json['other_participant'] as Map<String, dynamic>,
      ),
      lastMessage: json['last_message'] != null
          ? MessageModel.fromJson(json['last_message'] as Map<String, dynamic>)
          : null,
      unreadCount: json['unread_count'] as int? ?? 0,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participant1': participant1.toJson(),
      'participant2': participant2.toJson(),
      'match': matchId,
      'other_participant': otherParticipant.toJson(),
      'last_message': lastMessage?.toJson(),
      'unread_count': unreadCount,
      'created_at': createdAt,
    };
  }

  ChatRoomModel copyWith({
    int? id,
    ParticipantInfo? participant1,
    ParticipantInfo? participant2,
    int? matchId,
    ParticipantInfo? otherParticipant,
    MessageModel? lastMessage,
    int? unreadCount,
    String? createdAt,
  }) {
    return ChatRoomModel(
      id: id ?? this.id,
      participant1: participant1 ?? this.participant1,
      participant2: participant2 ?? this.participant2,
      matchId: matchId ?? this.matchId,
      otherParticipant: otherParticipant ?? this.otherParticipant,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ParticipantInfo {
  final int id;
  final String username;
  final String displayName;
  final List<String> imageUrls;
  final bool? isOnline;

  ParticipantInfo({
    required this.id,
    required this.username,
    required this.displayName,
    this.imageUrls = const [],
    this.isOnline,
  });

  // Get first image URL or null
  String? get profilePhoto => imageUrls.isNotEmpty ? imageUrls.first : null;

  factory ParticipantInfo.fromJson(Map<String, dynamic> json) {
    return ParticipantInfo(
      id: json['id'] as int,
      username: json['username'] as String,
      displayName: json['display_name'] as String,
      imageUrls: json['imageUrls'] != null
          ? List<String>.from(json['imageUrls'] as List)
          : [],
      isOnline: json['is_online'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'display_name': displayName,
      'imageUrls': imageUrls,
      'is_online': isOnline,
    };
  }
}
