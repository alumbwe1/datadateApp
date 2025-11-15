import 'message_model.dart';

class ChatRoomModel {
  final int id;
  final int participant1;
  final int participant2;
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
      participant1: json['participant1'] as int,
      participant2: json['participant2'] as int,
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
      'participant1': participant1,
      'participant2': participant2,
      'match': matchId,
      'other_participant': otherParticipant.toJson(),
      'last_message': lastMessage?.toJson(),
      'unread_count': unreadCount,
      'created_at': createdAt,
    };
  }
}

class ParticipantInfo {
  final int id;
  final String username;
  final String displayName;
  final String? profilePhoto;
  final bool? isOnline;

  ParticipantInfo({
    required this.id,
    required this.username,
    required this.displayName,
    this.profilePhoto,
    this.isOnline,
  });

  factory ParticipantInfo.fromJson(Map<String, dynamic> json) {
    return ParticipantInfo(
      id: json['id'] as int,
      username: json['username'] as String,
      displayName: json['display_name'] as String,
      profilePhoto: json['profile_photo'] as String?,
      isOnline: json['is_online'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'display_name': displayName,
      'profile_photo': profilePhoto,
      'is_online': isOnline,
    };
  }
}
