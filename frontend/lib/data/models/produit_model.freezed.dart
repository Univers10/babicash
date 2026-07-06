// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'produit_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ProduitModel _$ProduitModelFromJson(Map<String, dynamic> json) {
  return _ProduitModel.fromJson(json);
}

/// @nodoc
mixin _$ProduitModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'boutique_id')
  String get boutiqueId => throw _privateConstructorUsedError;
  @JsonKey(name: 'categorie_id')
  String? get categorieId => throw _privateConstructorUsedError;
  String get nom => throw _privateConstructorUsedError;
  @JsonKey(name: 'prix_achat_moyen', fromJson: parseDouble)
  double get prixAchatMoyen => throw _privateConstructorUsedError;
  @JsonKey(name: 'prix_vente_suggere', fromJson: parseDouble)
  double get prixVenteSuggere => throw _privateConstructorUsedError;
  @JsonKey(name: 'stock_actuel')
  int get stockActuel => throw _privateConstructorUsedError;
  @JsonKey(name: 'stock_alerte')
  int get stockAlerte => throw _privateConstructorUsedError;

  /// Serializes this ProduitModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProduitModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProduitModelCopyWith<ProduitModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProduitModelCopyWith<$Res> {
  factory $ProduitModelCopyWith(
          ProduitModel value, $Res Function(ProduitModel) then) =
      _$ProduitModelCopyWithImpl<$Res, ProduitModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'boutique_id') String boutiqueId,
      @JsonKey(name: 'categorie_id') String? categorieId,
      String nom,
      @JsonKey(name: 'prix_achat_moyen', fromJson: parseDouble)
      double prixAchatMoyen,
      @JsonKey(name: 'prix_vente_suggere', fromJson: parseDouble)
      double prixVenteSuggere,
      @JsonKey(name: 'stock_actuel') int stockActuel,
      @JsonKey(name: 'stock_alerte') int stockAlerte});
}

/// @nodoc
class _$ProduitModelCopyWithImpl<$Res, $Val extends ProduitModel>
    implements $ProduitModelCopyWith<$Res> {
  _$ProduitModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProduitModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? boutiqueId = null,
    Object? categorieId = freezed,
    Object? nom = null,
    Object? prixAchatMoyen = null,
    Object? prixVenteSuggere = null,
    Object? stockActuel = null,
    Object? stockAlerte = null,
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
      categorieId: freezed == categorieId
          ? _value.categorieId
          : categorieId // ignore: cast_nullable_to_non_nullable
              as String?,
      nom: null == nom
          ? _value.nom
          : nom // ignore: cast_nullable_to_non_nullable
              as String,
      prixAchatMoyen: null == prixAchatMoyen
          ? _value.prixAchatMoyen
          : prixAchatMoyen // ignore: cast_nullable_to_non_nullable
              as double,
      prixVenteSuggere: null == prixVenteSuggere
          ? _value.prixVenteSuggere
          : prixVenteSuggere // ignore: cast_nullable_to_non_nullable
              as double,
      stockActuel: null == stockActuel
          ? _value.stockActuel
          : stockActuel // ignore: cast_nullable_to_non_nullable
              as int,
      stockAlerte: null == stockAlerte
          ? _value.stockAlerte
          : stockAlerte // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProduitModelImplCopyWith<$Res>
    implements $ProduitModelCopyWith<$Res> {
  factory _$$ProduitModelImplCopyWith(
          _$ProduitModelImpl value, $Res Function(_$ProduitModelImpl) then) =
      __$$ProduitModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'boutique_id') String boutiqueId,
      @JsonKey(name: 'categorie_id') String? categorieId,
      String nom,
      @JsonKey(name: 'prix_achat_moyen', fromJson: parseDouble)
      double prixAchatMoyen,
      @JsonKey(name: 'prix_vente_suggere', fromJson: parseDouble)
      double prixVenteSuggere,
      @JsonKey(name: 'stock_actuel') int stockActuel,
      @JsonKey(name: 'stock_alerte') int stockAlerte});
}

/// @nodoc
class __$$ProduitModelImplCopyWithImpl<$Res>
    extends _$ProduitModelCopyWithImpl<$Res, _$ProduitModelImpl>
    implements _$$ProduitModelImplCopyWith<$Res> {
  __$$ProduitModelImplCopyWithImpl(
      _$ProduitModelImpl _value, $Res Function(_$ProduitModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProduitModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? boutiqueId = null,
    Object? categorieId = freezed,
    Object? nom = null,
    Object? prixAchatMoyen = null,
    Object? prixVenteSuggere = null,
    Object? stockActuel = null,
    Object? stockAlerte = null,
  }) {
    return _then(_$ProduitModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      boutiqueId: null == boutiqueId
          ? _value.boutiqueId
          : boutiqueId // ignore: cast_nullable_to_non_nullable
              as String,
      categorieId: freezed == categorieId
          ? _value.categorieId
          : categorieId // ignore: cast_nullable_to_non_nullable
              as String?,
      nom: null == nom
          ? _value.nom
          : nom // ignore: cast_nullable_to_non_nullable
              as String,
      prixAchatMoyen: null == prixAchatMoyen
          ? _value.prixAchatMoyen
          : prixAchatMoyen // ignore: cast_nullable_to_non_nullable
              as double,
      prixVenteSuggere: null == prixVenteSuggere
          ? _value.prixVenteSuggere
          : prixVenteSuggere // ignore: cast_nullable_to_non_nullable
              as double,
      stockActuel: null == stockActuel
          ? _value.stockActuel
          : stockActuel // ignore: cast_nullable_to_non_nullable
              as int,
      stockAlerte: null == stockAlerte
          ? _value.stockAlerte
          : stockAlerte // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProduitModelImpl implements _ProduitModel {
  const _$ProduitModelImpl(
      {required this.id,
      @JsonKey(name: 'boutique_id') required this.boutiqueId,
      @JsonKey(name: 'categorie_id') this.categorieId,
      required this.nom,
      @JsonKey(name: 'prix_achat_moyen', fromJson: parseDouble)
      required this.prixAchatMoyen,
      @JsonKey(name: 'prix_vente_suggere', fromJson: parseDouble)
      required this.prixVenteSuggere,
      @JsonKey(name: 'stock_actuel') required this.stockActuel,
      @JsonKey(name: 'stock_alerte') required this.stockAlerte});

  factory _$ProduitModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProduitModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'boutique_id')
  final String boutiqueId;
  @override
  @JsonKey(name: 'categorie_id')
  final String? categorieId;
  @override
  final String nom;
  @override
  @JsonKey(name: 'prix_achat_moyen', fromJson: parseDouble)
  final double prixAchatMoyen;
  @override
  @JsonKey(name: 'prix_vente_suggere', fromJson: parseDouble)
  final double prixVenteSuggere;
  @override
  @JsonKey(name: 'stock_actuel')
  final int stockActuel;
  @override
  @JsonKey(name: 'stock_alerte')
  final int stockAlerte;

  @override
  String toString() {
    return 'ProduitModel(id: $id, boutiqueId: $boutiqueId, categorieId: $categorieId, nom: $nom, prixAchatMoyen: $prixAchatMoyen, prixVenteSuggere: $prixVenteSuggere, stockActuel: $stockActuel, stockAlerte: $stockAlerte)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProduitModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.boutiqueId, boutiqueId) ||
                other.boutiqueId == boutiqueId) &&
            (identical(other.categorieId, categorieId) ||
                other.categorieId == categorieId) &&
            (identical(other.nom, nom) || other.nom == nom) &&
            (identical(other.prixAchatMoyen, prixAchatMoyen) ||
                other.prixAchatMoyen == prixAchatMoyen) &&
            (identical(other.prixVenteSuggere, prixVenteSuggere) ||
                other.prixVenteSuggere == prixVenteSuggere) &&
            (identical(other.stockActuel, stockActuel) ||
                other.stockActuel == stockActuel) &&
            (identical(other.stockAlerte, stockAlerte) ||
                other.stockAlerte == stockAlerte));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, boutiqueId, categorieId, nom,
      prixAchatMoyen, prixVenteSuggere, stockActuel, stockAlerte);

  /// Create a copy of ProduitModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProduitModelImplCopyWith<_$ProduitModelImpl> get copyWith =>
      __$$ProduitModelImplCopyWithImpl<_$ProduitModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProduitModelImplToJson(
      this,
    );
  }
}

abstract class _ProduitModel implements ProduitModel {
  const factory _ProduitModel(
          {required final String id,
          @JsonKey(name: 'boutique_id') required final String boutiqueId,
          @JsonKey(name: 'categorie_id') final String? categorieId,
          required final String nom,
          @JsonKey(name: 'prix_achat_moyen', fromJson: parseDouble)
          required final double prixAchatMoyen,
          @JsonKey(name: 'prix_vente_suggere', fromJson: parseDouble)
          required final double prixVenteSuggere,
          @JsonKey(name: 'stock_actuel') required final int stockActuel,
          @JsonKey(name: 'stock_alerte') required final int stockAlerte}) =
      _$ProduitModelImpl;

  factory _ProduitModel.fromJson(Map<String, dynamic> json) =
      _$ProduitModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'boutique_id')
  String get boutiqueId;
  @override
  @JsonKey(name: 'categorie_id')
  String? get categorieId;
  @override
  String get nom;
  @override
  @JsonKey(name: 'prix_achat_moyen', fromJson: parseDouble)
  double get prixAchatMoyen;
  @override
  @JsonKey(name: 'prix_vente_suggere', fromJson: parseDouble)
  double get prixVenteSuggere;
  @override
  @JsonKey(name: 'stock_actuel')
  int get stockActuel;
  @override
  @JsonKey(name: 'stock_alerte')
  int get stockAlerte;

  /// Create a copy of ProduitModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProduitModelImplCopyWith<_$ProduitModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CategorieModel _$CategorieModelFromJson(Map<String, dynamic> json) {
  return _CategorieModel.fromJson(json);
}

/// @nodoc
mixin _$CategorieModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'boutique_id')
  String get boutiqueId => throw _privateConstructorUsedError;
  String get nom => throw _privateConstructorUsedError;

  /// Serializes this CategorieModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CategorieModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CategorieModelCopyWith<CategorieModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CategorieModelCopyWith<$Res> {
  factory $CategorieModelCopyWith(
          CategorieModel value, $Res Function(CategorieModel) then) =
      _$CategorieModelCopyWithImpl<$Res, CategorieModel>;
  @useResult
  $Res call(
      {String id, @JsonKey(name: 'boutique_id') String boutiqueId, String nom});
}

/// @nodoc
class _$CategorieModelCopyWithImpl<$Res, $Val extends CategorieModel>
    implements $CategorieModelCopyWith<$Res> {
  _$CategorieModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CategorieModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? boutiqueId = null,
    Object? nom = null,
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
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CategorieModelImplCopyWith<$Res>
    implements $CategorieModelCopyWith<$Res> {
  factory _$$CategorieModelImplCopyWith(_$CategorieModelImpl value,
          $Res Function(_$CategorieModelImpl) then) =
      __$$CategorieModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id, @JsonKey(name: 'boutique_id') String boutiqueId, String nom});
}

/// @nodoc
class __$$CategorieModelImplCopyWithImpl<$Res>
    extends _$CategorieModelCopyWithImpl<$Res, _$CategorieModelImpl>
    implements _$$CategorieModelImplCopyWith<$Res> {
  __$$CategorieModelImplCopyWithImpl(
      _$CategorieModelImpl _value, $Res Function(_$CategorieModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of CategorieModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? boutiqueId = null,
    Object? nom = null,
  }) {
    return _then(_$CategorieModelImpl(
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
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CategorieModelImpl implements _CategorieModel {
  const _$CategorieModelImpl(
      {required this.id,
      @JsonKey(name: 'boutique_id') required this.boutiqueId,
      required this.nom});

  factory _$CategorieModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CategorieModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'boutique_id')
  final String boutiqueId;
  @override
  final String nom;

  @override
  String toString() {
    return 'CategorieModel(id: $id, boutiqueId: $boutiqueId, nom: $nom)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CategorieModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.boutiqueId, boutiqueId) ||
                other.boutiqueId == boutiqueId) &&
            (identical(other.nom, nom) || other.nom == nom));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, boutiqueId, nom);

  /// Create a copy of CategorieModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CategorieModelImplCopyWith<_$CategorieModelImpl> get copyWith =>
      __$$CategorieModelImplCopyWithImpl<_$CategorieModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CategorieModelImplToJson(
      this,
    );
  }
}

abstract class _CategorieModel implements CategorieModel {
  const factory _CategorieModel(
      {required final String id,
      @JsonKey(name: 'boutique_id') required final String boutiqueId,
      required final String nom}) = _$CategorieModelImpl;

  factory _CategorieModel.fromJson(Map<String, dynamic> json) =
      _$CategorieModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'boutique_id')
  String get boutiqueId;
  @override
  String get nom;

  /// Create a copy of CategorieModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CategorieModelImplCopyWith<_$CategorieModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProduitCreateRequest _$ProduitCreateRequestFromJson(Map<String, dynamic> json) {
  return _ProduitCreateRequest.fromJson(json);
}

/// @nodoc
mixin _$ProduitCreateRequest {
  @JsonKey(name: 'boutique_id')
  String get boutiqueId => throw _privateConstructorUsedError;
  @JsonKey(name: 'categorie_id')
  String? get categorieId => throw _privateConstructorUsedError;
  String get nom => throw _privateConstructorUsedError;
  @JsonKey(name: 'prix_achat_moyen')
  double get prixAchatMoyen => throw _privateConstructorUsedError;
  @JsonKey(name: 'prix_vente_suggere')
  double get prixVenteSuggere => throw _privateConstructorUsedError;
  @JsonKey(name: 'stock_actuel')
  int get stockActuel => throw _privateConstructorUsedError;
  @JsonKey(name: 'stock_alerte')
  int get stockAlerte => throw _privateConstructorUsedError;

  /// Serializes this ProduitCreateRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProduitCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProduitCreateRequestCopyWith<ProduitCreateRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProduitCreateRequestCopyWith<$Res> {
  factory $ProduitCreateRequestCopyWith(ProduitCreateRequest value,
          $Res Function(ProduitCreateRequest) then) =
      _$ProduitCreateRequestCopyWithImpl<$Res, ProduitCreateRequest>;
  @useResult
  $Res call(
      {@JsonKey(name: 'boutique_id') String boutiqueId,
      @JsonKey(name: 'categorie_id') String? categorieId,
      String nom,
      @JsonKey(name: 'prix_achat_moyen') double prixAchatMoyen,
      @JsonKey(name: 'prix_vente_suggere') double prixVenteSuggere,
      @JsonKey(name: 'stock_actuel') int stockActuel,
      @JsonKey(name: 'stock_alerte') int stockAlerte});
}

/// @nodoc
class _$ProduitCreateRequestCopyWithImpl<$Res,
        $Val extends ProduitCreateRequest>
    implements $ProduitCreateRequestCopyWith<$Res> {
  _$ProduitCreateRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProduitCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? boutiqueId = null,
    Object? categorieId = freezed,
    Object? nom = null,
    Object? prixAchatMoyen = null,
    Object? prixVenteSuggere = null,
    Object? stockActuel = null,
    Object? stockAlerte = null,
  }) {
    return _then(_value.copyWith(
      boutiqueId: null == boutiqueId
          ? _value.boutiqueId
          : boutiqueId // ignore: cast_nullable_to_non_nullable
              as String,
      categorieId: freezed == categorieId
          ? _value.categorieId
          : categorieId // ignore: cast_nullable_to_non_nullable
              as String?,
      nom: null == nom
          ? _value.nom
          : nom // ignore: cast_nullable_to_non_nullable
              as String,
      prixAchatMoyen: null == prixAchatMoyen
          ? _value.prixAchatMoyen
          : prixAchatMoyen // ignore: cast_nullable_to_non_nullable
              as double,
      prixVenteSuggere: null == prixVenteSuggere
          ? _value.prixVenteSuggere
          : prixVenteSuggere // ignore: cast_nullable_to_non_nullable
              as double,
      stockActuel: null == stockActuel
          ? _value.stockActuel
          : stockActuel // ignore: cast_nullable_to_non_nullable
              as int,
      stockAlerte: null == stockAlerte
          ? _value.stockAlerte
          : stockAlerte // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProduitCreateRequestImplCopyWith<$Res>
    implements $ProduitCreateRequestCopyWith<$Res> {
  factory _$$ProduitCreateRequestImplCopyWith(_$ProduitCreateRequestImpl value,
          $Res Function(_$ProduitCreateRequestImpl) then) =
      __$$ProduitCreateRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'boutique_id') String boutiqueId,
      @JsonKey(name: 'categorie_id') String? categorieId,
      String nom,
      @JsonKey(name: 'prix_achat_moyen') double prixAchatMoyen,
      @JsonKey(name: 'prix_vente_suggere') double prixVenteSuggere,
      @JsonKey(name: 'stock_actuel') int stockActuel,
      @JsonKey(name: 'stock_alerte') int stockAlerte});
}

/// @nodoc
class __$$ProduitCreateRequestImplCopyWithImpl<$Res>
    extends _$ProduitCreateRequestCopyWithImpl<$Res, _$ProduitCreateRequestImpl>
    implements _$$ProduitCreateRequestImplCopyWith<$Res> {
  __$$ProduitCreateRequestImplCopyWithImpl(_$ProduitCreateRequestImpl _value,
      $Res Function(_$ProduitCreateRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProduitCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? boutiqueId = null,
    Object? categorieId = freezed,
    Object? nom = null,
    Object? prixAchatMoyen = null,
    Object? prixVenteSuggere = null,
    Object? stockActuel = null,
    Object? stockAlerte = null,
  }) {
    return _then(_$ProduitCreateRequestImpl(
      boutiqueId: null == boutiqueId
          ? _value.boutiqueId
          : boutiqueId // ignore: cast_nullable_to_non_nullable
              as String,
      categorieId: freezed == categorieId
          ? _value.categorieId
          : categorieId // ignore: cast_nullable_to_non_nullable
              as String?,
      nom: null == nom
          ? _value.nom
          : nom // ignore: cast_nullable_to_non_nullable
              as String,
      prixAchatMoyen: null == prixAchatMoyen
          ? _value.prixAchatMoyen
          : prixAchatMoyen // ignore: cast_nullable_to_non_nullable
              as double,
      prixVenteSuggere: null == prixVenteSuggere
          ? _value.prixVenteSuggere
          : prixVenteSuggere // ignore: cast_nullable_to_non_nullable
              as double,
      stockActuel: null == stockActuel
          ? _value.stockActuel
          : stockActuel // ignore: cast_nullable_to_non_nullable
              as int,
      stockAlerte: null == stockAlerte
          ? _value.stockAlerte
          : stockAlerte // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProduitCreateRequestImpl implements _ProduitCreateRequest {
  const _$ProduitCreateRequestImpl(
      {@JsonKey(name: 'boutique_id') required this.boutiqueId,
      @JsonKey(name: 'categorie_id') this.categorieId,
      required this.nom,
      @JsonKey(name: 'prix_achat_moyen') required this.prixAchatMoyen,
      @JsonKey(name: 'prix_vente_suggere') required this.prixVenteSuggere,
      @JsonKey(name: 'stock_actuel') required this.stockActuel,
      @JsonKey(name: 'stock_alerte') required this.stockAlerte});

  factory _$ProduitCreateRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProduitCreateRequestImplFromJson(json);

  @override
  @JsonKey(name: 'boutique_id')
  final String boutiqueId;
  @override
  @JsonKey(name: 'categorie_id')
  final String? categorieId;
  @override
  final String nom;
  @override
  @JsonKey(name: 'prix_achat_moyen')
  final double prixAchatMoyen;
  @override
  @JsonKey(name: 'prix_vente_suggere')
  final double prixVenteSuggere;
  @override
  @JsonKey(name: 'stock_actuel')
  final int stockActuel;
  @override
  @JsonKey(name: 'stock_alerte')
  final int stockAlerte;

  @override
  String toString() {
    return 'ProduitCreateRequest(boutiqueId: $boutiqueId, categorieId: $categorieId, nom: $nom, prixAchatMoyen: $prixAchatMoyen, prixVenteSuggere: $prixVenteSuggere, stockActuel: $stockActuel, stockAlerte: $stockAlerte)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProduitCreateRequestImpl &&
            (identical(other.boutiqueId, boutiqueId) ||
                other.boutiqueId == boutiqueId) &&
            (identical(other.categorieId, categorieId) ||
                other.categorieId == categorieId) &&
            (identical(other.nom, nom) || other.nom == nom) &&
            (identical(other.prixAchatMoyen, prixAchatMoyen) ||
                other.prixAchatMoyen == prixAchatMoyen) &&
            (identical(other.prixVenteSuggere, prixVenteSuggere) ||
                other.prixVenteSuggere == prixVenteSuggere) &&
            (identical(other.stockActuel, stockActuel) ||
                other.stockActuel == stockActuel) &&
            (identical(other.stockAlerte, stockAlerte) ||
                other.stockAlerte == stockAlerte));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, boutiqueId, categorieId, nom,
      prixAchatMoyen, prixVenteSuggere, stockActuel, stockAlerte);

  /// Create a copy of ProduitCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProduitCreateRequestImplCopyWith<_$ProduitCreateRequestImpl>
      get copyWith =>
          __$$ProduitCreateRequestImplCopyWithImpl<_$ProduitCreateRequestImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProduitCreateRequestImplToJson(
      this,
    );
  }
}

abstract class _ProduitCreateRequest implements ProduitCreateRequest {
  const factory _ProduitCreateRequest(
      {@JsonKey(name: 'boutique_id') required final String boutiqueId,
      @JsonKey(name: 'categorie_id') final String? categorieId,
      required final String nom,
      @JsonKey(name: 'prix_achat_moyen') required final double prixAchatMoyen,
      @JsonKey(name: 'prix_vente_suggere')
      required final double prixVenteSuggere,
      @JsonKey(name: 'stock_actuel') required final int stockActuel,
      @JsonKey(name: 'stock_alerte')
      required final int stockAlerte}) = _$ProduitCreateRequestImpl;

  factory _ProduitCreateRequest.fromJson(Map<String, dynamic> json) =
      _$ProduitCreateRequestImpl.fromJson;

  @override
  @JsonKey(name: 'boutique_id')
  String get boutiqueId;
  @override
  @JsonKey(name: 'categorie_id')
  String? get categorieId;
  @override
  String get nom;
  @override
  @JsonKey(name: 'prix_achat_moyen')
  double get prixAchatMoyen;
  @override
  @JsonKey(name: 'prix_vente_suggere')
  double get prixVenteSuggere;
  @override
  @JsonKey(name: 'stock_actuel')
  int get stockActuel;
  @override
  @JsonKey(name: 'stock_alerte')
  int get stockAlerte;

  /// Create a copy of ProduitCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProduitCreateRequestImplCopyWith<_$ProduitCreateRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}

ProduitUpdateRequest _$ProduitUpdateRequestFromJson(Map<String, dynamic> json) {
  return _ProduitUpdateRequest.fromJson(json);
}

/// @nodoc
mixin _$ProduitUpdateRequest {
  @JsonKey(name: 'categorie_id')
  String? get categorieId => throw _privateConstructorUsedError;
  String? get nom => throw _privateConstructorUsedError;
  @JsonKey(name: 'prix_achat_moyen')
  double? get prixAchatMoyen => throw _privateConstructorUsedError;
  @JsonKey(name: 'prix_vente_suggere')
  double? get prixVenteSuggere => throw _privateConstructorUsedError;
  @JsonKey(name: 'stock_actuel')
  int? get stockActuel => throw _privateConstructorUsedError;
  @JsonKey(name: 'stock_alerte')
  int? get stockAlerte => throw _privateConstructorUsedError;

  /// Serializes this ProduitUpdateRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProduitUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProduitUpdateRequestCopyWith<ProduitUpdateRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProduitUpdateRequestCopyWith<$Res> {
  factory $ProduitUpdateRequestCopyWith(ProduitUpdateRequest value,
          $Res Function(ProduitUpdateRequest) then) =
      _$ProduitUpdateRequestCopyWithImpl<$Res, ProduitUpdateRequest>;
  @useResult
  $Res call(
      {@JsonKey(name: 'categorie_id') String? categorieId,
      String? nom,
      @JsonKey(name: 'prix_achat_moyen') double? prixAchatMoyen,
      @JsonKey(name: 'prix_vente_suggere') double? prixVenteSuggere,
      @JsonKey(name: 'stock_actuel') int? stockActuel,
      @JsonKey(name: 'stock_alerte') int? stockAlerte});
}

/// @nodoc
class _$ProduitUpdateRequestCopyWithImpl<$Res,
        $Val extends ProduitUpdateRequest>
    implements $ProduitUpdateRequestCopyWith<$Res> {
  _$ProduitUpdateRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProduitUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? categorieId = freezed,
    Object? nom = freezed,
    Object? prixAchatMoyen = freezed,
    Object? prixVenteSuggere = freezed,
    Object? stockActuel = freezed,
    Object? stockAlerte = freezed,
  }) {
    return _then(_value.copyWith(
      categorieId: freezed == categorieId
          ? _value.categorieId
          : categorieId // ignore: cast_nullable_to_non_nullable
              as String?,
      nom: freezed == nom
          ? _value.nom
          : nom // ignore: cast_nullable_to_non_nullable
              as String?,
      prixAchatMoyen: freezed == prixAchatMoyen
          ? _value.prixAchatMoyen
          : prixAchatMoyen // ignore: cast_nullable_to_non_nullable
              as double?,
      prixVenteSuggere: freezed == prixVenteSuggere
          ? _value.prixVenteSuggere
          : prixVenteSuggere // ignore: cast_nullable_to_non_nullable
              as double?,
      stockActuel: freezed == stockActuel
          ? _value.stockActuel
          : stockActuel // ignore: cast_nullable_to_non_nullable
              as int?,
      stockAlerte: freezed == stockAlerte
          ? _value.stockAlerte
          : stockAlerte // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProduitUpdateRequestImplCopyWith<$Res>
    implements $ProduitUpdateRequestCopyWith<$Res> {
  factory _$$ProduitUpdateRequestImplCopyWith(_$ProduitUpdateRequestImpl value,
          $Res Function(_$ProduitUpdateRequestImpl) then) =
      __$$ProduitUpdateRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'categorie_id') String? categorieId,
      String? nom,
      @JsonKey(name: 'prix_achat_moyen') double? prixAchatMoyen,
      @JsonKey(name: 'prix_vente_suggere') double? prixVenteSuggere,
      @JsonKey(name: 'stock_actuel') int? stockActuel,
      @JsonKey(name: 'stock_alerte') int? stockAlerte});
}

/// @nodoc
class __$$ProduitUpdateRequestImplCopyWithImpl<$Res>
    extends _$ProduitUpdateRequestCopyWithImpl<$Res, _$ProduitUpdateRequestImpl>
    implements _$$ProduitUpdateRequestImplCopyWith<$Res> {
  __$$ProduitUpdateRequestImplCopyWithImpl(_$ProduitUpdateRequestImpl _value,
      $Res Function(_$ProduitUpdateRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProduitUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? categorieId = freezed,
    Object? nom = freezed,
    Object? prixAchatMoyen = freezed,
    Object? prixVenteSuggere = freezed,
    Object? stockActuel = freezed,
    Object? stockAlerte = freezed,
  }) {
    return _then(_$ProduitUpdateRequestImpl(
      categorieId: freezed == categorieId
          ? _value.categorieId
          : categorieId // ignore: cast_nullable_to_non_nullable
              as String?,
      nom: freezed == nom
          ? _value.nom
          : nom // ignore: cast_nullable_to_non_nullable
              as String?,
      prixAchatMoyen: freezed == prixAchatMoyen
          ? _value.prixAchatMoyen
          : prixAchatMoyen // ignore: cast_nullable_to_non_nullable
              as double?,
      prixVenteSuggere: freezed == prixVenteSuggere
          ? _value.prixVenteSuggere
          : prixVenteSuggere // ignore: cast_nullable_to_non_nullable
              as double?,
      stockActuel: freezed == stockActuel
          ? _value.stockActuel
          : stockActuel // ignore: cast_nullable_to_non_nullable
              as int?,
      stockAlerte: freezed == stockAlerte
          ? _value.stockAlerte
          : stockAlerte // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProduitUpdateRequestImpl implements _ProduitUpdateRequest {
  const _$ProduitUpdateRequestImpl(
      {@JsonKey(name: 'categorie_id') this.categorieId,
      this.nom,
      @JsonKey(name: 'prix_achat_moyen') this.prixAchatMoyen,
      @JsonKey(name: 'prix_vente_suggere') this.prixVenteSuggere,
      @JsonKey(name: 'stock_actuel') this.stockActuel,
      @JsonKey(name: 'stock_alerte') this.stockAlerte});

  factory _$ProduitUpdateRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProduitUpdateRequestImplFromJson(json);

  @override
  @JsonKey(name: 'categorie_id')
  final String? categorieId;
  @override
  final String? nom;
  @override
  @JsonKey(name: 'prix_achat_moyen')
  final double? prixAchatMoyen;
  @override
  @JsonKey(name: 'prix_vente_suggere')
  final double? prixVenteSuggere;
  @override
  @JsonKey(name: 'stock_actuel')
  final int? stockActuel;
  @override
  @JsonKey(name: 'stock_alerte')
  final int? stockAlerte;

  @override
  String toString() {
    return 'ProduitUpdateRequest(categorieId: $categorieId, nom: $nom, prixAchatMoyen: $prixAchatMoyen, prixVenteSuggere: $prixVenteSuggere, stockActuel: $stockActuel, stockAlerte: $stockAlerte)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProduitUpdateRequestImpl &&
            (identical(other.categorieId, categorieId) ||
                other.categorieId == categorieId) &&
            (identical(other.nom, nom) || other.nom == nom) &&
            (identical(other.prixAchatMoyen, prixAchatMoyen) ||
                other.prixAchatMoyen == prixAchatMoyen) &&
            (identical(other.prixVenteSuggere, prixVenteSuggere) ||
                other.prixVenteSuggere == prixVenteSuggere) &&
            (identical(other.stockActuel, stockActuel) ||
                other.stockActuel == stockActuel) &&
            (identical(other.stockAlerte, stockAlerte) ||
                other.stockAlerte == stockAlerte));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, categorieId, nom, prixAchatMoyen,
      prixVenteSuggere, stockActuel, stockAlerte);

  /// Create a copy of ProduitUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProduitUpdateRequestImplCopyWith<_$ProduitUpdateRequestImpl>
      get copyWith =>
          __$$ProduitUpdateRequestImplCopyWithImpl<_$ProduitUpdateRequestImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProduitUpdateRequestImplToJson(
      this,
    );
  }
}

abstract class _ProduitUpdateRequest implements ProduitUpdateRequest {
  const factory _ProduitUpdateRequest(
          {@JsonKey(name: 'categorie_id') final String? categorieId,
          final String? nom,
          @JsonKey(name: 'prix_achat_moyen') final double? prixAchatMoyen,
          @JsonKey(name: 'prix_vente_suggere') final double? prixVenteSuggere,
          @JsonKey(name: 'stock_actuel') final int? stockActuel,
          @JsonKey(name: 'stock_alerte') final int? stockAlerte}) =
      _$ProduitUpdateRequestImpl;

  factory _ProduitUpdateRequest.fromJson(Map<String, dynamic> json) =
      _$ProduitUpdateRequestImpl.fromJson;

  @override
  @JsonKey(name: 'categorie_id')
  String? get categorieId;
  @override
  String? get nom;
  @override
  @JsonKey(name: 'prix_achat_moyen')
  double? get prixAchatMoyen;
  @override
  @JsonKey(name: 'prix_vente_suggere')
  double? get prixVenteSuggere;
  @override
  @JsonKey(name: 'stock_actuel')
  int? get stockActuel;
  @override
  @JsonKey(name: 'stock_alerte')
  int? get stockAlerte;

  /// Create a copy of ProduitUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProduitUpdateRequestImplCopyWith<_$ProduitUpdateRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}

CategorieCreateRequest _$CategorieCreateRequestFromJson(
    Map<String, dynamic> json) {
  return _CategorieCreateRequest.fromJson(json);
}

/// @nodoc
mixin _$CategorieCreateRequest {
  @JsonKey(name: 'boutique_id')
  String get boutiqueId => throw _privateConstructorUsedError;
  String get nom => throw _privateConstructorUsedError;

  /// Serializes this CategorieCreateRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CategorieCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CategorieCreateRequestCopyWith<CategorieCreateRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CategorieCreateRequestCopyWith<$Res> {
  factory $CategorieCreateRequestCopyWith(CategorieCreateRequest value,
          $Res Function(CategorieCreateRequest) then) =
      _$CategorieCreateRequestCopyWithImpl<$Res, CategorieCreateRequest>;
  @useResult
  $Res call({@JsonKey(name: 'boutique_id') String boutiqueId, String nom});
}

/// @nodoc
class _$CategorieCreateRequestCopyWithImpl<$Res,
        $Val extends CategorieCreateRequest>
    implements $CategorieCreateRequestCopyWith<$Res> {
  _$CategorieCreateRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CategorieCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? boutiqueId = null,
    Object? nom = null,
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
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CategorieCreateRequestImplCopyWith<$Res>
    implements $CategorieCreateRequestCopyWith<$Res> {
  factory _$$CategorieCreateRequestImplCopyWith(
          _$CategorieCreateRequestImpl value,
          $Res Function(_$CategorieCreateRequestImpl) then) =
      __$$CategorieCreateRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({@JsonKey(name: 'boutique_id') String boutiqueId, String nom});
}

/// @nodoc
class __$$CategorieCreateRequestImplCopyWithImpl<$Res>
    extends _$CategorieCreateRequestCopyWithImpl<$Res,
        _$CategorieCreateRequestImpl>
    implements _$$CategorieCreateRequestImplCopyWith<$Res> {
  __$$CategorieCreateRequestImplCopyWithImpl(
      _$CategorieCreateRequestImpl _value,
      $Res Function(_$CategorieCreateRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of CategorieCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? boutiqueId = null,
    Object? nom = null,
  }) {
    return _then(_$CategorieCreateRequestImpl(
      boutiqueId: null == boutiqueId
          ? _value.boutiqueId
          : boutiqueId // ignore: cast_nullable_to_non_nullable
              as String,
      nom: null == nom
          ? _value.nom
          : nom // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CategorieCreateRequestImpl implements _CategorieCreateRequest {
  const _$CategorieCreateRequestImpl(
      {@JsonKey(name: 'boutique_id') required this.boutiqueId,
      required this.nom});

  factory _$CategorieCreateRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CategorieCreateRequestImplFromJson(json);

  @override
  @JsonKey(name: 'boutique_id')
  final String boutiqueId;
  @override
  final String nom;

  @override
  String toString() {
    return 'CategorieCreateRequest(boutiqueId: $boutiqueId, nom: $nom)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CategorieCreateRequestImpl &&
            (identical(other.boutiqueId, boutiqueId) ||
                other.boutiqueId == boutiqueId) &&
            (identical(other.nom, nom) || other.nom == nom));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, boutiqueId, nom);

  /// Create a copy of CategorieCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CategorieCreateRequestImplCopyWith<_$CategorieCreateRequestImpl>
      get copyWith => __$$CategorieCreateRequestImplCopyWithImpl<
          _$CategorieCreateRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CategorieCreateRequestImplToJson(
      this,
    );
  }
}

abstract class _CategorieCreateRequest implements CategorieCreateRequest {
  const factory _CategorieCreateRequest(
      {@JsonKey(name: 'boutique_id') required final String boutiqueId,
      required final String nom}) = _$CategorieCreateRequestImpl;

  factory _CategorieCreateRequest.fromJson(Map<String, dynamic> json) =
      _$CategorieCreateRequestImpl.fromJson;

  @override
  @JsonKey(name: 'boutique_id')
  String get boutiqueId;
  @override
  String get nom;

  /// Create a copy of CategorieCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CategorieCreateRequestImplCopyWith<_$CategorieCreateRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}

CategorieUpdateRequest _$CategorieUpdateRequestFromJson(
    Map<String, dynamic> json) {
  return _CategorieUpdateRequest.fromJson(json);
}

/// @nodoc
mixin _$CategorieUpdateRequest {
  String? get nom => throw _privateConstructorUsedError;

  /// Serializes this CategorieUpdateRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CategorieUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CategorieUpdateRequestCopyWith<CategorieUpdateRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CategorieUpdateRequestCopyWith<$Res> {
  factory $CategorieUpdateRequestCopyWith(CategorieUpdateRequest value,
          $Res Function(CategorieUpdateRequest) then) =
      _$CategorieUpdateRequestCopyWithImpl<$Res, CategorieUpdateRequest>;
  @useResult
  $Res call({String? nom});
}

/// @nodoc
class _$CategorieUpdateRequestCopyWithImpl<$Res,
        $Val extends CategorieUpdateRequest>
    implements $CategorieUpdateRequestCopyWith<$Res> {
  _$CategorieUpdateRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CategorieUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? nom = freezed,
  }) {
    return _then(_value.copyWith(
      nom: freezed == nom
          ? _value.nom
          : nom // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CategorieUpdateRequestImplCopyWith<$Res>
    implements $CategorieUpdateRequestCopyWith<$Res> {
  factory _$$CategorieUpdateRequestImplCopyWith(
          _$CategorieUpdateRequestImpl value,
          $Res Function(_$CategorieUpdateRequestImpl) then) =
      __$$CategorieUpdateRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? nom});
}

/// @nodoc
class __$$CategorieUpdateRequestImplCopyWithImpl<$Res>
    extends _$CategorieUpdateRequestCopyWithImpl<$Res,
        _$CategorieUpdateRequestImpl>
    implements _$$CategorieUpdateRequestImplCopyWith<$Res> {
  __$$CategorieUpdateRequestImplCopyWithImpl(
      _$CategorieUpdateRequestImpl _value,
      $Res Function(_$CategorieUpdateRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of CategorieUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? nom = freezed,
  }) {
    return _then(_$CategorieUpdateRequestImpl(
      nom: freezed == nom
          ? _value.nom
          : nom // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CategorieUpdateRequestImpl implements _CategorieUpdateRequest {
  const _$CategorieUpdateRequestImpl({this.nom});

  factory _$CategorieUpdateRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CategorieUpdateRequestImplFromJson(json);

  @override
  final String? nom;

  @override
  String toString() {
    return 'CategorieUpdateRequest(nom: $nom)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CategorieUpdateRequestImpl &&
            (identical(other.nom, nom) || other.nom == nom));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, nom);

  /// Create a copy of CategorieUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CategorieUpdateRequestImplCopyWith<_$CategorieUpdateRequestImpl>
      get copyWith => __$$CategorieUpdateRequestImplCopyWithImpl<
          _$CategorieUpdateRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CategorieUpdateRequestImplToJson(
      this,
    );
  }
}

abstract class _CategorieUpdateRequest implements CategorieUpdateRequest {
  const factory _CategorieUpdateRequest({final String? nom}) =
      _$CategorieUpdateRequestImpl;

  factory _CategorieUpdateRequest.fromJson(Map<String, dynamic> json) =
      _$CategorieUpdateRequestImpl.fromJson;

  @override
  String? get nom;

  /// Create a copy of CategorieUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CategorieUpdateRequestImplCopyWith<_$CategorieUpdateRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}
