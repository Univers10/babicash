// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'boutique_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BoutiqueModel _$BoutiqueModelFromJson(Map<String, dynamic> json) {
  return _BoutiqueModel.fromJson(json);
}

/// @nodoc
mixin _$BoutiqueModel {
  String get id => throw _privateConstructorUsedError;
  String get nom => throw _privateConstructorUsedError;
  @JsonKey(name: 'proprietaire_id')
  String get proprietaireId => throw _privateConstructorUsedError;
  String? get adresse => throw _privateConstructorUsedError;
  String? get telephone => throw _privateConstructorUsedError;
  @JsonKey(name: 'type_commerce')
  String? get typeCommerce => throw _privateConstructorUsedError;
  @JsonKey(name: 'logo_url')
  String? get logoUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'date_creation')
  DateTime get dateCreation => throw _privateConstructorUsedError;

  /// Serializes this BoutiqueModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BoutiqueModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BoutiqueModelCopyWith<BoutiqueModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BoutiqueModelCopyWith<$Res> {
  factory $BoutiqueModelCopyWith(
          BoutiqueModel value, $Res Function(BoutiqueModel) then) =
      _$BoutiqueModelCopyWithImpl<$Res, BoutiqueModel>;
  @useResult
  $Res call(
      {String id,
      String nom,
      @JsonKey(name: 'proprietaire_id') String proprietaireId,
      String? adresse,
      String? telephone,
      @JsonKey(name: 'type_commerce') String? typeCommerce,
      @JsonKey(name: 'logo_url') String? logoUrl,
      @JsonKey(name: 'date_creation') DateTime dateCreation});
}

/// @nodoc
class _$BoutiqueModelCopyWithImpl<$Res, $Val extends BoutiqueModel>
    implements $BoutiqueModelCopyWith<$Res> {
  _$BoutiqueModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BoutiqueModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nom = null,
    Object? proprietaireId = null,
    Object? adresse = freezed,
    Object? telephone = freezed,
    Object? typeCommerce = freezed,
    Object? logoUrl = freezed,
    Object? dateCreation = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      nom: null == nom
          ? _value.nom
          : nom // ignore: cast_nullable_to_non_nullable
              as String,
      proprietaireId: null == proprietaireId
          ? _value.proprietaireId
          : proprietaireId // ignore: cast_nullable_to_non_nullable
              as String,
      adresse: freezed == adresse
          ? _value.adresse
          : adresse // ignore: cast_nullable_to_non_nullable
              as String?,
      telephone: freezed == telephone
          ? _value.telephone
          : telephone // ignore: cast_nullable_to_non_nullable
              as String?,
      typeCommerce: freezed == typeCommerce
          ? _value.typeCommerce
          : typeCommerce // ignore: cast_nullable_to_non_nullable
              as String?,
      logoUrl: freezed == logoUrl
          ? _value.logoUrl
          : logoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      dateCreation: null == dateCreation
          ? _value.dateCreation
          : dateCreation // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BoutiqueModelImplCopyWith<$Res>
    implements $BoutiqueModelCopyWith<$Res> {
  factory _$$BoutiqueModelImplCopyWith(
          _$BoutiqueModelImpl value, $Res Function(_$BoutiqueModelImpl) then) =
      __$$BoutiqueModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String nom,
      @JsonKey(name: 'proprietaire_id') String proprietaireId,
      String? adresse,
      String? telephone,
      @JsonKey(name: 'type_commerce') String? typeCommerce,
      @JsonKey(name: 'logo_url') String? logoUrl,
      @JsonKey(name: 'date_creation') DateTime dateCreation});
}

/// @nodoc
class __$$BoutiqueModelImplCopyWithImpl<$Res>
    extends _$BoutiqueModelCopyWithImpl<$Res, _$BoutiqueModelImpl>
    implements _$$BoutiqueModelImplCopyWith<$Res> {
  __$$BoutiqueModelImplCopyWithImpl(
      _$BoutiqueModelImpl _value, $Res Function(_$BoutiqueModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of BoutiqueModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nom = null,
    Object? proprietaireId = null,
    Object? adresse = freezed,
    Object? telephone = freezed,
    Object? typeCommerce = freezed,
    Object? logoUrl = freezed,
    Object? dateCreation = null,
  }) {
    return _then(_$BoutiqueModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      nom: null == nom
          ? _value.nom
          : nom // ignore: cast_nullable_to_non_nullable
              as String,
      proprietaireId: null == proprietaireId
          ? _value.proprietaireId
          : proprietaireId // ignore: cast_nullable_to_non_nullable
              as String,
      adresse: freezed == adresse
          ? _value.adresse
          : adresse // ignore: cast_nullable_to_non_nullable
              as String?,
      telephone: freezed == telephone
          ? _value.telephone
          : telephone // ignore: cast_nullable_to_non_nullable
              as String?,
      typeCommerce: freezed == typeCommerce
          ? _value.typeCommerce
          : typeCommerce // ignore: cast_nullable_to_non_nullable
              as String?,
      logoUrl: freezed == logoUrl
          ? _value.logoUrl
          : logoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      dateCreation: null == dateCreation
          ? _value.dateCreation
          : dateCreation // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BoutiqueModelImpl implements _BoutiqueModel {
  const _$BoutiqueModelImpl(
      {required this.id,
      required this.nom,
      @JsonKey(name: 'proprietaire_id') required this.proprietaireId,
      this.adresse,
      this.telephone,
      @JsonKey(name: 'type_commerce') this.typeCommerce,
      @JsonKey(name: 'logo_url') this.logoUrl,
      @JsonKey(name: 'date_creation') required this.dateCreation});

  factory _$BoutiqueModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$BoutiqueModelImplFromJson(json);

  @override
  final String id;
  @override
  final String nom;
  @override
  @JsonKey(name: 'proprietaire_id')
  final String proprietaireId;
  @override
  final String? adresse;
  @override
  final String? telephone;
  @override
  @JsonKey(name: 'type_commerce')
  final String? typeCommerce;
  @override
  @JsonKey(name: 'logo_url')
  final String? logoUrl;
  @override
  @JsonKey(name: 'date_creation')
  final DateTime dateCreation;

  @override
  String toString() {
    return 'BoutiqueModel(id: $id, nom: $nom, proprietaireId: $proprietaireId, adresse: $adresse, telephone: $telephone, typeCommerce: $typeCommerce, logoUrl: $logoUrl, dateCreation: $dateCreation)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BoutiqueModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nom, nom) || other.nom == nom) &&
            (identical(other.proprietaireId, proprietaireId) ||
                other.proprietaireId == proprietaireId) &&
            (identical(other.adresse, adresse) || other.adresse == adresse) &&
            (identical(other.telephone, telephone) ||
                other.telephone == telephone) &&
            (identical(other.typeCommerce, typeCommerce) ||
                other.typeCommerce == typeCommerce) &&
            (identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl) &&
            (identical(other.dateCreation, dateCreation) ||
                other.dateCreation == dateCreation));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, nom, proprietaireId, adresse,
      telephone, typeCommerce, logoUrl, dateCreation);

  /// Create a copy of BoutiqueModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BoutiqueModelImplCopyWith<_$BoutiqueModelImpl> get copyWith =>
      __$$BoutiqueModelImplCopyWithImpl<_$BoutiqueModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BoutiqueModelImplToJson(
      this,
    );
  }
}

abstract class _BoutiqueModel implements BoutiqueModel {
  const factory _BoutiqueModel(
      {required final String id,
      required final String nom,
      @JsonKey(name: 'proprietaire_id') required final String proprietaireId,
      final String? adresse,
      final String? telephone,
      @JsonKey(name: 'type_commerce') final String? typeCommerce,
      @JsonKey(name: 'logo_url') final String? logoUrl,
      @JsonKey(name: 'date_creation')
      required final DateTime dateCreation}) = _$BoutiqueModelImpl;

  factory _BoutiqueModel.fromJson(Map<String, dynamic> json) =
      _$BoutiqueModelImpl.fromJson;

  @override
  String get id;
  @override
  String get nom;
  @override
  @JsonKey(name: 'proprietaire_id')
  String get proprietaireId;
  @override
  String? get adresse;
  @override
  String? get telephone;
  @override
  @JsonKey(name: 'type_commerce')
  String? get typeCommerce;
  @override
  @JsonKey(name: 'logo_url')
  String? get logoUrl;
  @override
  @JsonKey(name: 'date_creation')
  DateTime get dateCreation;

  /// Create a copy of BoutiqueModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BoutiqueModelImplCopyWith<_$BoutiqueModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
