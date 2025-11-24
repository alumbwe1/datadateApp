// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'system_status_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SystemStatusModel _$SystemStatusModelFromJson(Map<String, dynamic> json) {
  return _SystemStatusModel.fromJson(json);
}

/// @nodoc
mixin _$SystemStatusModel {
  String get mode => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_maintenance')
  bool get isMaintenance => throw _privateConstructorUsedError;
  @JsonKey(name: 'maintenance_message')
  String get maintenanceMessage => throw _privateConstructorUsedError;
  @JsonKey(name: 'features_enabled')
  FeaturesEnabledModel get featuresEnabled =>
      throw _privateConstructorUsedError;

  /// Serializes this SystemStatusModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SystemStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SystemStatusModelCopyWith<SystemStatusModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SystemStatusModelCopyWith<$Res> {
  factory $SystemStatusModelCopyWith(
    SystemStatusModel value,
    $Res Function(SystemStatusModel) then,
  ) = _$SystemStatusModelCopyWithImpl<$Res, SystemStatusModel>;
  @useResult
  $Res call({
    String mode,
    @JsonKey(name: 'is_maintenance') bool isMaintenance,
    @JsonKey(name: 'maintenance_message') String maintenanceMessage,
    @JsonKey(name: 'features_enabled') FeaturesEnabledModel featuresEnabled,
  });

  $FeaturesEnabledModelCopyWith<$Res> get featuresEnabled;
}

/// @nodoc
class _$SystemStatusModelCopyWithImpl<$Res, $Val extends SystemStatusModel>
    implements $SystemStatusModelCopyWith<$Res> {
  _$SystemStatusModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SystemStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mode = null,
    Object? isMaintenance = null,
    Object? maintenanceMessage = null,
    Object? featuresEnabled = null,
  }) {
    return _then(
      _value.copyWith(
            mode: null == mode
                ? _value.mode
                : mode // ignore: cast_nullable_to_non_nullable
                      as String,
            isMaintenance: null == isMaintenance
                ? _value.isMaintenance
                : isMaintenance // ignore: cast_nullable_to_non_nullable
                      as bool,
            maintenanceMessage: null == maintenanceMessage
                ? _value.maintenanceMessage
                : maintenanceMessage // ignore: cast_nullable_to_non_nullable
                      as String,
            featuresEnabled: null == featuresEnabled
                ? _value.featuresEnabled
                : featuresEnabled // ignore: cast_nullable_to_non_nullable
                      as FeaturesEnabledModel,
          )
          as $Val,
    );
  }

  /// Create a copy of SystemStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FeaturesEnabledModelCopyWith<$Res> get featuresEnabled {
    return $FeaturesEnabledModelCopyWith<$Res>(_value.featuresEnabled, (value) {
      return _then(_value.copyWith(featuresEnabled: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SystemStatusModelImplCopyWith<$Res>
    implements $SystemStatusModelCopyWith<$Res> {
  factory _$$SystemStatusModelImplCopyWith(
    _$SystemStatusModelImpl value,
    $Res Function(_$SystemStatusModelImpl) then,
  ) = __$$SystemStatusModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String mode,
    @JsonKey(name: 'is_maintenance') bool isMaintenance,
    @JsonKey(name: 'maintenance_message') String maintenanceMessage,
    @JsonKey(name: 'features_enabled') FeaturesEnabledModel featuresEnabled,
  });

  @override
  $FeaturesEnabledModelCopyWith<$Res> get featuresEnabled;
}

/// @nodoc
class __$$SystemStatusModelImplCopyWithImpl<$Res>
    extends _$SystemStatusModelCopyWithImpl<$Res, _$SystemStatusModelImpl>
    implements _$$SystemStatusModelImplCopyWith<$Res> {
  __$$SystemStatusModelImplCopyWithImpl(
    _$SystemStatusModelImpl _value,
    $Res Function(_$SystemStatusModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SystemStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mode = null,
    Object? isMaintenance = null,
    Object? maintenanceMessage = null,
    Object? featuresEnabled = null,
  }) {
    return _then(
      _$SystemStatusModelImpl(
        mode: null == mode
            ? _value.mode
            : mode // ignore: cast_nullable_to_non_nullable
                  as String,
        isMaintenance: null == isMaintenance
            ? _value.isMaintenance
            : isMaintenance // ignore: cast_nullable_to_non_nullable
                  as bool,
        maintenanceMessage: null == maintenanceMessage
            ? _value.maintenanceMessage
            : maintenanceMessage // ignore: cast_nullable_to_non_nullable
                  as String,
        featuresEnabled: null == featuresEnabled
            ? _value.featuresEnabled
            : featuresEnabled // ignore: cast_nullable_to_non_nullable
                  as FeaturesEnabledModel,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SystemStatusModelImpl implements _SystemStatusModel {
  const _$SystemStatusModelImpl({
    required this.mode,
    @JsonKey(name: 'is_maintenance') required this.isMaintenance,
    @JsonKey(name: 'maintenance_message') required this.maintenanceMessage,
    @JsonKey(name: 'features_enabled') required this.featuresEnabled,
  });

  factory _$SystemStatusModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SystemStatusModelImplFromJson(json);

  @override
  final String mode;
  @override
  @JsonKey(name: 'is_maintenance')
  final bool isMaintenance;
  @override
  @JsonKey(name: 'maintenance_message')
  final String maintenanceMessage;
  @override
  @JsonKey(name: 'features_enabled')
  final FeaturesEnabledModel featuresEnabled;

  @override
  String toString() {
    return 'SystemStatusModel(mode: $mode, isMaintenance: $isMaintenance, maintenanceMessage: $maintenanceMessage, featuresEnabled: $featuresEnabled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SystemStatusModelImpl &&
            (identical(other.mode, mode) || other.mode == mode) &&
            (identical(other.isMaintenance, isMaintenance) ||
                other.isMaintenance == isMaintenance) &&
            (identical(other.maintenanceMessage, maintenanceMessage) ||
                other.maintenanceMessage == maintenanceMessage) &&
            (identical(other.featuresEnabled, featuresEnabled) ||
                other.featuresEnabled == featuresEnabled));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    mode,
    isMaintenance,
    maintenanceMessage,
    featuresEnabled,
  );

  /// Create a copy of SystemStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SystemStatusModelImplCopyWith<_$SystemStatusModelImpl> get copyWith =>
      __$$SystemStatusModelImplCopyWithImpl<_$SystemStatusModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SystemStatusModelImplToJson(this);
  }
}

abstract class _SystemStatusModel implements SystemStatusModel {
  const factory _SystemStatusModel({
    required final String mode,
    @JsonKey(name: 'is_maintenance') required final bool isMaintenance,
    @JsonKey(name: 'maintenance_message')
    required final String maintenanceMessage,
    @JsonKey(name: 'features_enabled')
    required final FeaturesEnabledModel featuresEnabled,
  }) = _$SystemStatusModelImpl;

  factory _SystemStatusModel.fromJson(Map<String, dynamic> json) =
      _$SystemStatusModelImpl.fromJson;

  @override
  String get mode;
  @override
  @JsonKey(name: 'is_maintenance')
  bool get isMaintenance;
  @override
  @JsonKey(name: 'maintenance_message')
  String get maintenanceMessage;
  @override
  @JsonKey(name: 'features_enabled')
  FeaturesEnabledModel get featuresEnabled;

  /// Create a copy of SystemStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SystemStatusModelImplCopyWith<_$SystemStatusModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FeaturesEnabledModel _$FeaturesEnabledModelFromJson(Map<String, dynamic> json) {
  return _FeaturesEnabledModel.fromJson(json);
}

/// @nodoc
mixin _$FeaturesEnabledModel {
  bool get matching => throw _privateConstructorUsedError;
  bool get chat => throw _privateConstructorUsedError;
  bool get boost => throw _privateConstructorUsedError;
  bool get premium => throw _privateConstructorUsedError;

  /// Serializes this FeaturesEnabledModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FeaturesEnabledModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FeaturesEnabledModelCopyWith<FeaturesEnabledModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeaturesEnabledModelCopyWith<$Res> {
  factory $FeaturesEnabledModelCopyWith(
    FeaturesEnabledModel value,
    $Res Function(FeaturesEnabledModel) then,
  ) = _$FeaturesEnabledModelCopyWithImpl<$Res, FeaturesEnabledModel>;
  @useResult
  $Res call({bool matching, bool chat, bool boost, bool premium});
}

/// @nodoc
class _$FeaturesEnabledModelCopyWithImpl<
  $Res,
  $Val extends FeaturesEnabledModel
>
    implements $FeaturesEnabledModelCopyWith<$Res> {
  _$FeaturesEnabledModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FeaturesEnabledModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? matching = null,
    Object? chat = null,
    Object? boost = null,
    Object? premium = null,
  }) {
    return _then(
      _value.copyWith(
            matching: null == matching
                ? _value.matching
                : matching // ignore: cast_nullable_to_non_nullable
                      as bool,
            chat: null == chat
                ? _value.chat
                : chat // ignore: cast_nullable_to_non_nullable
                      as bool,
            boost: null == boost
                ? _value.boost
                : boost // ignore: cast_nullable_to_non_nullable
                      as bool,
            premium: null == premium
                ? _value.premium
                : premium // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FeaturesEnabledModelImplCopyWith<$Res>
    implements $FeaturesEnabledModelCopyWith<$Res> {
  factory _$$FeaturesEnabledModelImplCopyWith(
    _$FeaturesEnabledModelImpl value,
    $Res Function(_$FeaturesEnabledModelImpl) then,
  ) = __$$FeaturesEnabledModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool matching, bool chat, bool boost, bool premium});
}

/// @nodoc
class __$$FeaturesEnabledModelImplCopyWithImpl<$Res>
    extends _$FeaturesEnabledModelCopyWithImpl<$Res, _$FeaturesEnabledModelImpl>
    implements _$$FeaturesEnabledModelImplCopyWith<$Res> {
  __$$FeaturesEnabledModelImplCopyWithImpl(
    _$FeaturesEnabledModelImpl _value,
    $Res Function(_$FeaturesEnabledModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FeaturesEnabledModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? matching = null,
    Object? chat = null,
    Object? boost = null,
    Object? premium = null,
  }) {
    return _then(
      _$FeaturesEnabledModelImpl(
        matching: null == matching
            ? _value.matching
            : matching // ignore: cast_nullable_to_non_nullable
                  as bool,
        chat: null == chat
            ? _value.chat
            : chat // ignore: cast_nullable_to_non_nullable
                  as bool,
        boost: null == boost
            ? _value.boost
            : boost // ignore: cast_nullable_to_non_nullable
                  as bool,
        premium: null == premium
            ? _value.premium
            : premium // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FeaturesEnabledModelImpl implements _FeaturesEnabledModel {
  const _$FeaturesEnabledModelImpl({
    required this.matching,
    required this.chat,
    required this.boost,
    required this.premium,
  });

  factory _$FeaturesEnabledModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$FeaturesEnabledModelImplFromJson(json);

  @override
  final bool matching;
  @override
  final bool chat;
  @override
  final bool boost;
  @override
  final bool premium;

  @override
  String toString() {
    return 'FeaturesEnabledModel(matching: $matching, chat: $chat, boost: $boost, premium: $premium)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeaturesEnabledModelImpl &&
            (identical(other.matching, matching) ||
                other.matching == matching) &&
            (identical(other.chat, chat) || other.chat == chat) &&
            (identical(other.boost, boost) || other.boost == boost) &&
            (identical(other.premium, premium) || other.premium == premium));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, matching, chat, boost, premium);

  /// Create a copy of FeaturesEnabledModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeaturesEnabledModelImplCopyWith<_$FeaturesEnabledModelImpl>
  get copyWith =>
      __$$FeaturesEnabledModelImplCopyWithImpl<_$FeaturesEnabledModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$FeaturesEnabledModelImplToJson(this);
  }
}

abstract class _FeaturesEnabledModel implements FeaturesEnabledModel {
  const factory _FeaturesEnabledModel({
    required final bool matching,
    required final bool chat,
    required final bool boost,
    required final bool premium,
  }) = _$FeaturesEnabledModelImpl;

  factory _FeaturesEnabledModel.fromJson(Map<String, dynamic> json) =
      _$FeaturesEnabledModelImpl.fromJson;

  @override
  bool get matching;
  @override
  bool get chat;
  @override
  bool get boost;
  @override
  bool get premium;

  /// Create a copy of FeaturesEnabledModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeaturesEnabledModelImplCopyWith<_$FeaturesEnabledModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
