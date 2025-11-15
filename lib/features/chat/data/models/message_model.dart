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
    return MessageModel(
      id: json['id'] as int,
      room: json['room'] as int,
      sender: json['sender'] as int,
      senderInfo: json['sender_info'] != null
          ? SenderInfo.fromJson(json['sender_info'] as Map<String, dynamic>)
          : null,
      content: json['content'] as String,
      isRead: json['is_read'] as bool,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
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
