// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'report_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ReportModel _$ReportModelFromJson(Map<String, dynamic> json) {
  return _ReportModel.fromJson(json);
}

/// @nodoc
mixin _$ReportModel {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'reporter_username')
  String get reporterUsername => throw _privateConstructorUsedError;
  @JsonKey(name: 'reported_username')
  String get reportedUsername => throw _privateConstructorUsedError;
  @JsonKey(name: 'report_type')
  String get reportType => throw _privateConstructorUsedError;
  String get reason => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'message_id')
  String? get messageId => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'admin_notes')
  String? get adminNotes => throw _privateConstructorUsedError;
  @JsonKey(name: 'resolved_at')
  DateTime? get resolvedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'resolved_by_username')
  String? get resolvedByUsername => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this ReportModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReportModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReportModelCopyWith<ReportModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReportModelCopyWith<$Res> {
  factory $ReportModelCopyWith(
    ReportModel value,
    $Res Function(ReportModel) then,
  ) = _$ReportModelCopyWithImpl<$Res, ReportModel>;
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'reporter_username') String reporterUsername,
    @JsonKey(name: 'reported_username') String reportedUsername,
    @JsonKey(name: 'report_type') String reportType,
    String reason,
    String? description,
    @JsonKey(name: 'message_id') String? messageId,
    String status,
    @JsonKey(name: 'admin_notes') String? adminNotes,
    @JsonKey(name: 'resolved_at') DateTime? resolvedAt,
    @JsonKey(name: 'resolved_by_username') String? resolvedByUsername,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class _$ReportModelCopyWithImpl<$Res, $Val extends ReportModel>
    implements $ReportModelCopyWith<$Res> {
  _$ReportModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReportModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? reporterUsername = null,
    Object? reportedUsername = null,
    Object? reportType = null,
    Object? reason = null,
    Object? description = freezed,
    Object? messageId = freezed,
    Object? status = null,
    Object? adminNotes = freezed,
    Object? resolvedAt = freezed,
    Object? resolvedByUsername = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            reporterUsername: null == reporterUsername
                ? _value.reporterUsername
                : reporterUsername // ignore: cast_nullable_to_non_nullable
                      as String,
            reportedUsername: null == reportedUsername
                ? _value.reportedUsername
                : reportedUsername // ignore: cast_nullable_to_non_nullable
                      as String,
            reportType: null == reportType
                ? _value.reportType
                : reportType // ignore: cast_nullable_to_non_nullable
                      as String,
            reason: null == reason
                ? _value.reason
                : reason // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            messageId: freezed == messageId
                ? _value.messageId
                : messageId // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            adminNotes: freezed == adminNotes
                ? _value.adminNotes
                : adminNotes // ignore: cast_nullable_to_non_nullable
                      as String?,
            resolvedAt: freezed == resolvedAt
                ? _value.resolvedAt
                : resolvedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            resolvedByUsername: freezed == resolvedByUsername
                ? _value.resolvedByUsername
                : resolvedByUsername // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReportModelImplCopyWith<$Res>
    implements $ReportModelCopyWith<$Res> {
  factory _$$ReportModelImplCopyWith(
    _$ReportModelImpl value,
    $Res Function(_$ReportModelImpl) then,
  ) = __$$ReportModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'reporter_username') String reporterUsername,
    @JsonKey(name: 'reported_username') String reportedUsername,
    @JsonKey(name: 'report_type') String reportType,
    String reason,
    String? description,
    @JsonKey(name: 'message_id') String? messageId,
    String status,
    @JsonKey(name: 'admin_notes') String? adminNotes,
    @JsonKey(name: 'resolved_at') DateTime? resolvedAt,
    @JsonKey(name: 'resolved_by_username') String? resolvedByUsername,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class __$$ReportModelImplCopyWithImpl<$Res>
    extends _$ReportModelCopyWithImpl<$Res, _$ReportModelImpl>
    implements _$$ReportModelImplCopyWith<$Res> {
  __$$ReportModelImplCopyWithImpl(
    _$ReportModelImpl _value,
    $Res Function(_$ReportModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReportModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? reporterUsername = null,
    Object? reportedUsername = null,
    Object? reportType = null,
    Object? reason = null,
    Object? description = freezed,
    Object? messageId = freezed,
    Object? status = null,
    Object? adminNotes = freezed,
    Object? resolvedAt = freezed,
    Object? resolvedByUsername = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$ReportModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        reporterUsername: null == reporterUsername
            ? _value.reporterUsername
            : reporterUsername // ignore: cast_nullable_to_non_nullable
                  as String,
        reportedUsername: null == reportedUsername
            ? _value.reportedUsername
            : reportedUsername // ignore: cast_nullable_to_non_nullable
                  as String,
        reportType: null == reportType
            ? _value.reportType
            : reportType // ignore: cast_nullable_to_non_nullable
                  as String,
        reason: null == reason
            ? _value.reason
            : reason // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        messageId: freezed == messageId
            ? _value.messageId
            : messageId // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        adminNotes: freezed == adminNotes
            ? _value.adminNotes
            : adminNotes // ignore: cast_nullable_to_non_nullable
                  as String?,
        resolvedAt: freezed == resolvedAt
            ? _value.resolvedAt
            : resolvedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        resolvedByUsername: freezed == resolvedByUsername
            ? _value.resolvedByUsername
            : resolvedByUsername // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReportModelImpl implements _ReportModel {
  const _$ReportModelImpl({
    required this.id,
    @JsonKey(name: 'reporter_username') required this.reporterUsername,
    @JsonKey(name: 'reported_username') required this.reportedUsername,
    @JsonKey(name: 'report_type') required this.reportType,
    required this.reason,
    this.description,
    @JsonKey(name: 'message_id') this.messageId,
    required this.status,
    @JsonKey(name: 'admin_notes') this.adminNotes,
    @JsonKey(name: 'resolved_at') this.resolvedAt,
    @JsonKey(name: 'resolved_by_username') this.resolvedByUsername,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'updated_at') required this.updatedAt,
  });

  factory _$ReportModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReportModelImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'reporter_username')
  final String reporterUsername;
  @override
  @JsonKey(name: 'reported_username')
  final String reportedUsername;
  @override
  @JsonKey(name: 'report_type')
  final String reportType;
  @override
  final String reason;
  @override
  final String? description;
  @override
  @JsonKey(name: 'message_id')
  final String? messageId;
  @override
  final String status;
  @override
  @JsonKey(name: 'admin_notes')
  final String? adminNotes;
  @override
  @JsonKey(name: 'resolved_at')
  final DateTime? resolvedAt;
  @override
  @JsonKey(name: 'resolved_by_username')
  final String? resolvedByUsername;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @override
  String toString() {
    return 'ReportModel(id: $id, reporterUsername: $reporterUsername, reportedUsername: $reportedUsername, reportType: $reportType, reason: $reason, description: $description, messageId: $messageId, status: $status, adminNotes: $adminNotes, resolvedAt: $resolvedAt, resolvedByUsername: $resolvedByUsername, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReportModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.reporterUsername, reporterUsername) ||
                other.reporterUsername == reporterUsername) &&
            (identical(other.reportedUsername, reportedUsername) ||
                other.reportedUsername == reportedUsername) &&
            (identical(other.reportType, reportType) ||
                other.reportType == reportType) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.messageId, messageId) ||
                other.messageId == messageId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.adminNotes, adminNotes) ||
                other.adminNotes == adminNotes) &&
            (identical(other.resolvedAt, resolvedAt) ||
                other.resolvedAt == resolvedAt) &&
            (identical(other.resolvedByUsername, resolvedByUsername) ||
                other.resolvedByUsername == resolvedByUsername) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    reporterUsername,
    reportedUsername,
    reportType,
    reason,
    description,
    messageId,
    status,
    adminNotes,
    resolvedAt,
    resolvedByUsername,
    createdAt,
    updatedAt,
  );

  /// Create a copy of ReportModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReportModelImplCopyWith<_$ReportModelImpl> get copyWith =>
      __$$ReportModelImplCopyWithImpl<_$ReportModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReportModelImplToJson(this);
  }
}

abstract class _ReportModel implements ReportModel {
  const factory _ReportModel({
    required final int id,
    @JsonKey(name: 'reporter_username') required final String reporterUsername,
    @JsonKey(name: 'reported_username') required final String reportedUsername,
    @JsonKey(name: 'report_type') required final String reportType,
    required final String reason,
    final String? description,
    @JsonKey(name: 'message_id') final String? messageId,
    required final String status,
    @JsonKey(name: 'admin_notes') final String? adminNotes,
    @JsonKey(name: 'resolved_at') final DateTime? resolvedAt,
    @JsonKey(name: 'resolved_by_username') final String? resolvedByUsername,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    @JsonKey(name: 'updated_at') required final DateTime updatedAt,
  }) = _$ReportModelImpl;

  factory _ReportModel.fromJson(Map<String, dynamic> json) =
      _$ReportModelImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'reporter_username')
  String get reporterUsername;
  @override
  @JsonKey(name: 'reported_username')
  String get reportedUsername;
  @override
  @JsonKey(name: 'report_type')
  String get reportType;
  @override
  String get reason;
  @override
  String? get description;
  @override
  @JsonKey(name: 'message_id')
  String? get messageId;
  @override
  String get status;
  @override
  @JsonKey(name: 'admin_notes')
  String? get adminNotes;
  @override
  @JsonKey(name: 'resolved_at')
  DateTime? get resolvedAt;
  @override
  @JsonKey(name: 'resolved_by_username')
  String? get resolvedByUsername;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;

  /// Create a copy of ReportModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReportModelImplCopyWith<_$ReportModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
