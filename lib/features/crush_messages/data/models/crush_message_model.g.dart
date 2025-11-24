// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crush_message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CrushMessageModelImpl _$$CrushMessageModelImplFromJson(
  Map<String, dynamic> json,
) => _$CrushMessageModelImpl(
  id: (json['id'] as num).toInt(),
  senderId: (json['sender_id'] as num).toInt(),
  senderUsername: json['sender_username'] as String,
  receiverId: (json['receiver_id'] as num).toInt(),
  receiverUsername: json['receiver_username'] as String,
  message: json['message'] as String,
  status: json['status'] as String,
  readAt: json['read_at'] == null
      ? null
      : DateTime.parse(json['read_at'] as String),
  respondedAt: json['responded_at'] == null
      ? null
      : DateTime.parse(json['responded_at'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$$CrushMessageModelImplToJson(
  _$CrushMessageModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'sender_id': instance.senderId,
  'sender_username': instance.senderUsername,
  'receiver_id': instance.receiverId,
  'receiver_username': instance.receiverUsername,
  'message': instance.message,
  'status': instance.status,
  'read_at': instance.readAt?.toIso8601String(),
  'responded_at': instance.respondedAt?.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
};
