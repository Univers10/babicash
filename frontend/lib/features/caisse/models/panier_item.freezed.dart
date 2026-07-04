// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'panier_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PanierItem {
  String? get produitId => throw _privateConstructorUsedError;
  String get nom => throw _privateConstructorUsedError;
  double get prixUnitaire => throw _privateConstructorUsedError;
  double get prixAchat => throw _privateConstructorUsedError;
  int get quantite => throw _privateConstructorUsedError;

  /// Create a copy of PanierItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PanierItemCopyWith<PanierItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PanierItemCopyWith<$Res> {
  factory $PanierItemCopyWith(
          PanierItem value, $Res Function(PanierItem) then) =
      _$PanierItemCopyWithImpl<$Res, PanierItem>;
  @useResult
  $Res call(
      {String? produitId,
      String nom,
      double prixUnitaire,
      double prixAchat,
      int quantite});
}

/// @nodoc
class _$PanierItemCopyWithImpl<$Res, $Val extends PanierItem>
    implements $PanierItemCopyWith<$Res> {
  _$PanierItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PanierItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? produitId = freezed,
    Object? nom = null,
    Object? prixUnitaire = null,
    Object? prixAchat = null,
    Object? quantite = null,
  }) {
    return _then(_value.copyWith(
      produitId: freezed == produitId
          ? _value.produitId
          : produitId // ignore: cast_nullable_to_non_nullable
              as String?,
      nom: null == nom
          ? _value.nom
          : nom // ignore: cast_nullable_to_non_nullable
              as String,
      prixUnitaire: null == prixUnitaire
          ? _value.prixUnitaire
          : prixUnitaire // ignore: cast_nullable_to_non_nullable
              as double,
      prixAchat: null == prixAchat
          ? _value.prixAchat
          : prixAchat // ignore: cast_nullable_to_non_nullable
              as double,
      quantite: null == quantite
          ? _value.quantite
          : quantite // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PanierItemImplCopyWith<$Res>
    implements $PanierItemCopyWith<$Res> {
  factory _$$PanierItemImplCopyWith(
          _$PanierItemImpl value, $Res Function(_$PanierItemImpl) then) =
      __$$PanierItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? produitId,
      String nom,
      double prixUnitaire,
      double prixAchat,
      int quantite});
}

/// @nodoc
class __$$PanierItemImplCopyWithImpl<$Res>
    extends _$PanierItemCopyWithImpl<$Res, _$PanierItemImpl>
    implements _$$PanierItemImplCopyWith<$Res> {
  __$$PanierItemImplCopyWithImpl(
      _$PanierItemImpl _value, $Res Function(_$PanierItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of PanierItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? produitId = freezed,
    Object? nom = null,
    Object? prixUnitaire = null,
    Object? prixAchat = null,
    Object? quantite = null,
  }) {
    return _then(_$PanierItemImpl(
      produitId: freezed == produitId
          ? _value.produitId
          : produitId // ignore: cast_nullable_to_non_nullable
              as String?,
      nom: null == nom
          ? _value.nom
          : nom // ignore: cast_nullable_to_non_nullable
              as String,
      prixUnitaire: null == prixUnitaire
          ? _value.prixUnitaire
          : prixUnitaire // ignore: cast_nullable_to_non_nullable
              as double,
      prixAchat: null == prixAchat
          ? _value.prixAchat
          : prixAchat // ignore: cast_nullable_to_non_nullable
              as double,
      quantite: null == quantite
          ? _value.quantite
          : quantite // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$PanierItemImpl extends _PanierItem {
  const _$PanierItemImpl(
      {this.produitId,
      required this.nom,
      required this.prixUnitaire,
      required this.prixAchat,
      this.quantite = 1})
      : super._();

  @override
  final String? produitId;
  @override
  final String nom;
  @override
  final double prixUnitaire;
  @override
  final double prixAchat;
  @override
  @JsonKey()
  final int quantite;

  @override
  String toString() {
    return 'PanierItem(produitId: $produitId, nom: $nom, prixUnitaire: $prixUnitaire, prixAchat: $prixAchat, quantite: $quantite)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PanierItemImpl &&
            (identical(other.produitId, produitId) ||
                other.produitId == produitId) &&
            (identical(other.nom, nom) || other.nom == nom) &&
            (identical(other.prixUnitaire, prixUnitaire) ||
                other.prixUnitaire == prixUnitaire) &&
            (identical(other.prixAchat, prixAchat) ||
                other.prixAchat == prixAchat) &&
            (identical(other.quantite, quantite) ||
                other.quantite == quantite));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, produitId, nom, prixUnitaire, prixAchat, quantite);

  /// Create a copy of PanierItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PanierItemImplCopyWith<_$PanierItemImpl> get copyWith =>
      __$$PanierItemImplCopyWithImpl<_$PanierItemImpl>(this, _$identity);
}

abstract class _PanierItem extends PanierItem {
  const factory _PanierItem(
      {final String? produitId,
      required final String nom,
      required final double prixUnitaire,
      required final double prixAchat,
      final int quantite}) = _$PanierItemImpl;
  const _PanierItem._() : super._();

  @override
  String? get produitId;
  @override
  String get nom;
  @override
  double get prixUnitaire;
  @override
  double get prixAchat;
  @override
  int get quantite;

  /// Create a copy of PanierItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PanierItemImplCopyWith<_$PanierItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
