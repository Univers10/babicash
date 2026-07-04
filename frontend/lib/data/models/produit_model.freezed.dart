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
  @JsonKey(name: 'prix_achat_moyen')
  double get prixAchatMoyen => throw _privateConstructorUsedError;
  @JsonKey(name: 'prix_vente_suggere')
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
      @JsonKey(name: 'prix_achat_moyen') double prixAchatMoyen,
      @JsonKey(name: 'prix_vente_suggere') double prixVenteSuggere,
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
      @JsonKey(name: 'prix_achat_moyen') double prixAchatMoyen,
      @JsonKey(name: 'prix_vente_suggere') double prixVenteSuggere,
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
      @JsonKey(name: 'prix_achat_moyen') required this.prixAchatMoyen,
      @JsonKey(name: 'prix_vente_suggere') required this.prixVenteSuggere,
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
      @JsonKey(name: 'prix_achat_moyen') required final double prixAchatMoyen,
      @JsonKey(name: 'prix_vente_suggere')
      required final double prixVenteSuggere,
      @JsonKey(name: 'stock_actuel') required final int stockActuel,
      @JsonKey(name: 'stock_alerte')
      required final int stockAlerte}) = _$ProduitModelImpl;

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
