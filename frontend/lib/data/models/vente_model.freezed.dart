// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vente_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LigneVenteHistorique _$LigneVenteHistoriqueFromJson(Map<String, dynamic> json) {
  return _LigneVenteHistorique.fromJson(json);
}

/// @nodoc
mixin _$LigneVenteHistorique {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'produit_id')
  String? get produitId => throw _privateConstructorUsedError;
  @JsonKey(name: 'produit_nom')
  String? get produitNom => throw _privateConstructorUsedError;
  int get quantite => throw _privateConstructorUsedError;
  @JsonKey(name: 'prix_vendu_reel', fromJson: parseDouble)
  double get prixVenduReel => throw _privateConstructorUsedError;
  @JsonKey(name: 'marge_calculee', fromJson: parseDouble)
  double get margeCalculee => throw _privateConstructorUsedError;
  @JsonKey(name: 'vente_a_perte')
  bool get venteAPerte => throw _privateConstructorUsedError;

  /// Serializes this LigneVenteHistorique to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LigneVenteHistorique
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LigneVenteHistoriqueCopyWith<LigneVenteHistorique> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LigneVenteHistoriqueCopyWith<$Res> {
  factory $LigneVenteHistoriqueCopyWith(LigneVenteHistorique value,
          $Res Function(LigneVenteHistorique) then) =
      _$LigneVenteHistoriqueCopyWithImpl<$Res, LigneVenteHistorique>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'produit_id') String? produitId,
      @JsonKey(name: 'produit_nom') String? produitNom,
      int quantite,
      @JsonKey(name: 'prix_vendu_reel', fromJson: parseDouble)
      double prixVenduReel,
      @JsonKey(name: 'marge_calculee', fromJson: parseDouble)
      double margeCalculee,
      @JsonKey(name: 'vente_a_perte') bool venteAPerte});
}

/// @nodoc
class _$LigneVenteHistoriqueCopyWithImpl<$Res,
        $Val extends LigneVenteHistorique>
    implements $LigneVenteHistoriqueCopyWith<$Res> {
  _$LigneVenteHistoriqueCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LigneVenteHistorique
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? produitId = freezed,
    Object? produitNom = freezed,
    Object? quantite = null,
    Object? prixVenduReel = null,
    Object? margeCalculee = null,
    Object? venteAPerte = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      produitId: freezed == produitId
          ? _value.produitId
          : produitId // ignore: cast_nullable_to_non_nullable
              as String?,
      produitNom: freezed == produitNom
          ? _value.produitNom
          : produitNom // ignore: cast_nullable_to_non_nullable
              as String?,
      quantite: null == quantite
          ? _value.quantite
          : quantite // ignore: cast_nullable_to_non_nullable
              as int,
      prixVenduReel: null == prixVenduReel
          ? _value.prixVenduReel
          : prixVenduReel // ignore: cast_nullable_to_non_nullable
              as double,
      margeCalculee: null == margeCalculee
          ? _value.margeCalculee
          : margeCalculee // ignore: cast_nullable_to_non_nullable
              as double,
      venteAPerte: null == venteAPerte
          ? _value.venteAPerte
          : venteAPerte // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LigneVenteHistoriqueImplCopyWith<$Res>
    implements $LigneVenteHistoriqueCopyWith<$Res> {
  factory _$$LigneVenteHistoriqueImplCopyWith(_$LigneVenteHistoriqueImpl value,
          $Res Function(_$LigneVenteHistoriqueImpl) then) =
      __$$LigneVenteHistoriqueImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'produit_id') String? produitId,
      @JsonKey(name: 'produit_nom') String? produitNom,
      int quantite,
      @JsonKey(name: 'prix_vendu_reel', fromJson: parseDouble)
      double prixVenduReel,
      @JsonKey(name: 'marge_calculee', fromJson: parseDouble)
      double margeCalculee,
      @JsonKey(name: 'vente_a_perte') bool venteAPerte});
}

/// @nodoc
class __$$LigneVenteHistoriqueImplCopyWithImpl<$Res>
    extends _$LigneVenteHistoriqueCopyWithImpl<$Res, _$LigneVenteHistoriqueImpl>
    implements _$$LigneVenteHistoriqueImplCopyWith<$Res> {
  __$$LigneVenteHistoriqueImplCopyWithImpl(_$LigneVenteHistoriqueImpl _value,
      $Res Function(_$LigneVenteHistoriqueImpl) _then)
      : super(_value, _then);

  /// Create a copy of LigneVenteHistorique
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? produitId = freezed,
    Object? produitNom = freezed,
    Object? quantite = null,
    Object? prixVenduReel = null,
    Object? margeCalculee = null,
    Object? venteAPerte = null,
  }) {
    return _then(_$LigneVenteHistoriqueImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      produitId: freezed == produitId
          ? _value.produitId
          : produitId // ignore: cast_nullable_to_non_nullable
              as String?,
      produitNom: freezed == produitNom
          ? _value.produitNom
          : produitNom // ignore: cast_nullable_to_non_nullable
              as String?,
      quantite: null == quantite
          ? _value.quantite
          : quantite // ignore: cast_nullable_to_non_nullable
              as int,
      prixVenduReel: null == prixVenduReel
          ? _value.prixVenduReel
          : prixVenduReel // ignore: cast_nullable_to_non_nullable
              as double,
      margeCalculee: null == margeCalculee
          ? _value.margeCalculee
          : margeCalculee // ignore: cast_nullable_to_non_nullable
              as double,
      venteAPerte: null == venteAPerte
          ? _value.venteAPerte
          : venteAPerte // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LigneVenteHistoriqueImpl implements _LigneVenteHistorique {
  const _$LigneVenteHistoriqueImpl(
      {required this.id,
      @JsonKey(name: 'produit_id') this.produitId,
      @JsonKey(name: 'produit_nom') this.produitNom,
      required this.quantite,
      @JsonKey(name: 'prix_vendu_reel', fromJson: parseDouble)
      required this.prixVenduReel,
      @JsonKey(name: 'marge_calculee', fromJson: parseDouble)
      this.margeCalculee = 0,
      @JsonKey(name: 'vente_a_perte') this.venteAPerte = false});

  factory _$LigneVenteHistoriqueImpl.fromJson(Map<String, dynamic> json) =>
      _$$LigneVenteHistoriqueImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'produit_id')
  final String? produitId;
  @override
  @JsonKey(name: 'produit_nom')
  final String? produitNom;
  @override
  final int quantite;
  @override
  @JsonKey(name: 'prix_vendu_reel', fromJson: parseDouble)
  final double prixVenduReel;
  @override
  @JsonKey(name: 'marge_calculee', fromJson: parseDouble)
  final double margeCalculee;
  @override
  @JsonKey(name: 'vente_a_perte')
  final bool venteAPerte;

  @override
  String toString() {
    return 'LigneVenteHistorique(id: $id, produitId: $produitId, produitNom: $produitNom, quantite: $quantite, prixVenduReel: $prixVenduReel, margeCalculee: $margeCalculee, venteAPerte: $venteAPerte)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LigneVenteHistoriqueImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.produitId, produitId) ||
                other.produitId == produitId) &&
            (identical(other.produitNom, produitNom) ||
                other.produitNom == produitNom) &&
            (identical(other.quantite, quantite) ||
                other.quantite == quantite) &&
            (identical(other.prixVenduReel, prixVenduReel) ||
                other.prixVenduReel == prixVenduReel) &&
            (identical(other.margeCalculee, margeCalculee) ||
                other.margeCalculee == margeCalculee) &&
            (identical(other.venteAPerte, venteAPerte) ||
                other.venteAPerte == venteAPerte));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, produitId, produitNom,
      quantite, prixVenduReel, margeCalculee, venteAPerte);

  /// Create a copy of LigneVenteHistorique
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LigneVenteHistoriqueImplCopyWith<_$LigneVenteHistoriqueImpl>
      get copyWith =>
          __$$LigneVenteHistoriqueImplCopyWithImpl<_$LigneVenteHistoriqueImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LigneVenteHistoriqueImplToJson(
      this,
    );
  }
}

abstract class _LigneVenteHistorique implements LigneVenteHistorique {
  const factory _LigneVenteHistorique(
          {required final String id,
          @JsonKey(name: 'produit_id') final String? produitId,
          @JsonKey(name: 'produit_nom') final String? produitNom,
          required final int quantite,
          @JsonKey(name: 'prix_vendu_reel', fromJson: parseDouble)
          required final double prixVenduReel,
          @JsonKey(name: 'marge_calculee', fromJson: parseDouble)
          final double margeCalculee,
          @JsonKey(name: 'vente_a_perte') final bool venteAPerte}) =
      _$LigneVenteHistoriqueImpl;

  factory _LigneVenteHistorique.fromJson(Map<String, dynamic> json) =
      _$LigneVenteHistoriqueImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'produit_id')
  String? get produitId;
  @override
  @JsonKey(name: 'produit_nom')
  String? get produitNom;
  @override
  int get quantite;
  @override
  @JsonKey(name: 'prix_vendu_reel', fromJson: parseDouble)
  double get prixVenduReel;
  @override
  @JsonKey(name: 'marge_calculee', fromJson: parseDouble)
  double get margeCalculee;
  @override
  @JsonKey(name: 'vente_a_perte')
  bool get venteAPerte;

  /// Create a copy of LigneVenteHistorique
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LigneVenteHistoriqueImplCopyWith<_$LigneVenteHistoriqueImpl>
      get copyWith => throw _privateConstructorUsedError;
}

VenteHistorique _$VenteHistoriqueFromJson(Map<String, dynamic> json) {
  return _VenteHistorique.fromJson(json);
}

/// @nodoc
mixin _$VenteHistorique {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'boutique_id')
  String get boutiqueId => throw _privateConstructorUsedError;
  @JsonKey(name: 'date_vente')
  DateTime get dateVente => throw _privateConstructorUsedError;
  @JsonKey(name: 'montant_total', fromJson: parseDouble)
  double get montantTotal => throw _privateConstructorUsedError;
  @JsonKey(name: 'mode_paiement')
  String get modePaiement => throw _privateConstructorUsedError;
  @JsonKey(name: 'signale_proprietaire')
  bool get signaleProprietaire => throw _privateConstructorUsedError;
  @JsonKey(name: 'tier_id')
  String? get tierId => throw _privateConstructorUsedError;
  @JsonKey(name: 'client_nom')
  String? get clientNom => throw _privateConstructorUsedError;
  List<LigneVenteHistorique> get lignes => throw _privateConstructorUsedError;

  /// Serializes this VenteHistorique to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VenteHistorique
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VenteHistoriqueCopyWith<VenteHistorique> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VenteHistoriqueCopyWith<$Res> {
  factory $VenteHistoriqueCopyWith(
          VenteHistorique value, $Res Function(VenteHistorique) then) =
      _$VenteHistoriqueCopyWithImpl<$Res, VenteHistorique>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'boutique_id') String boutiqueId,
      @JsonKey(name: 'date_vente') DateTime dateVente,
      @JsonKey(name: 'montant_total', fromJson: parseDouble)
      double montantTotal,
      @JsonKey(name: 'mode_paiement') String modePaiement,
      @JsonKey(name: 'signale_proprietaire') bool signaleProprietaire,
      @JsonKey(name: 'tier_id') String? tierId,
      @JsonKey(name: 'client_nom') String? clientNom,
      List<LigneVenteHistorique> lignes});
}

/// @nodoc
class _$VenteHistoriqueCopyWithImpl<$Res, $Val extends VenteHistorique>
    implements $VenteHistoriqueCopyWith<$Res> {
  _$VenteHistoriqueCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VenteHistorique
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? boutiqueId = null,
    Object? dateVente = null,
    Object? montantTotal = null,
    Object? modePaiement = null,
    Object? signaleProprietaire = null,
    Object? tierId = freezed,
    Object? clientNom = freezed,
    Object? lignes = null,
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
      dateVente: null == dateVente
          ? _value.dateVente
          : dateVente // ignore: cast_nullable_to_non_nullable
              as DateTime,
      montantTotal: null == montantTotal
          ? _value.montantTotal
          : montantTotal // ignore: cast_nullable_to_non_nullable
              as double,
      modePaiement: null == modePaiement
          ? _value.modePaiement
          : modePaiement // ignore: cast_nullable_to_non_nullable
              as String,
      signaleProprietaire: null == signaleProprietaire
          ? _value.signaleProprietaire
          : signaleProprietaire // ignore: cast_nullable_to_non_nullable
              as bool,
      tierId: freezed == tierId
          ? _value.tierId
          : tierId // ignore: cast_nullable_to_non_nullable
              as String?,
      clientNom: freezed == clientNom
          ? _value.clientNom
          : clientNom // ignore: cast_nullable_to_non_nullable
              as String?,
      lignes: null == lignes
          ? _value.lignes
          : lignes // ignore: cast_nullable_to_non_nullable
              as List<LigneVenteHistorique>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VenteHistoriqueImplCopyWith<$Res>
    implements $VenteHistoriqueCopyWith<$Res> {
  factory _$$VenteHistoriqueImplCopyWith(_$VenteHistoriqueImpl value,
          $Res Function(_$VenteHistoriqueImpl) then) =
      __$$VenteHistoriqueImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'boutique_id') String boutiqueId,
      @JsonKey(name: 'date_vente') DateTime dateVente,
      @JsonKey(name: 'montant_total', fromJson: parseDouble)
      double montantTotal,
      @JsonKey(name: 'mode_paiement') String modePaiement,
      @JsonKey(name: 'signale_proprietaire') bool signaleProprietaire,
      @JsonKey(name: 'tier_id') String? tierId,
      @JsonKey(name: 'client_nom') String? clientNom,
      List<LigneVenteHistorique> lignes});
}

/// @nodoc
class __$$VenteHistoriqueImplCopyWithImpl<$Res>
    extends _$VenteHistoriqueCopyWithImpl<$Res, _$VenteHistoriqueImpl>
    implements _$$VenteHistoriqueImplCopyWith<$Res> {
  __$$VenteHistoriqueImplCopyWithImpl(
      _$VenteHistoriqueImpl _value, $Res Function(_$VenteHistoriqueImpl) _then)
      : super(_value, _then);

  /// Create a copy of VenteHistorique
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? boutiqueId = null,
    Object? dateVente = null,
    Object? montantTotal = null,
    Object? modePaiement = null,
    Object? signaleProprietaire = null,
    Object? tierId = freezed,
    Object? clientNom = freezed,
    Object? lignes = null,
  }) {
    return _then(_$VenteHistoriqueImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      boutiqueId: null == boutiqueId
          ? _value.boutiqueId
          : boutiqueId // ignore: cast_nullable_to_non_nullable
              as String,
      dateVente: null == dateVente
          ? _value.dateVente
          : dateVente // ignore: cast_nullable_to_non_nullable
              as DateTime,
      montantTotal: null == montantTotal
          ? _value.montantTotal
          : montantTotal // ignore: cast_nullable_to_non_nullable
              as double,
      modePaiement: null == modePaiement
          ? _value.modePaiement
          : modePaiement // ignore: cast_nullable_to_non_nullable
              as String,
      signaleProprietaire: null == signaleProprietaire
          ? _value.signaleProprietaire
          : signaleProprietaire // ignore: cast_nullable_to_non_nullable
              as bool,
      tierId: freezed == tierId
          ? _value.tierId
          : tierId // ignore: cast_nullable_to_non_nullable
              as String?,
      clientNom: freezed == clientNom
          ? _value.clientNom
          : clientNom // ignore: cast_nullable_to_non_nullable
              as String?,
      lignes: null == lignes
          ? _value._lignes
          : lignes // ignore: cast_nullable_to_non_nullable
              as List<LigneVenteHistorique>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VenteHistoriqueImpl implements _VenteHistorique {
  const _$VenteHistoriqueImpl(
      {required this.id,
      @JsonKey(name: 'boutique_id') required this.boutiqueId,
      @JsonKey(name: 'date_vente') required this.dateVente,
      @JsonKey(name: 'montant_total', fromJson: parseDouble)
      required this.montantTotal,
      @JsonKey(name: 'mode_paiement') required this.modePaiement,
      @JsonKey(name: 'signale_proprietaire') this.signaleProprietaire = false,
      @JsonKey(name: 'tier_id') this.tierId,
      @JsonKey(name: 'client_nom') this.clientNom,
      final List<LigneVenteHistorique> lignes = const []})
      : _lignes = lignes;

  factory _$VenteHistoriqueImpl.fromJson(Map<String, dynamic> json) =>
      _$$VenteHistoriqueImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'boutique_id')
  final String boutiqueId;
  @override
  @JsonKey(name: 'date_vente')
  final DateTime dateVente;
  @override
  @JsonKey(name: 'montant_total', fromJson: parseDouble)
  final double montantTotal;
  @override
  @JsonKey(name: 'mode_paiement')
  final String modePaiement;
  @override
  @JsonKey(name: 'signale_proprietaire')
  final bool signaleProprietaire;
  @override
  @JsonKey(name: 'tier_id')
  final String? tierId;
  @override
  @JsonKey(name: 'client_nom')
  final String? clientNom;
  final List<LigneVenteHistorique> _lignes;
  @override
  @JsonKey()
  List<LigneVenteHistorique> get lignes {
    if (_lignes is EqualUnmodifiableListView) return _lignes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_lignes);
  }

  @override
  String toString() {
    return 'VenteHistorique(id: $id, boutiqueId: $boutiqueId, dateVente: $dateVente, montantTotal: $montantTotal, modePaiement: $modePaiement, signaleProprietaire: $signaleProprietaire, tierId: $tierId, clientNom: $clientNom, lignes: $lignes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VenteHistoriqueImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.boutiqueId, boutiqueId) ||
                other.boutiqueId == boutiqueId) &&
            (identical(other.dateVente, dateVente) ||
                other.dateVente == dateVente) &&
            (identical(other.montantTotal, montantTotal) ||
                other.montantTotal == montantTotal) &&
            (identical(other.modePaiement, modePaiement) ||
                other.modePaiement == modePaiement) &&
            (identical(other.signaleProprietaire, signaleProprietaire) ||
                other.signaleProprietaire == signaleProprietaire) &&
            (identical(other.tierId, tierId) || other.tierId == tierId) &&
            (identical(other.clientNom, clientNom) ||
                other.clientNom == clientNom) &&
            const DeepCollectionEquality().equals(other._lignes, _lignes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      boutiqueId,
      dateVente,
      montantTotal,
      modePaiement,
      signaleProprietaire,
      tierId,
      clientNom,
      const DeepCollectionEquality().hash(_lignes));

  /// Create a copy of VenteHistorique
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VenteHistoriqueImplCopyWith<_$VenteHistoriqueImpl> get copyWith =>
      __$$VenteHistoriqueImplCopyWithImpl<_$VenteHistoriqueImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VenteHistoriqueImplToJson(
      this,
    );
  }
}

abstract class _VenteHistorique implements VenteHistorique {
  const factory _VenteHistorique(
      {required final String id,
      @JsonKey(name: 'boutique_id') required final String boutiqueId,
      @JsonKey(name: 'date_vente') required final DateTime dateVente,
      @JsonKey(name: 'montant_total', fromJson: parseDouble)
      required final double montantTotal,
      @JsonKey(name: 'mode_paiement') required final String modePaiement,
      @JsonKey(name: 'signale_proprietaire') final bool signaleProprietaire,
      @JsonKey(name: 'tier_id') final String? tierId,
      @JsonKey(name: 'client_nom') final String? clientNom,
      final List<LigneVenteHistorique> lignes}) = _$VenteHistoriqueImpl;

  factory _VenteHistorique.fromJson(Map<String, dynamic> json) =
      _$VenteHistoriqueImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'boutique_id')
  String get boutiqueId;
  @override
  @JsonKey(name: 'date_vente')
  DateTime get dateVente;
  @override
  @JsonKey(name: 'montant_total', fromJson: parseDouble)
  double get montantTotal;
  @override
  @JsonKey(name: 'mode_paiement')
  String get modePaiement;
  @override
  @JsonKey(name: 'signale_proprietaire')
  bool get signaleProprietaire;
  @override
  @JsonKey(name: 'tier_id')
  String? get tierId;
  @override
  @JsonKey(name: 'client_nom')
  String? get clientNom;
  @override
  List<LigneVenteHistorique> get lignes;

  /// Create a copy of VenteHistorique
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VenteHistoriqueImplCopyWith<_$VenteHistoriqueImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

VenteListResponse _$VenteListResponseFromJson(Map<String, dynamic> json) {
  return _VenteListResponse.fromJson(json);
}

/// @nodoc
mixin _$VenteListResponse {
  int get total => throw _privateConstructorUsedError;
  List<VenteHistorique> get ventes => throw _privateConstructorUsedError;

  /// Serializes this VenteListResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VenteListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VenteListResponseCopyWith<VenteListResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VenteListResponseCopyWith<$Res> {
  factory $VenteListResponseCopyWith(
          VenteListResponse value, $Res Function(VenteListResponse) then) =
      _$VenteListResponseCopyWithImpl<$Res, VenteListResponse>;
  @useResult
  $Res call({int total, List<VenteHistorique> ventes});
}

/// @nodoc
class _$VenteListResponseCopyWithImpl<$Res, $Val extends VenteListResponse>
    implements $VenteListResponseCopyWith<$Res> {
  _$VenteListResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VenteListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? total = null,
    Object? ventes = null,
  }) {
    return _then(_value.copyWith(
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      ventes: null == ventes
          ? _value.ventes
          : ventes // ignore: cast_nullable_to_non_nullable
              as List<VenteHistorique>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VenteListResponseImplCopyWith<$Res>
    implements $VenteListResponseCopyWith<$Res> {
  factory _$$VenteListResponseImplCopyWith(_$VenteListResponseImpl value,
          $Res Function(_$VenteListResponseImpl) then) =
      __$$VenteListResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int total, List<VenteHistorique> ventes});
}

/// @nodoc
class __$$VenteListResponseImplCopyWithImpl<$Res>
    extends _$VenteListResponseCopyWithImpl<$Res, _$VenteListResponseImpl>
    implements _$$VenteListResponseImplCopyWith<$Res> {
  __$$VenteListResponseImplCopyWithImpl(_$VenteListResponseImpl _value,
      $Res Function(_$VenteListResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of VenteListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? total = null,
    Object? ventes = null,
  }) {
    return _then(_$VenteListResponseImpl(
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      ventes: null == ventes
          ? _value._ventes
          : ventes // ignore: cast_nullable_to_non_nullable
              as List<VenteHistorique>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VenteListResponseImpl implements _VenteListResponse {
  const _$VenteListResponseImpl(
      {required this.total, required final List<VenteHistorique> ventes})
      : _ventes = ventes;

  factory _$VenteListResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$VenteListResponseImplFromJson(json);

  @override
  final int total;
  final List<VenteHistorique> _ventes;
  @override
  List<VenteHistorique> get ventes {
    if (_ventes is EqualUnmodifiableListView) return _ventes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_ventes);
  }

  @override
  String toString() {
    return 'VenteListResponse(total: $total, ventes: $ventes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VenteListResponseImpl &&
            (identical(other.total, total) || other.total == total) &&
            const DeepCollectionEquality().equals(other._ventes, _ventes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, total, const DeepCollectionEquality().hash(_ventes));

  /// Create a copy of VenteListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VenteListResponseImplCopyWith<_$VenteListResponseImpl> get copyWith =>
      __$$VenteListResponseImplCopyWithImpl<_$VenteListResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VenteListResponseImplToJson(
      this,
    );
  }
}

abstract class _VenteListResponse implements VenteListResponse {
  const factory _VenteListResponse(
      {required final int total,
      required final List<VenteHistorique> ventes}) = _$VenteListResponseImpl;

  factory _VenteListResponse.fromJson(Map<String, dynamic> json) =
      _$VenteListResponseImpl.fromJson;

  @override
  int get total;
  @override
  List<VenteHistorique> get ventes;

  /// Create a copy of VenteListResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VenteListResponseImplCopyWith<_$VenteListResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
