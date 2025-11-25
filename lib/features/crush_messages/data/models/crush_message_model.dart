// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'crush_message_model.freezed.dart';
part 'crush_message_model.g.dart';

@freezed
class CrushMessageModel with _$CrushMessageModel {
  const factory CrushMessageModel({
    required int id,
    required int senderId,
    @JsonKey(name: 'sender_username') required String senderUsername,
    @JsonKey(name: 'receiver_id') required int receiverId,
    @JsonKey(name: 'receiver_username') required String receiverUsername,
    required String message,
    required String status,
    @JsonKey(name: 'read_at') DateTime? readAt,
    @JsonKey(name: 'responded_at') DateTime? respondedAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _CrushMessageModel;

  factory CrushMessageModel.fromJson(Map<String, dynamic> json) =>
      _$CrushMessageModelFromJson(json);
}
