// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'crush_message_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CrushMessageModel _$CrushMessageModelFromJson(Map<String, dynamic> json) {
  return _CrushMessageModel.fromJson(json);
}

/// @nodoc
mixin _$CrushMessageModel {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'sender_id')
  int get senderId => throw _privateConstructorUsedError;
  @JsonKey(name: 'sender_username')
  String get senderUsername => throw _privateConstructorUsedError;
  @JsonKey(name: 'receiver_id')
  int get receiverId => throw _privateConstructorUsedError;
  @JsonKey(name: 'receiver_username')
  String get receiverUsername => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'read_at')
  DateTime? get readAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'responded_at')
  DateTime? get respondedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this CrushMessageModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CrushMessageModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CrushMessageModelCopyWith<CrushMessageModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CrushMessageModelCopyWith<$Res> {
  factory $CrushMessageModelCopyWith(
    CrushMessageModel value,
    $Res Function(CrushMessageModel) then,
  ) = _$CrushMessageModelCopyWithImpl<$Res, CrushMessageModel>;
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'sender_id') int senderId,
    @JsonKey(name: 'sender_username') String senderUsername,
    @JsonKey(name: 'receiver_id') int receiverId,
    @JsonKey(name: 'receiver_username') String receiverUsername,
    String message,
    String status,
    @JsonKey(name: 'read_at') DateTime? readAt,
    @JsonKey(name: 'responded_at') DateTime? respondedAt,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class _$CrushMessageModelCopyWithImpl<$Res, $Val extends CrushMessageModel>
    implements $CrushMessageModelCopyWith<$Res> {
  _$CrushMessageModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CrushMessageModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? senderId = null,
    Object? senderUsername = null,
    Object? receiverId = null,
    Object? receiverUsername = null,
    Object? message = null,
    Object? status = null,
    Object? readAt = freezed,
    Object? respondedAt = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            senderId: null == senderId
                ? _value.senderId
                : senderId // ignore: cast_nullable_to_non_nullable
                      as int,
            senderUsername: null == senderUsername
                ? _value.senderUsername
                : senderUsername // ignore: cast_nullable_to_non_nullable
                      as String,
            receiverId: null == receiverId
                ? _value.receiverId
                : receiverId // ignore: cast_nullable_to_non_nullable
                      as int,
            receiverUsername: null == receiverUsername
                ? _value.receiverUsername
                : receiverUsername // ignore: cast_nullable_to_non_nullable
                      as String,
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            readAt: freezed == readAt
                ? _value.readAt
                : readAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            respondedAt: freezed == respondedAt
                ? _value.respondedAt
                : respondedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CrushMessageModelImplCopyWith<$Res>
    implements $CrushMessageModelCopyWith<$Res> {
  factory _$$CrushMessageModelImplCopyWith(
    _$CrushMessageModelImpl value,
    $Res Function(_$CrushMessageModelImpl) then,
  ) = __$$CrushMessageModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'sender_id') int senderId,
    @JsonKey(name: 'sender_username') String senderUsername,
    @JsonKey(name: 'receiver_id') int receiverId,
    @JsonKey(name: 'receiver_username') String receiverUsername,
    String message,
    String status,
    @JsonKey(name: 'read_at') DateTime? readAt,
    @JsonKey(name: 'responded_at') DateTime? respondedAt,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class __$$CrushMessageModelImplCopyWithImpl<$Res>
    extends _$CrushMessageModelCopyWithImpl<$Res, _$CrushMessageModelImpl>
    implements _$$CrushMessageModelImplCopyWith<$Res> {
  __$$CrushMessageModelImplCopyWithImpl(
    _$CrushMessageModelImpl _value,
    $Res Function(_$CrushMessageModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CrushMessageModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? senderId = null,
    Object? senderUsername = null,
    Object? receiverId = null,
    Object? receiverUsername = null,
    Object? message = null,
    Object? status = null,
    Object? readAt = freezed,
    Object? respondedAt = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$CrushMessageModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        senderId: null == senderId
            ? _value.senderId
            : senderId // ignore: cast_nullable_to_non_nullable
                  as int,
        senderUsername: null == senderUsername
            ? _value.senderUsername
            : senderUsername // ignore: cast_nullable_to_non_nullable
                  as String,
        receiverId: null == receiverId
            ? _value.receiverId
            : receiverId // ignore: cast_nullable_to_non_nullable
                  as int,
        receiverUsername: null == receiverUsername
            ? _value.receiverUsername
            : receiverUsername // ignore: cast_nullable_to_non_nullable
                  as String,
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        readAt: freezed == readAt
            ? _value.readAt
            : readAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        respondedAt: freezed == respondedAt
            ? _value.respondedAt
            : respondedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CrushMessageModelImpl implements _CrushMessageModel {
  const _$CrushMessageModelImpl({
    required this.id,
    @JsonKey(name: 'sender_id') required this.senderId,
    @JsonKey(name: 'sender_username') required this.senderUsername,
    @JsonKey(name: 'receiver_id') required this.receiverId,
    @JsonKey(name: 'receiver_username') required this.receiverUsername,
    required this.message,
    required this.status,
    @JsonKey(name: 'read_at') this.readAt,
    @JsonKey(name: 'responded_at') this.respondedAt,
    @JsonKey(name: 'created_at') required this.createdAt,
  });

  factory _$CrushMessageModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CrushMessageModelImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'sender_id')
  final int senderId;
  @override
  @JsonKey(name: 'sender_username')
  final String senderUsername;
  @override
  @JsonKey(name: 'receiver_id')
  final int receiverId;
  @override
  @JsonKey(name: 'receiver_username')
  final String receiverUsername;
  @override
  final String message;
  @override
  final String status;
  @override
  @JsonKey(name: 'read_at')
  final DateTime? readAt;
  @override
  @JsonKey(name: 'responded_at')
  final DateTime? respondedAt;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'CrushMessageModel(id: $id, senderId: $senderId, senderUsername: $senderUsername, receiverId: $receiverId, receiverUsername: $receiverUsername, message: $message, status: $status, readAt: $readAt, respondedAt: $respondedAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CrushMessageModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.senderUsername, senderUsername) ||
                other.senderUsername == senderUsername) &&
            (identical(other.receiverId, receiverId) ||
                other.receiverId == receiverId) &&
            (identical(other.receiverUsername, receiverUsername) ||
                other.receiverUsername == receiverUsername) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.readAt, readAt) || other.readAt == readAt) &&
            (identical(other.respondedAt, respondedAt) ||
                other.respondedAt == respondedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    senderId,
    senderUsername,
    receiverId,
    receiverUsername,
    message,
    status,
    readAt,
    respondedAt,
    createdAt,
  );

  /// Create a copy of CrushMessageModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CrushMessageModelImplCopyWith<_$CrushMessageModelImpl> get copyWith =>
      __$$CrushMessageModelImplCopyWithImpl<_$CrushMessageModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CrushMessageModelImplToJson(this);
  }
}

abstract class _CrushMessageModel implements CrushMessageModel {
  const factory _CrushMessageModel({
    required final int id,
    @JsonKey(name: 'sender_id') required final int senderId,
    @JsonKey(name: 'sender_username') required final String senderUsername,
    @JsonKey(name: 'receiver_id') required final int receiverId,
    @JsonKey(name: 'receiver_username') required final String receiverUsername,
    required final String message,
    required final String status,
    @JsonKey(name: 'read_at') final DateTime? readAt,
    @JsonKey(name: 'responded_at') final DateTime? respondedAt,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
  }) = _$CrushMessageModelImpl;

  factory _CrushMessageModel.fromJson(Map<String, dynamic> json) =
      _$CrushMessageModelImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'sender_id')
  int get senderId;
  @override
  @JsonKey(name: 'sender_username')
  String get senderUsername;
  @override
  @JsonKey(name: 'receiver_id')
  int get receiverId;
  @override
  @JsonKey(name: 'receiver_username')
  String get receiverUsername;
  @override
  String get message;
  @override
  String get status;
  @override
  @JsonKey(name: 'read_at')
  DateTime? get readAt;
  @override
  @JsonKey(name: 'responded_at')
  DateTime? get respondedAt;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of CrushMessageModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CrushMessageModelImplCopyWith<_$CrushMessageModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
