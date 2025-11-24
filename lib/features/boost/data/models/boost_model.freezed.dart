// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'boost_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BoostPricingModel _$BoostPricingModelFromJson(Map<String, dynamic> json) {
  return _BoostPricingModel.fromJson(json);
}

/// @nodoc
mixin _$BoostPricingModel {
  @JsonKey(name: 'min_amount')
  double get minAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'default_duration_hours')
  int get defaultDurationHours => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  bool get enabled => throw _privateConstructorUsedError;

  /// Serializes this BoostPricingModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BoostPricingModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BoostPricingModelCopyWith<BoostPricingModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BoostPricingModelCopyWith<$Res> {
  factory $BoostPricingModelCopyWith(
    BoostPricingModel value,
    $Res Function(BoostPricingModel) then,
  ) = _$BoostPricingModelCopyWithImpl<$Res, BoostPricingModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'min_amount') double minAmount,
    @JsonKey(name: 'default_duration_hours') int defaultDurationHours,
    String currency,
    bool enabled,
  });
}

/// @nodoc
class _$BoostPricingModelCopyWithImpl<$Res, $Val extends BoostPricingModel>
    implements $BoostPricingModelCopyWith<$Res> {
  _$BoostPricingModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BoostPricingModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? minAmount = null,
    Object? defaultDurationHours = null,
    Object? currency = null,
    Object? enabled = null,
  }) {
    return _then(
      _value.copyWith(
            minAmount: null == minAmount
                ? _value.minAmount
                : minAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            defaultDurationHours: null == defaultDurationHours
                ? _value.defaultDurationHours
                : defaultDurationHours // ignore: cast_nullable_to_non_nullable
                      as int,
            currency: null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as String,
            enabled: null == enabled
                ? _value.enabled
                : enabled // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BoostPricingModelImplCopyWith<$Res>
    implements $BoostPricingModelCopyWith<$Res> {
  factory _$$BoostPricingModelImplCopyWith(
    _$BoostPricingModelImpl value,
    $Res Function(_$BoostPricingModelImpl) then,
  ) = __$$BoostPricingModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'min_amount') double minAmount,
    @JsonKey(name: 'default_duration_hours') int defaultDurationHours,
    String currency,
    bool enabled,
  });
}

/// @nodoc
class __$$BoostPricingModelImplCopyWithImpl<$Res>
    extends _$BoostPricingModelCopyWithImpl<$Res, _$BoostPricingModelImpl>
    implements _$$BoostPricingModelImplCopyWith<$Res> {
  __$$BoostPricingModelImplCopyWithImpl(
    _$BoostPricingModelImpl _value,
    $Res Function(_$BoostPricingModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BoostPricingModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? minAmount = null,
    Object? defaultDurationHours = null,
    Object? currency = null,
    Object? enabled = null,
  }) {
    return _then(
      _$BoostPricingModelImpl(
        minAmount: null == minAmount
            ? _value.minAmount
            : minAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        defaultDurationHours: null == defaultDurationHours
            ? _value.defaultDurationHours
            : defaultDurationHours // ignore: cast_nullable_to_non_nullable
                  as int,
        currency: null == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as String,
        enabled: null == enabled
            ? _value.enabled
            : enabled // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BoostPricingModelImpl implements _BoostPricingModel {
  const _$BoostPricingModelImpl({
    @JsonKey(name: 'min_amount') required this.minAmount,
    @JsonKey(name: 'default_duration_hours') required this.defaultDurationHours,
    required this.currency,
    required this.enabled,
  });

  factory _$BoostPricingModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$BoostPricingModelImplFromJson(json);

  @override
  @JsonKey(name: 'min_amount')
  final double minAmount;
  @override
  @JsonKey(name: 'default_duration_hours')
  final int defaultDurationHours;
  @override
  final String currency;
  @override
  final bool enabled;

  @override
  String toString() {
    return 'BoostPricingModel(minAmount: $minAmount, defaultDurationHours: $defaultDurationHours, currency: $currency, enabled: $enabled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BoostPricingModelImpl &&
            (identical(other.minAmount, minAmount) ||
                other.minAmount == minAmount) &&
            (identical(other.defaultDurationHours, defaultDurationHours) ||
                other.defaultDurationHours == defaultDurationHours) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.enabled, enabled) || other.enabled == enabled));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    minAmount,
    defaultDurationHours,
    currency,
    enabled,
  );

  /// Create a copy of BoostPricingModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BoostPricingModelImplCopyWith<_$BoostPricingModelImpl> get copyWith =>
      __$$BoostPricingModelImplCopyWithImpl<_$BoostPricingModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$BoostPricingModelImplToJson(this);
  }
}

abstract class _BoostPricingModel implements BoostPricingModel {
  const factory _BoostPricingModel({
    @JsonKey(name: 'min_amount') required final double minAmount,
    @JsonKey(name: 'default_duration_hours')
    required final int defaultDurationHours,
    required final String currency,
    required final bool enabled,
  }) = _$BoostPricingModelImpl;

  factory _BoostPricingModel.fromJson(Map<String, dynamic> json) =
      _$BoostPricingModelImpl.fromJson;

  @override
  @JsonKey(name: 'min_amount')
  double get minAmount;
  @override
  @JsonKey(name: 'default_duration_hours')
  int get defaultDurationHours;
  @override
  String get currency;
  @override
  bool get enabled;

  /// Create a copy of BoostPricingModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BoostPricingModelImplCopyWith<_$BoostPricingModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BoostModel _$BoostModelFromJson(Map<String, dynamic> json) {
  return _BoostModel.fromJson(json);
}

/// @nodoc
mixin _$BoostModel {
  int get id => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  @JsonKey(name: 'amount_paid')
  String get amountPaid => throw _privateConstructorUsedError;
  @JsonKey(name: 'target_views')
  int get targetViews => throw _privateConstructorUsedError;
  @JsonKey(name: 'duration_hours')
  int get durationHours => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_views')
  int get currentViews => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'progress_percentage')
  double get progressPercentage => throw _privateConstructorUsedError;
  @JsonKey(name: 'time_remaining')
  int get timeRemaining => throw _privateConstructorUsedError;
  @JsonKey(name: 'started_at')
  DateTime? get startedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'expires_at')
  DateTime? get expiresAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'completed_at')
  DateTime? get completedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this BoostModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BoostModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BoostModelCopyWith<BoostModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BoostModelCopyWith<$Res> {
  factory $BoostModelCopyWith(
    BoostModel value,
    $Res Function(BoostModel) then,
  ) = _$BoostModelCopyWithImpl<$Res, BoostModel>;
  @useResult
  $Res call({
    int id,
    String username,
    @JsonKey(name: 'amount_paid') String amountPaid,
    @JsonKey(name: 'target_views') int targetViews,
    @JsonKey(name: 'duration_hours') int durationHours,
    @JsonKey(name: 'current_views') int currentViews,
    String status,
    @JsonKey(name: 'progress_percentage') double progressPercentage,
    @JsonKey(name: 'time_remaining') int timeRemaining,
    @JsonKey(name: 'started_at') DateTime? startedAt,
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
    @JsonKey(name: 'completed_at') DateTime? completedAt,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class _$BoostModelCopyWithImpl<$Res, $Val extends BoostModel>
    implements $BoostModelCopyWith<$Res> {
  _$BoostModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BoostModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? username = null,
    Object? amountPaid = null,
    Object? targetViews = null,
    Object? durationHours = null,
    Object? currentViews = null,
    Object? status = null,
    Object? progressPercentage = null,
    Object? timeRemaining = null,
    Object? startedAt = freezed,
    Object? expiresAt = freezed,
    Object? completedAt = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            username: null == username
                ? _value.username
                : username // ignore: cast_nullable_to_non_nullable
                      as String,
            amountPaid: null == amountPaid
                ? _value.amountPaid
                : amountPaid // ignore: cast_nullable_to_non_nullable
                      as String,
            targetViews: null == targetViews
                ? _value.targetViews
                : targetViews // ignore: cast_nullable_to_non_nullable
                      as int,
            durationHours: null == durationHours
                ? _value.durationHours
                : durationHours // ignore: cast_nullable_to_non_nullable
                      as int,
            currentViews: null == currentViews
                ? _value.currentViews
                : currentViews // ignore: cast_nullable_to_non_nullable
                      as int,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            progressPercentage: null == progressPercentage
                ? _value.progressPercentage
                : progressPercentage // ignore: cast_nullable_to_non_nullable
                      as double,
            timeRemaining: null == timeRemaining
                ? _value.timeRemaining
                : timeRemaining // ignore: cast_nullable_to_non_nullable
                      as int,
            startedAt: freezed == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            expiresAt: freezed == expiresAt
                ? _value.expiresAt
                : expiresAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            completedAt: freezed == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
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
abstract class _$$BoostModelImplCopyWith<$Res>
    implements $BoostModelCopyWith<$Res> {
  factory _$$BoostModelImplCopyWith(
    _$BoostModelImpl value,
    $Res Function(_$BoostModelImpl) then,
  ) = __$$BoostModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String username,
    @JsonKey(name: 'amount_paid') String amountPaid,
    @JsonKey(name: 'target_views') int targetViews,
    @JsonKey(name: 'duration_hours') int durationHours,
    @JsonKey(name: 'current_views') int currentViews,
    String status,
    @JsonKey(name: 'progress_percentage') double progressPercentage,
    @JsonKey(name: 'time_remaining') int timeRemaining,
    @JsonKey(name: 'started_at') DateTime? startedAt,
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
    @JsonKey(name: 'completed_at') DateTime? completedAt,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class __$$BoostModelImplCopyWithImpl<$Res>
    extends _$BoostModelCopyWithImpl<$Res, _$BoostModelImpl>
    implements _$$BoostModelImplCopyWith<$Res> {
  __$$BoostModelImplCopyWithImpl(
    _$BoostModelImpl _value,
    $Res Function(_$BoostModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BoostModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? username = null,
    Object? amountPaid = null,
    Object? targetViews = null,
    Object? durationHours = null,
    Object? currentViews = null,
    Object? status = null,
    Object? progressPercentage = null,
    Object? timeRemaining = null,
    Object? startedAt = freezed,
    Object? expiresAt = freezed,
    Object? completedAt = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$BoostModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        username: null == username
            ? _value.username
            : username // ignore: cast_nullable_to_non_nullable
                  as String,
        amountPaid: null == amountPaid
            ? _value.amountPaid
            : amountPaid // ignore: cast_nullable_to_non_nullable
                  as String,
        targetViews: null == targetViews
            ? _value.targetViews
            : targetViews // ignore: cast_nullable_to_non_nullable
                  as int,
        durationHours: null == durationHours
            ? _value.durationHours
            : durationHours // ignore: cast_nullable_to_non_nullable
                  as int,
        currentViews: null == currentViews
            ? _value.currentViews
            : currentViews // ignore: cast_nullable_to_non_nullable
                  as int,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        progressPercentage: null == progressPercentage
            ? _value.progressPercentage
            : progressPercentage // ignore: cast_nullable_to_non_nullable
                  as double,
        timeRemaining: null == timeRemaining
            ? _value.timeRemaining
            : timeRemaining // ignore: cast_nullable_to_non_nullable
                  as int,
        startedAt: freezed == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        expiresAt: freezed == expiresAt
            ? _value.expiresAt
            : expiresAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        completedAt: freezed == completedAt
            ? _value.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
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
class _$BoostModelImpl implements _BoostModel {
  const _$BoostModelImpl({
    required this.id,
    required this.username,
    @JsonKey(name: 'amount_paid') required this.amountPaid,
    @JsonKey(name: 'target_views') required this.targetViews,
    @JsonKey(name: 'duration_hours') required this.durationHours,
    @JsonKey(name: 'current_views') required this.currentViews,
    required this.status,
    @JsonKey(name: 'progress_percentage') required this.progressPercentage,
    @JsonKey(name: 'time_remaining') required this.timeRemaining,
    @JsonKey(name: 'started_at') this.startedAt,
    @JsonKey(name: 'expires_at') this.expiresAt,
    @JsonKey(name: 'completed_at') this.completedAt,
    @JsonKey(name: 'created_at') required this.createdAt,
  });

  factory _$BoostModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$BoostModelImplFromJson(json);

  @override
  final int id;
  @override
  final String username;
  @override
  @JsonKey(name: 'amount_paid')
  final String amountPaid;
  @override
  @JsonKey(name: 'target_views')
  final int targetViews;
  @override
  @JsonKey(name: 'duration_hours')
  final int durationHours;
  @override
  @JsonKey(name: 'current_views')
  final int currentViews;
  @override
  final String status;
  @override
  @JsonKey(name: 'progress_percentage')
  final double progressPercentage;
  @override
  @JsonKey(name: 'time_remaining')
  final int timeRemaining;
  @override
  @JsonKey(name: 'started_at')
  final DateTime? startedAt;
  @override
  @JsonKey(name: 'expires_at')
  final DateTime? expiresAt;
  @override
  @JsonKey(name: 'completed_at')
  final DateTime? completedAt;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'BoostModel(id: $id, username: $username, amountPaid: $amountPaid, targetViews: $targetViews, durationHours: $durationHours, currentViews: $currentViews, status: $status, progressPercentage: $progressPercentage, timeRemaining: $timeRemaining, startedAt: $startedAt, expiresAt: $expiresAt, completedAt: $completedAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BoostModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.amountPaid, amountPaid) ||
                other.amountPaid == amountPaid) &&
            (identical(other.targetViews, targetViews) ||
                other.targetViews == targetViews) &&
            (identical(other.durationHours, durationHours) ||
                other.durationHours == durationHours) &&
            (identical(other.currentViews, currentViews) ||
                other.currentViews == currentViews) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.progressPercentage, progressPercentage) ||
                other.progressPercentage == progressPercentage) &&
            (identical(other.timeRemaining, timeRemaining) ||
                other.timeRemaining == timeRemaining) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    username,
    amountPaid,
    targetViews,
    durationHours,
    currentViews,
    status,
    progressPercentage,
    timeRemaining,
    startedAt,
    expiresAt,
    completedAt,
    createdAt,
  );

  /// Create a copy of BoostModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BoostModelImplCopyWith<_$BoostModelImpl> get copyWith =>
      __$$BoostModelImplCopyWithImpl<_$BoostModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BoostModelImplToJson(this);
  }
}

abstract class _BoostModel implements BoostModel {
  const factory _BoostModel({
    required final int id,
    required final String username,
    @JsonKey(name: 'amount_paid') required final String amountPaid,
    @JsonKey(name: 'target_views') required final int targetViews,
    @JsonKey(name: 'duration_hours') required final int durationHours,
    @JsonKey(name: 'current_views') required final int currentViews,
    required final String status,
    @JsonKey(name: 'progress_percentage')
    required final double progressPercentage,
    @JsonKey(name: 'time_remaining') required final int timeRemaining,
    @JsonKey(name: 'started_at') final DateTime? startedAt,
    @JsonKey(name: 'expires_at') final DateTime? expiresAt,
    @JsonKey(name: 'completed_at') final DateTime? completedAt,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
  }) = _$BoostModelImpl;

  factory _BoostModel.fromJson(Map<String, dynamic> json) =
      _$BoostModelImpl.fromJson;

  @override
  int get id;
  @override
  String get username;
  @override
  @JsonKey(name: 'amount_paid')
  String get amountPaid;
  @override
  @JsonKey(name: 'target_views')
  int get targetViews;
  @override
  @JsonKey(name: 'duration_hours')
  int get durationHours;
  @override
  @JsonKey(name: 'current_views')
  int get currentViews;
  @override
  String get status;
  @override
  @JsonKey(name: 'progress_percentage')
  double get progressPercentage;
  @override
  @JsonKey(name: 'time_remaining')
  int get timeRemaining;
  @override
  @JsonKey(name: 'started_at')
  DateTime? get startedAt;
  @override
  @JsonKey(name: 'expires_at')
  DateTime? get expiresAt;
  @override
  @JsonKey(name: 'completed_at')
  DateTime? get completedAt;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of BoostModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BoostModelImplCopyWith<_$BoostModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
