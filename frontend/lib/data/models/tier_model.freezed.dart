// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tier_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TierModel _$TierModelFromJson(Map<String, dynamic> json) {
  return _TierModel.fromJson(json);
}

/// @nodoc
mixin _$TierModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'boutique_id')
  String get boutiqueId => throw _privateConstructorUsedError;
  String get nom => throw _privateConstructorUsedError;
  String? get telephone => throw _privateConstructorUsedError;
  @JsonKey(name: 'type_tiers')
  String get typeTiers => throw _privateConstructorUsedError;
  @JsonKey(name: 'solde_du')
  double get soldeDu => throw _privateConstructorUsedError;

  /// Serializes this TierModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TierModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TierModelCopyWith<TierModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TierModelCopyWith<$Res> {
  factory $TierModelCopyWith(TierModel value, $Res Function(TierModel) then) =
      _$TierModelCopyWithImpl<$Res, TierModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'boutique_id') String boutiqueId,
      String nom,
      String? telephone,
      @JsonKey(name: 'type_tiers') String typeTiers,
      @JsonKey(name: 'solde_du') double soldeDu});
}

/// @nodoc
class _$TierModelCopyWithImpl<$Res, $Val extends TierModel>
    implements $TierModelCopyWith<$Res> {
  _$TierModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TierModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? boutiqueId = null,
    Object? nom = null,
    Object? telephone = freezed,
    Object? typeTiers = null,
    Object? soldeDu = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      boutiqueId: null == boutiqueId
          ? _value.boutiqueId
          : boutiqueId // ignore: cast_nullable_to_non_nullable
              as String,
      nom: null == nom
          ? _value.nom
          : nom // ignore: cast_nullable_to_non_nullable
              as String,
      telephone: freezed == telephone
          ? _value.telephone
          : telephone // ignore: cast_nullable_to_non_nullable
              as String?,
      typeTiers: null == typeTiers
          ? _value.typeTiers
          : typeTiers // ignore: cast_nullable_to_non_nullable
              as String,
      soldeDu: null == soldeDu
          ? _value.soldeDu
          : soldeDu // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TierModelImplCopyWith<$Res>
    implements $TierModelCopyWith<$Res> {
  factory _$$TierModelImplCopyWith(
          _$TierModelImpl value, $Res Function(_$TierModelImpl) then) =
      __$$TierModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'boutique_id') String boutiqueId,
      String nom,
      String? telephone,
      @JsonKey(name: 'type_tiers') String typeTiers,
      @JsonKey(name: 'solde_du') double soldeDu});
}

/// @nodoc
class __$$TierModelImplCopyWithImpl<$Res>
    extends _$TierModelCopyWithImpl<$Res, _$TierModelImpl>
    implements _$$TierModelImplCopyWith<$Res> {
  __$$TierModelImplCopyWithImpl(
      _$TierModelImpl _value, $Res Function(_$TierModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of TierModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? boutiqueId = null,
    Object? nom = null,
    Object? telephone = freezed,
    Object? typeTiers = null,
    Object? soldeDu = null,
  }) {
    return _then(_$TierModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      boutiqueId: null == boutiqueId
          ? _value.boutiqueId
          : boutiqueId // ignore: cast_nullable_to_non_nullable
              as String,
      nom: null == nom
          ? _value.nom
          : nom // ignore: cast_nullable_to_non_nullable
              as String,
      telephone: freezed == telephone
          ? _value.telephone
          : telephone // ignore: cast_nullable_to_non_nullable
              as String?,
      typeTiers: null == typeTiers
          ? _value.typeTiers
          : typeTiers // ignore: cast_nullable_to_non_nullable
              as String,
      soldeDu: null == soldeDu
          ? _value.soldeDu
          : soldeDu // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TierModelImpl implements _TierModel {
  const _$TierModelImpl(
      {required this.id,
      @JsonKey(name: 'boutique_id') required this.boutiqueId,
      required this.nom,
      this.telephone,
      @JsonKey(name: 'type_tiers') required this.typeTiers,
      @JsonKey(name: 'solde_du') this.soldeDu = 0});

  factory _$TierModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TierModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'boutique_id')
  final String boutiqueId;
  @override
  final String nom;
  @override
  final String? telephone;
  @override
  @JsonKey(name: 'type_tiers')
  final String typeTiers;
  @override
  @JsonKey(name: 'solde_du')
  final double soldeDu;

  @override
  String toString() {
    return 'TierModel(id: $id, boutiqueId: $boutiqueId, nom: $nom, telephone: $telephone, typeTiers: $typeTiers, soldeDu: $soldeDu)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TierModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.boutiqueId, boutiqueId) ||
                other.boutiqueId == boutiqueId) &&
            (identical(other.nom, nom) || other.nom == nom) &&
            (identical(other.telephone, telephone) ||
                other.telephone == telephone) &&
            (identical(other.typeTiers, typeTiers) ||
                other.typeTiers == typeTiers) &&
            (identical(other.soldeDu, soldeDu) || other.soldeDu == soldeDu));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, boutiqueId, nom, telephone, typeTiers, soldeDu);

  /// Create a copy of TierModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TierModelImplCopyWith<_$TierModelImpl> get copyWith =>
      __$$TierModelImplCopyWithImpl<_$TierModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TierModelImplToJson(
      this,
    );
  }
}

abstract class _TierModel implements TierModel {
  const factory _TierModel(
      {required final String id,
      @JsonKey(name: 'boutique_id') required final String boutiqueId,
      required final String nom,
      final String? telephone,
      @JsonKey(name: 'type_tiers') required final String typeTiers,
      @JsonKey(name: 'solde_du') final double soldeDu}) = _$TierModelImpl;

  factory _TierModel.fromJson(Map<String, dynamic> json) =
      _$TierModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'boutique_id')
  String get boutiqueId;
  @override
  String get nom;
  @override
  String? get telephone;
  @override
  @JsonKey(name: 'type_tiers')
  String get typeTiers;
  @override
  @JsonKey(name: 'solde_du')
  double get soldeDu;

  /// Create a copy of TierModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TierModelImplCopyWith<_$TierModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TierCreateRequest _$TierCreateRequestFromJson(Map<String, dynamic> json) {
  return _TierCreateRequest.fromJson(json);
}

/// @nodoc
mixin _$TierCreateRequest {
  @JsonKey(name: 'boutique_id')
  String get boutiqueId => throw _privateConstructorUsedError;
  String get nom => throw _privateConstructorUsedError;
  String? get telephone => throw _privateConstructorUsedError;
  @JsonKey(name: 'type_tiers')
  String get typeTiers => throw _privateConstructorUsedError;

  /// Serializes this TierCreateRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TierCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TierCreateRequestCopyWith<TierCreateRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TierCreateRequestCopyWith<$Res> {
  factory $TierCreateRequestCopyWith(
          TierCreateRequest value, $Res Function(TierCreateRequest) then) =
      _$TierCreateRequestCopyWithImpl<$Res, TierCreateRequest>;
  @useResult
  $Res call(
      {@JsonKey(name: 'boutique_id') String boutiqueId,
      String nom,
      String? telephone,
      @JsonKey(name: 'type_tiers') String typeTiers});
}

/// @nodoc
class _$TierCreateRequestCopyWithImpl<$Res, $Val extends TierCreateRequest>
    implements $TierCreateRequestCopyWith<$Res> {
  _$TierCreateRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TierCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? boutiqueId = null,
    Object? nom = null,
    Object? telephone = freezed,
    Object? typeTiers = null,
  }) {
    return _then(_value.copyWith(
      boutiqueId: null == boutiqueId
          ? _value.boutiqueId
          : boutiqueId // ignore: cast_nullable_to_non_nullable
              as String,
      nom: null == nom
          ? _value.nom
          : nom // ignore: cast_nullable_to_non_nullable
              as String,
      telephone: freezed == telephone
          ? _value.telephone
          : telephone // ignore: cast_nullable_to_non_nullable
              as String?,
      typeTiers: null == typeTiers
          ? _value.typeTiers
          : typeTiers // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TierCreateRequestImplCopyWith<$Res>
    implements $TierCreateRequestCopyWith<$Res> {
  factory _$$TierCreateRequestImplCopyWith(_$TierCreateRequestImpl value,
          $Res Function(_$TierCreateRequestImpl) then) =
      __$$TierCreateRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'boutique_id') String boutiqueId,
      String nom,
      String? telephone,
      @JsonKey(name: 'type_tiers') String typeTiers});
}

/// @nodoc
class __$$TierCreateRequestImplCopyWithImpl<$Res>
    extends _$TierCreateRequestCopyWithImpl<$Res, _$TierCreateRequestImpl>
    implements _$$TierCreateRequestImplCopyWith<$Res> {
  __$$TierCreateRequestImplCopyWithImpl(_$TierCreateRequestImpl _value,
      $Res Function(_$TierCreateRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of TierCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? boutiqueId = null,
    Object? nom = null,
    Object? telephone = freezed,
    Object? typeTiers = null,
  }) {
    return _then(_$TierCreateRequestImpl(
      boutiqueId: null == boutiqueId
          ? _value.boutiqueId
          : boutiqueId // ignore: cast_nullable_to_non_nullable
              as String,
      nom: null == nom
          ? _value.nom
          : nom // ignore: cast_nullable_to_non_nullable
              as String,
      telephone: freezed == telephone
          ? _value.telephone
          : telephone // ignore: cast_nullable_to_non_nullable
              as String?,
      typeTiers: null == typeTiers
          ? _value.typeTiers
          : typeTiers // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TierCreateRequestImpl implements _TierCreateRequest {
  const _$TierCreateRequestImpl(
      {@JsonKey(name: 'boutique_id') required this.boutiqueId,
      required this.nom,
      this.telephone,
      @JsonKey(name: 'type_tiers') required this.typeTiers});

  factory _$TierCreateRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$TierCreateRequestImplFromJson(json);

  @override
  @JsonKey(name: 'boutique_id')
  final String boutiqueId;
  @override
  final String nom;
  @override
  final String? telephone;
  @override
  @JsonKey(name: 'type_tiers')
  final String typeTiers;

  @override
  String toString() {
    return 'TierCreateRequest(boutiqueId: $boutiqueId, nom: $nom, telephone: $telephone, typeTiers: $typeTiers)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TierCreateRequestImpl &&
            (identical(other.boutiqueId, boutiqueId) ||
                other.boutiqueId == boutiqueId) &&
            (identical(other.nom, nom) || other.nom == nom) &&
            (identical(other.telephone, telephone) ||
                other.telephone == telephone) &&
            (identical(other.typeTiers, typeTiers) ||
                other.typeTiers == typeTiers));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, boutiqueId, nom, telephone, typeTiers);

  /// Create a copy of TierCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TierCreateRequestImplCopyWith<_$TierCreateRequestImpl> get copyWith =>
      __$$TierCreateRequestImplCopyWithImpl<_$TierCreateRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TierCreateRequestImplToJson(
      this,
    );
  }
}

abstract class _TierCreateRequest implements TierCreateRequest {
  const factory _TierCreateRequest(
          {@JsonKey(name: 'boutique_id') required final String boutiqueId,
          required final String nom,
          final String? telephone,
          @JsonKey(name: 'type_tiers') required final String typeTiers}) =
      _$TierCreateRequestImpl;

  factory _TierCreateRequest.fromJson(Map<String, dynamic> json) =
      _$TierCreateRequestImpl.fromJson;

  @override
  @JsonKey(name: 'boutique_id')
  String get boutiqueId;
  @override
  String get nom;
  @override
  String? get telephone;
  @override
  @JsonKey(name: 'type_tiers')
  String get typeTiers;

  /// Create a copy of TierCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TierCreateRequestImplCopyWith<_$TierCreateRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TierUpdateRequest _$TierUpdateRequestFromJson(Map<String, dynamic> json) {
  return _TierUpdateRequest.fromJson(json);
}

/// @nodoc
mixin _$TierUpdateRequest {
  String? get nom => throw _privateConstructorUsedError;
  String? get telephone => throw _privateConstructorUsedError;

  /// Serializes this TierUpdateRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TierUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TierUpdateRequestCopyWith<TierUpdateRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TierUpdateRequestCopyWith<$Res> {
  factory $TierUpdateRequestCopyWith(
          TierUpdateRequest value, $Res Function(TierUpdateRequest) then) =
      _$TierUpdateRequestCopyWithImpl<$Res, TierUpdateRequest>;
  @useResult
  $Res call({String? nom, String? telephone});
}

/// @nodoc
class _$TierUpdateRequestCopyWithImpl<$Res, $Val extends TierUpdateRequest>
    implements $TierUpdateRequestCopyWith<$Res> {
  _$TierUpdateRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TierUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? nom = freezed,
    Object? telephone = freezed,
  }) {
    return _then(_value.copyWith(
      nom: freezed == nom
          ? _value.nom
          : nom // ignore: cast_nullable_to_non_nullable
              as String?,
      telephone: freezed == telephone
          ? _value.telephone
          : telephone // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TierUpdateRequestImplCopyWith<$Res>
    implements $TierUpdateRequestCopyWith<$Res> {
  factory _$$TierUpdateRequestImplCopyWith(_$TierUpdateRequestImpl value,
          $Res Function(_$TierUpdateRequestImpl) then) =
      __$$TierUpdateRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? nom, String? telephone});
}

/// @nodoc
class __$$TierUpdateRequestImplCopyWithImpl<$Res>
    extends _$TierUpdateRequestCopyWithImpl<$Res, _$TierUpdateRequestImpl>
    implements _$$TierUpdateRequestImplCopyWith<$Res> {
  __$$TierUpdateRequestImplCopyWithImpl(_$TierUpdateRequestImpl _value,
      $Res Function(_$TierUpdateRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of TierUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? nom = freezed,
    Object? telephone = freezed,
  }) {
    return _then(_$TierUpdateRequestImpl(
      nom: freezed == nom
          ? _value.nom
          : nom // ignore: cast_nullable_to_non_nullable
              as String?,
      telephone: freezed == telephone
          ? _value.telephone
          : telephone // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TierUpdateRequestImpl implements _TierUpdateRequest {
  const _$TierUpdateRequestImpl({this.nom, this.telephone});

  factory _$TierUpdateRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$TierUpdateRequestImplFromJson(json);

  @override
  final String? nom;
  @override
  final String? telephone;

  @override
  String toString() {
    return 'TierUpdateRequest(nom: $nom, telephone: $telephone)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TierUpdateRequestImpl &&
            (identical(other.nom, nom) || other.nom == nom) &&
            (identical(other.telephone, telephone) ||
                other.telephone == telephone));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, nom, telephone);

  /// Create a copy of TierUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TierUpdateRequestImplCopyWith<_$TierUpdateRequestImpl> get copyWith =>
      __$$TierUpdateRequestImplCopyWithImpl<_$TierUpdateRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TierUpdateRequestImplToJson(
      this,
    );
  }
}

abstract class _TierUpdateRequest implements TierUpdateRequest {
  const factory _TierUpdateRequest(
      {final String? nom, final String? telephone}) = _$TierUpdateRequestImpl;

  factory _TierUpdateRequest.fromJson(Map<String, dynamic> json) =
      _$TierUpdateRequestImpl.fromJson;

  @override
  String? get nom;
  @override
  String? get telephone;

  /// Create a copy of TierUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TierUpdateRequestImplCopyWith<_$TierUpdateRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PaiementTierRequest _$PaiementTierRequestFromJson(Map<String, dynamic> json) {
  return _PaiementTierRequest.fromJson(json);
}

/// @nodoc
mixin _$PaiementTierRequest {
  double get montant => throw _privateConstructorUsedError;
  String? get motif => throw _privateConstructorUsedError;

  /// Serializes this PaiementTierRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PaiementTierRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PaiementTierRequestCopyWith<PaiementTierRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaiementTierRequestCopyWith<$Res> {
  factory $PaiementTierRequestCopyWith(
          PaiementTierRequest value, $Res Function(PaiementTierRequest) then) =
      _$PaiementTierRequestCopyWithImpl<$Res, PaiementTierRequest>;
  @useResult
  $Res call({double montant, String? motif});
}

/// @nodoc
class _$PaiementTierRequestCopyWithImpl<$Res, $Val extends PaiementTierRequest>
    implements $PaiementTierRequestCopyWith<$Res> {
  _$PaiementTierRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PaiementTierRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? montant = null,
    Object? motif = freezed,
  }) {
    return _then(_value.copyWith(
      montant: null == montant
          ? _value.montant
          : montant // ignore: cast_nullable_to_non_nullable
              as double,
      motif: freezed == motif
          ? _value.motif
          : motif // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PaiementTierRequestImplCopyWith<$Res>
    implements $PaiementTierRequestCopyWith<$Res> {
  factory _$$PaiementTierRequestImplCopyWith(_$PaiementTierRequestImpl value,
          $Res Function(_$PaiementTierRequestImpl) then) =
      __$$PaiementTierRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double montant, String? motif});
}

/// @nodoc
class __$$PaiementTierRequestImplCopyWithImpl<$Res>
    extends _$PaiementTierRequestCopyWithImpl<$Res, _$PaiementTierRequestImpl>
    implements _$$PaiementTierRequestImplCopyWith<$Res> {
  __$$PaiementTierRequestImplCopyWithImpl(_$PaiementTierRequestImpl _value,
      $Res Function(_$PaiementTierRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of PaiementTierRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? montant = null,
    Object? motif = freezed,
  }) {
    return _then(_$PaiementTierRequestImpl(
      montant: null == montant
          ? _value.montant
          : montant // ignore: cast_nullable_to_non_nullable
              as double,
      motif: freezed == motif
          ? _value.motif
          : motif // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PaiementTierRequestImpl implements _PaiementTierRequest {
  const _$PaiementTierRequestImpl({required this.montant, this.motif});

  factory _$PaiementTierRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$PaiementTierRequestImplFromJson(json);

  @override
  final double montant;
  @override
  final String? motif;

  @override
  String toString() {
    return 'PaiementTierRequest(montant: $montant, motif: $motif)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaiementTierRequestImpl &&
            (identical(other.montant, montant) || other.montant == montant) &&
            (identical(other.motif, motif) || other.motif == motif));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, montant, motif);

  /// Create a copy of PaiementTierRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaiementTierRequestImplCopyWith<_$PaiementTierRequestImpl> get copyWith =>
      __$$PaiementTierRequestImplCopyWithImpl<_$PaiementTierRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PaiementTierRequestImplToJson(
      this,
    );
  }
}

abstract class _PaiementTierRequest implements PaiementTierRequest {
  const factory _PaiementTierRequest(
      {required final double montant,
      final String? motif}) = _$PaiementTierRequestImpl;

  factory _PaiementTierRequest.fromJson(Map<String, dynamic> json) =
      _$PaiementTierRequestImpl.fromJson;

  @override
  double get montant;
  @override
  String? get motif;

  /// Create a copy of PaiementTierRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaiementTierRequestImplCopyWith<_$PaiementTierRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
