// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'block_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BlockModel _$BlockModelFromJson(Map<String, dynamic> json) {
  return _BlockModel.fromJson(json);
}

/// @nodoc
mixin _$BlockModel {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'blocker_username')
  String get blockerUsername => throw _privateConstructorUsedError;
  @JsonKey(name: 'blocked_username')
  String get blockedUsername => throw _privateConstructorUsedError;
  @JsonKey(name: 'blocked_user_id')
  int get blockedUserId => throw _privateConstructorUsedError;
  String? get reason => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this BlockModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BlockModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BlockModelCopyWith<BlockModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BlockModelCopyWith<$Res> {
  factory $BlockModelCopyWith(
    BlockModel value,
    $Res Function(BlockModel) then,
  ) = _$BlockModelCopyWithImpl<$Res, BlockModel>;
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'blocker_username') String blockerUsername,
    @JsonKey(name: 'blocked_username') String blockedUsername,
    @JsonKey(name: 'blocked_user_id') int blockedUserId,
    String? reason,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class _$BlockModelCopyWithImpl<$Res, $Val extends BlockModel>
    implements $BlockModelCopyWith<$Res> {
  _$BlockModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BlockModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? blockerUsername = null,
    Object? blockedUsername = null,
    Object? blockedUserId = null,
    Object? reason = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            blockerUsername: null == blockerUsername
                ? _value.blockerUsername
                : blockerUsername // ignore: cast_nullable_to_non_nullable
                      as String,
            blockedUsername: null == blockedUsername
                ? _value.blockedUsername
                : blockedUsername // ignore: cast_nullable_to_non_nullable
                      as String,
            blockedUserId: null == blockedUserId
                ? _value.blockedUserId
                : blockedUserId // ignore: cast_nullable_to_non_nullable
                      as int,
            reason: freezed == reason
                ? _value.reason
                : reason // ignore: cast_nullable_to_non_nullable
                      as String?,
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
abstract class _$$BlockModelImplCopyWith<$Res>
    implements $BlockModelCopyWith<$Res> {
  factory _$$BlockModelImplCopyWith(
    _$BlockModelImpl value,
    $Res Function(_$BlockModelImpl) then,
  ) = __$$BlockModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'blocker_username') String blockerUsername,
    @JsonKey(name: 'blocked_username') String blockedUsername,
    @JsonKey(name: 'blocked_user_id') int blockedUserId,
    String? reason,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class __$$BlockModelImplCopyWithImpl<$Res>
    extends _$BlockModelCopyWithImpl<$Res, _$BlockModelImpl>
    implements _$$BlockModelImplCopyWith<$Res> {
  __$$BlockModelImplCopyWithImpl(
    _$BlockModelImpl _value,
    $Res Function(_$BlockModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BlockModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? blockerUsername = null,
    Object? blockedUsername = null,
    Object? blockedUserId = null,
    Object? reason = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$BlockModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        blockerUsername: null == blockerUsername
            ? _value.blockerUsername
            : blockerUsername // ignore: cast_nullable_to_non_nullable
                  as String,
        blockedUsername: null == blockedUsername
            ? _value.blockedUsername
            : blockedUsername // ignore: cast_nullable_to_non_nullable
                  as String,
        blockedUserId: null == blockedUserId
            ? _value.blockedUserId
            : blockedUserId // ignore: cast_nullable_to_non_nullable
                  as int,
        reason: freezed == reason
            ? _value.reason
            : reason // ignore: cast_nullable_to_non_nullable
                  as String?,
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
class _$BlockModelImpl implements _BlockModel {
  const _$BlockModelImpl({
    required this.id,
    @JsonKey(name: 'blocker_username') required this.blockerUsername,
    @JsonKey(name: 'blocked_username') required this.blockedUsername,
    @JsonKey(name: 'blocked_user_id') required this.blockedUserId,
    this.reason,
    @JsonKey(name: 'created_at') required this.createdAt,
  });

  factory _$BlockModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$BlockModelImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'blocker_username')
  final String blockerUsername;
  @override
  @JsonKey(name: 'blocked_username')
  final String blockedUsername;
  @override
  @JsonKey(name: 'blocked_user_id')
  final int blockedUserId;
  @override
  final String? reason;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'BlockModel(id: $id, blockerUsername: $blockerUsername, blockedUsername: $blockedUsername, blockedUserId: $blockedUserId, reason: $reason, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BlockModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.blockerUsername, blockerUsername) ||
                other.blockerUsername == blockerUsername) &&
            (identical(other.blockedUsername, blockedUsername) ||
                other.blockedUsername == blockedUsername) &&
            (identical(other.blockedUserId, blockedUserId) ||
                other.blockedUserId == blockedUserId) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    blockerUsername,
    blockedUsername,
    blockedUserId,
    reason,
    createdAt,
  );

  /// Create a copy of BlockModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BlockModelImplCopyWith<_$BlockModelImpl> get copyWith =>
      __$$BlockModelImplCopyWithImpl<_$BlockModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BlockModelImplToJson(this);
  }
}

abstract class _BlockModel implements BlockModel {
  const factory _BlockModel({
    required final int id,
    @JsonKey(name: 'blocker_username') required final String blockerUsername,
    @JsonKey(name: 'blocked_username') required final String blockedUsername,
    @JsonKey(name: 'blocked_user_id') required final int blockedUserId,
    final String? reason,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
  }) = _$BlockModelImpl;

  factory _BlockModel.fromJson(Map<String, dynamic> json) =
      _$BlockModelImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'blocker_username')
  String get blockerUsername;
  @override
  @JsonKey(name: 'blocked_username')
  String get blockedUsername;
  @override
  @JsonKey(name: 'blocked_user_id')
  int get blockedUserId;
  @override
  String? get reason;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of BlockModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BlockModelImplCopyWith<_$BlockModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BlockStatusModel _$BlockStatusModelFromJson(Map<String, dynamic> json) {
  return _BlockStatusModel.fromJson(json);
}

/// @nodoc
mixin _$BlockStatusModel {
  @JsonKey(name: 'is_blocked')
  bool get isBlocked => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_blocked_by')
  bool get isBlockedBy => throw _privateConstructorUsedError;
  @JsonKey(name: 'can_interact')
  bool get canInteract => throw _privateConstructorUsedError;

  /// Serializes this BlockStatusModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BlockStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BlockStatusModelCopyWith<BlockStatusModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BlockStatusModelCopyWith<$Res> {
  factory $BlockStatusModelCopyWith(
    BlockStatusModel value,
    $Res Function(BlockStatusModel) then,
  ) = _$BlockStatusModelCopyWithImpl<$Res, BlockStatusModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'is_blocked') bool isBlocked,
    @JsonKey(name: 'is_blocked_by') bool isBlockedBy,
    @JsonKey(name: 'can_interact') bool canInteract,
  });
}

/// @nodoc
class _$BlockStatusModelCopyWithImpl<$Res, $Val extends BlockStatusModel>
    implements $BlockStatusModelCopyWith<$Res> {
  _$BlockStatusModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BlockStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isBlocked = null,
    Object? isBlockedBy = null,
    Object? canInteract = null,
  }) {
    return _then(
      _value.copyWith(
            isBlocked: null == isBlocked
                ? _value.isBlocked
                : isBlocked // ignore: cast_nullable_to_non_nullable
                      as bool,
            isBlockedBy: null == isBlockedBy
                ? _value.isBlockedBy
                : isBlockedBy // ignore: cast_nullable_to_non_nullable
                      as bool,
            canInteract: null == canInteract
                ? _value.canInteract
                : canInteract // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BlockStatusModelImplCopyWith<$Res>
    implements $BlockStatusModelCopyWith<$Res> {
  factory _$$BlockStatusModelImplCopyWith(
    _$BlockStatusModelImpl value,
    $Res Function(_$BlockStatusModelImpl) then,
  ) = __$$BlockStatusModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'is_blocked') bool isBlocked,
    @JsonKey(name: 'is_blocked_by') bool isBlockedBy,
    @JsonKey(name: 'can_interact') bool canInteract,
  });
}

/// @nodoc
class __$$BlockStatusModelImplCopyWithImpl<$Res>
    extends _$BlockStatusModelCopyWithImpl<$Res, _$BlockStatusModelImpl>
    implements _$$BlockStatusModelImplCopyWith<$Res> {
  __$$BlockStatusModelImplCopyWithImpl(
    _$BlockStatusModelImpl _value,
    $Res Function(_$BlockStatusModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BlockStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isBlocked = null,
    Object? isBlockedBy = null,
    Object? canInteract = null,
  }) {
    return _then(
      _$BlockStatusModelImpl(
        isBlocked: null == isBlocked
            ? _value.isBlocked
            : isBlocked // ignore: cast_nullable_to_non_nullable
                  as bool,
        isBlockedBy: null == isBlockedBy
            ? _value.isBlockedBy
            : isBlockedBy // ignore: cast_nullable_to_non_nullable
                  as bool,
        canInteract: null == canInteract
            ? _value.canInteract
            : canInteract // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BlockStatusModelImpl implements _BlockStatusModel {
  const _$BlockStatusModelImpl({
    @JsonKey(name: 'is_blocked') required this.isBlocked,
    @JsonKey(name: 'is_blocked_by') required this.isBlockedBy,
    @JsonKey(name: 'can_interact') required this.canInteract,
  });

  factory _$BlockStatusModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$BlockStatusModelImplFromJson(json);

  @override
  @JsonKey(name: 'is_blocked')
  final bool isBlocked;
  @override
  @JsonKey(name: 'is_blocked_by')
  final bool isBlockedBy;
  @override
  @JsonKey(name: 'can_interact')
  final bool canInteract;

  @override
  String toString() {
    return 'BlockStatusModel(isBlocked: $isBlocked, isBlockedBy: $isBlockedBy, canInteract: $canInteract)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BlockStatusModelImpl &&
            (identical(other.isBlocked, isBlocked) ||
                other.isBlocked == isBlocked) &&
            (identical(other.isBlockedBy, isBlockedBy) ||
                other.isBlockedBy == isBlockedBy) &&
            (identical(other.canInteract, canInteract) ||
                other.canInteract == canInteract));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, isBlocked, isBlockedBy, canInteract);

  /// Create a copy of BlockStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BlockStatusModelImplCopyWith<_$BlockStatusModelImpl> get copyWith =>
      __$$BlockStatusModelImplCopyWithImpl<_$BlockStatusModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$BlockStatusModelImplToJson(this);
  }
}

abstract class _BlockStatusModel implements BlockStatusModel {
  const factory _BlockStatusModel({
    @JsonKey(name: 'is_blocked') required final bool isBlocked,
    @JsonKey(name: 'is_blocked_by') required final bool isBlockedBy,
    @JsonKey(name: 'can_interact') required final bool canInteract,
  }) = _$BlockStatusModelImpl;

  factory _BlockStatusModel.fromJson(Map<String, dynamic> json) =
      _$BlockStatusModelImpl.fromJson;

  @override
  @JsonKey(name: 'is_blocked')
  bool get isBlocked;
  @override
  @JsonKey(name: 'is_blocked_by')
  bool get isBlockedBy;
  @override
  @JsonKey(name: 'can_interact')
  bool get canInteract;

  /// Create a copy of BlockStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BlockStatusModelImplCopyWith<_$BlockStatusModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
