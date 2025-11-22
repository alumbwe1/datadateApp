class MessageModel {
  final int id;
  final int room;
  final int sender;
  final SenderInfo? senderInfo;
  final String content;
  final bool isRead;
  final String createdAt;
  final String updatedAt;

  MessageModel({
    required this.id,
    required this.room,
    required this.sender,
    this.senderInfo,
    required this.content,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    // Handle sender field - can be either int, object, or sender_id
    int senderId;
    SenderInfo? senderInfo;

    // Check for sender_id first (used in last_message from chat rooms)
    if (json.containsKey('sender_id')) {
      senderId = json['sender_id'] as int;
      senderInfo = null;
    } else {
      final senderField = json['sender'];
      if (senderField is int) {
        // sender is just an ID
        senderId = senderField;
        senderInfo = json['sender_info'] != null
            ? SenderInfo.fromJson(json['sender_info'] as Map<String, dynamic>)
            : null;
      } else if (senderField is Map<String, dynamic>) {
        // sender is an object with full info
        senderId = senderField['id'] as int;
        senderInfo = SenderInfo.fromJson(senderField);
      } else {
        throw Exception('Invalid sender field type');
      }
    }

    return MessageModel(
      id: json['id'] as int? ?? 0, // Default to 0 for last_message preview
      room: json['room'] as int? ?? 0, // Default to 0 for last_message preview
      sender: senderId,
      senderInfo: senderInfo,
      content: json['content'] as String,
      isRead: json['is_read'] as bool? ?? false, // Default to false
      createdAt: json['created_at'] as String,
      updatedAt:
          json['updated_at'] as String? ??
          json['created_at'] as String, // Fallback to created_at
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room': room,
      'sender': sender,
      'sender_info': senderInfo?.toJson(),
      'content': content,
      'is_read': isRead,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  MessageModel copyWith({
    int? id,
    int? room,
    int? sender,
    SenderInfo? senderInfo,
    String? content,
    bool? isRead,
    String? createdAt,
    String? updatedAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      room: room ?? this.room,
      sender: sender ?? this.sender,
      senderInfo: senderInfo ?? this.senderInfo,
      content: content ?? this.content,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class SenderInfo {
  final int id;
  final String username;
  final String displayName;

  SenderInfo({
    required this.id,
    required this.username,
    required this.displayName,
  });

  factory SenderInfo.fromJson(Map<String, dynamic> json) {
    return SenderInfo(
      id: json['id'] as int,
      username: json['username'] as String,
      displayName: json['display_name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'username': username, 'display_name': displayName};
  }
}
