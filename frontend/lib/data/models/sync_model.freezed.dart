// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sync_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LigneVenteIn _$LigneVenteInFromJson(Map<String, dynamic> json) {
  return _LigneVenteIn.fromJson(json);
}

/// @nodoc
mixin _$LigneVenteIn {
  @JsonKey(name: 'produit_id')
  String? get produitId => throw _privateConstructorUsedError;
  int get quantite => throw _privateConstructorUsedError;
  @JsonKey(name: 'prix_vendu_reel')
  double get prixVenduReel => throw _privateConstructorUsedError;
  @JsonKey(name: 'lot_id')
  String? get lotId => throw _privateConstructorUsedError;
  @JsonKey(name: 'lot_nom')
  String? get lotNom => throw _privateConstructorUsedError;

  /// Serializes this LigneVenteIn to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LigneVenteIn
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LigneVenteInCopyWith<LigneVenteIn> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LigneVenteInCopyWith<$Res> {
  factory $LigneVenteInCopyWith(
          LigneVenteIn value, $Res Function(LigneVenteIn) then) =
      _$LigneVenteInCopyWithImpl<$Res, LigneVenteIn>;
  @useResult
  $Res call(
      {@JsonKey(name: 'produit_id') String? produitId,
      int quantite,
      @JsonKey(name: 'prix_vendu_reel') double prixVenduReel,
      @JsonKey(name: 'lot_id') String? lotId,
      @JsonKey(name: 'lot_nom') String? lotNom});
}

/// @nodoc
class _$LigneVenteInCopyWithImpl<$Res, $Val extends LigneVenteIn>
    implements $LigneVenteInCopyWith<$Res> {
  _$LigneVenteInCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LigneVenteIn
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? produitId = freezed,
    Object? quantite = null,
    Object? prixVenduReel = null,
    Object? lotId = freezed,
    Object? lotNom = freezed,
  }) {
    return _then(_value.copyWith(
      produitId: freezed == produitId
          ? _value.produitId
          : produitId // ignore: cast_nullable_to_non_nullable
              as String?,
      quantite: null == quantite
          ? _value.quantite
          : quantite // ignore: cast_nullable_to_non_nullable
              as int,
      prixVenduReel: null == prixVenduReel
          ? _value.prixVenduReel
          : prixVenduReel // ignore: cast_nullable_to_non_nullable
              as double,
      lotId: freezed == lotId
          ? _value.lotId
          : lotId // ignore: cast_nullable_to_non_nullable
              as String?,
      lotNom: freezed == lotNom
          ? _value.lotNom
          : lotNom // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LigneVenteInImplCopyWith<$Res>
    implements $LigneVenteInCopyWith<$Res> {
  factory _$$LigneVenteInImplCopyWith(
          _$LigneVenteInImpl value, $Res Function(_$LigneVenteInImpl) then) =
      __$$LigneVenteInImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'produit_id') String? produitId,
      int quantite,
      @JsonKey(name: 'prix_vendu_reel') double prixVenduReel,
      @JsonKey(name: 'lot_id') String? lotId,
      @JsonKey(name: 'lot_nom') String? lotNom});
}

/// @nodoc
class __$$LigneVenteInImplCopyWithImpl<$Res>
    extends _$LigneVenteInCopyWithImpl<$Res, _$LigneVenteInImpl>
    implements _$$LigneVenteInImplCopyWith<$Res> {
  __$$LigneVenteInImplCopyWithImpl(
      _$LigneVenteInImpl _value, $Res Function(_$LigneVenteInImpl) _then)
      : super(_value, _then);

  /// Create a copy of LigneVenteIn
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? produitId = freezed,
    Object? quantite = null,
    Object? prixVenduReel = null,
    Object? lotId = freezed,
    Object? lotNom = freezed,
  }) {
    return _then(_$LigneVenteInImpl(
      produitId: freezed == produitId
          ? _value.produitId
          : produitId // ignore: cast_nullable_to_non_nullable
              as String?,
      quantite: null == quantite
          ? _value.quantite
          : quantite // ignore: cast_nullable_to_non_nullable
              as int,
      prixVenduReel: null == prixVenduReel
          ? _value.prixVenduReel
          : prixVenduReel // ignore: cast_nullable_to_non_nullable
              as double,
      lotId: freezed == lotId
          ? _value.lotId
          : lotId // ignore: cast_nullable_to_non_nullable
              as String?,
      lotNom: freezed == lotNom
          ? _value.lotNom
          : lotNom // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LigneVenteInImpl implements _LigneVenteIn {
  const _$LigneVenteInImpl(
      {@JsonKey(name: 'produit_id') this.produitId,
      this.quantite = 1,
      @JsonKey(name: 'prix_vendu_reel') required this.prixVenduReel,
      @JsonKey(name: 'lot_id') this.lotId,
      @JsonKey(name: 'lot_nom') this.lotNom});

  factory _$LigneVenteInImpl.fromJson(Map<String, dynamic> json) =>
      _$$LigneVenteInImplFromJson(json);

  @override
  @JsonKey(name: 'produit_id')
  final String? produitId;
  @override
  @JsonKey()
  final int quantite;
  @override
  @JsonKey(name: 'prix_vendu_reel')
  final double prixVenduReel;
  @override
  @JsonKey(name: 'lot_id')
  final String? lotId;
  @override
  @JsonKey(name: 'lot_nom')
  final String? lotNom;

  @override
  String toString() {
    return 'LigneVenteIn(produitId: $produitId, quantite: $quantite, prixVenduReel: $prixVenduReel, lotId: $lotId, lotNom: $lotNom)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LigneVenteInImpl &&
            (identical(other.produitId, produitId) ||
                other.produitId == produitId) &&
            (identical(other.quantite, quantite) ||
                other.quantite == quantite) &&
            (identical(other.prixVenduReel, prixVenduReel) ||
                other.prixVenduReel == prixVenduReel) &&
            (identical(other.lotId, lotId) || other.lotId == lotId) &&
            (identical(other.lotNom, lotNom) || other.lotNom == lotNom));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, produitId, quantite, prixVenduReel, lotId, lotNom);

  /// Create a copy of LigneVenteIn
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LigneVenteInImplCopyWith<_$LigneVenteInImpl> get copyWith =>
      __$$LigneVenteInImplCopyWithImpl<_$LigneVenteInImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LigneVenteInImplToJson(
      this,
    );
  }
}

abstract class _LigneVenteIn implements LigneVenteIn {
  const factory _LigneVenteIn(
      {@JsonKey(name: 'produit_id') final String? produitId,
      final int quantite,
      @JsonKey(name: 'prix_vendu_reel') required final double prixVenduReel,
      @JsonKey(name: 'lot_id') final String? lotId,
      @JsonKey(name: 'lot_nom') final String? lotNom}) = _$LigneVenteInImpl;

  factory _LigneVenteIn.fromJson(Map<String, dynamic> json) =
      _$LigneVenteInImpl.fromJson;

  @override
  @JsonKey(name: 'produit_id')
  String? get produitId;
  @override
  int get quantite;
  @override
  @JsonKey(name: 'prix_vendu_reel')
  double get prixVenduReel;
  @override
  @JsonKey(name: 'lot_id')
  String? get lotId;
  @override
  @JsonKey(name: 'lot_nom')
  String? get lotNom;

  /// Create a copy of LigneVenteIn
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LigneVenteInImplCopyWith<_$LigneVenteInImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

VenteIn _$VenteInFromJson(Map<String, dynamic> json) {
  return _VenteIn.fromJson(json);
}

/// @nodoc
mixin _$VenteIn {
  @JsonKey(name: 'id_local_smartphone')
  String get idLocal => throw _privateConstructorUsedError;
  @JsonKey(name: 'session_id')
  String? get sessionId => throw _privateConstructorUsedError;
  @JsonKey(name: 'tier_id')
  String? get tierId => throw _privateConstructorUsedError;
  @JsonKey(name: 'date_vente')
  DateTime? get dateVente => throw _privateConstructorUsedError;
  @JsonKey(name: 'mode_paiement')
  String get modePaiement => throw _privateConstructorUsedError;
  List<LigneVenteIn> get lignes => throw _privateConstructorUsedError;

  /// Serializes this VenteIn to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VenteIn
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VenteInCopyWith<VenteIn> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VenteInCopyWith<$Res> {
  factory $VenteInCopyWith(VenteIn value, $Res Function(VenteIn) then) =
      _$VenteInCopyWithImpl<$Res, VenteIn>;
  @useResult
  $Res call(
      {@JsonKey(name: 'id_local_smartphone') String idLocal,
      @JsonKey(name: 'session_id') String? sessionId,
      @JsonKey(name: 'tier_id') String? tierId,
      @JsonKey(name: 'date_vente') DateTime? dateVente,
      @JsonKey(name: 'mode_paiement') String modePaiement,
      List<LigneVenteIn> lignes});
}

/// @nodoc
class _$VenteInCopyWithImpl<$Res, $Val extends VenteIn>
    implements $VenteInCopyWith<$Res> {
  _$VenteInCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VenteIn
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? idLocal = null,
    Object? sessionId = freezed,
    Object? tierId = freezed,
    Object? dateVente = freezed,
    Object? modePaiement = null,
    Object? lignes = null,
  }) {
    return _then(_value.copyWith(
      idLocal: null == idLocal
          ? _value.idLocal
          : idLocal // ignore: cast_nullable_to_non_nullable
              as String,
      sessionId: freezed == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String?,
      tierId: freezed == tierId
          ? _value.tierId
          : tierId // ignore: cast_nullable_to_non_nullable
              as String?,
      dateVente: freezed == dateVente
          ? _value.dateVente
          : dateVente // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      modePaiement: null == modePaiement
          ? _value.modePaiement
          : modePaiement // ignore: cast_nullable_to_non_nullable
              as String,
      lignes: null == lignes
          ? _value.lignes
          : lignes // ignore: cast_nullable_to_non_nullable
              as List<LigneVenteIn>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VenteInImplCopyWith<$Res> implements $VenteInCopyWith<$Res> {
  factory _$$VenteInImplCopyWith(
          _$VenteInImpl value, $Res Function(_$VenteInImpl) then) =
      __$$VenteInImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'id_local_smartphone') String idLocal,
      @JsonKey(name: 'session_id') String? sessionId,
      @JsonKey(name: 'tier_id') String? tierId,
      @JsonKey(name: 'date_vente') DateTime? dateVente,
      @JsonKey(name: 'mode_paiement') String modePaiement,
      List<LigneVenteIn> lignes});
}

/// @nodoc
class __$$VenteInImplCopyWithImpl<$Res>
    extends _$VenteInCopyWithImpl<$Res, _$VenteInImpl>
    implements _$$VenteInImplCopyWith<$Res> {
  __$$VenteInImplCopyWithImpl(
      _$VenteInImpl _value, $Res Function(_$VenteInImpl) _then)
      : super(_value, _then);

  /// Create a copy of VenteIn
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? idLocal = null,
    Object? sessionId = freezed,
    Object? tierId = freezed,
    Object? dateVente = freezed,
    Object? modePaiement = null,
    Object? lignes = null,
  }) {
    return _then(_$VenteInImpl(
      idLocal: null == idLocal
          ? _value.idLocal
          : idLocal // ignore: cast_nullable_to_non_nullable
              as String,
      sessionId: freezed == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String?,
      tierId: freezed == tierId
          ? _value.tierId
          : tierId // ignore: cast_nullable_to_non_nullable
              as String?,
      dateVente: freezed == dateVente
          ? _value.dateVente
          : dateVente // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      modePaiement: null == modePaiement
          ? _value.modePaiement
          : modePaiement // ignore: cast_nullable_to_non_nullable
              as String,
      lignes: null == lignes
          ? _value._lignes
          : lignes // ignore: cast_nullable_to_non_nullable
              as List<LigneVenteIn>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VenteInImpl implements _VenteIn {
  const _$VenteInImpl(
      {@JsonKey(name: 'id_local_smartphone') required this.idLocal,
      @JsonKey(name: 'session_id') this.sessionId,
      @JsonKey(name: 'tier_id') this.tierId,
      @JsonKey(name: 'date_vente') this.dateVente,
      @JsonKey(name: 'mode_paiement') required this.modePaiement,
      required final List<LigneVenteIn> lignes})
      : _lignes = lignes;

  factory _$VenteInImpl.fromJson(Map<String, dynamic> json) =>
      _$$VenteInImplFromJson(json);

  @override
  @JsonKey(name: 'id_local_smartphone')
  final String idLocal;
  @override
  @JsonKey(name: 'session_id')
  final String? sessionId;
  @override
  @JsonKey(name: 'tier_id')
  final String? tierId;
  @override
  @JsonKey(name: 'date_vente')
  final DateTime? dateVente;
  @override
  @JsonKey(name: 'mode_paiement')
  final String modePaiement;
  final List<LigneVenteIn> _lignes;
  @override
  List<LigneVenteIn> get lignes {
    if (_lignes is EqualUnmodifiableListView) return _lignes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_lignes);
  }

  @override
  String toString() {
    return 'VenteIn(idLocal: $idLocal, sessionId: $sessionId, tierId: $tierId, dateVente: $dateVente, modePaiement: $modePaiement, lignes: $lignes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VenteInImpl &&
            (identical(other.idLocal, idLocal) || other.idLocal == idLocal) &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.tierId, tierId) || other.tierId == tierId) &&
            (identical(other.dateVente, dateVente) ||
                other.dateVente == dateVente) &&
            (identical(other.modePaiement, modePaiement) ||
                other.modePaiement == modePaiement) &&
            const DeepCollectionEquality().equals(other._lignes, _lignes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, idLocal, sessionId, tierId,
      dateVente, modePaiement, const DeepCollectionEquality().hash(_lignes));

  /// Create a copy of VenteIn
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VenteInImplCopyWith<_$VenteInImpl> get copyWith =>
      __$$VenteInImplCopyWithImpl<_$VenteInImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VenteInImplToJson(
      this,
    );
  }
}

abstract class _VenteIn implements VenteIn {
  const factory _VenteIn(
      {@JsonKey(name: 'id_local_smartphone') required final String idLocal,
      @JsonKey(name: 'session_id') final String? sessionId,
      @JsonKey(name: 'tier_id') final String? tierId,
      @JsonKey(name: 'date_vente') final DateTime? dateVente,
      @JsonKey(name: 'mode_paiement') required final String modePaiement,
      required final List<LigneVenteIn> lignes}) = _$VenteInImpl;

  factory _VenteIn.fromJson(Map<String, dynamic> json) = _$VenteInImpl.fromJson;

  @override
  @JsonKey(name: 'id_local_smartphone')
  String get idLocal;
  @override
  @JsonKey(name: 'session_id')
  String? get sessionId;
  @override
  @JsonKey(name: 'tier_id')
  String? get tierId;
  @override
  @JsonKey(name: 'date_vente')
  DateTime? get dateVente;
  @override
  @JsonKey(name: 'mode_paiement')
  String get modePaiement;
  @override
  List<LigneVenteIn> get lignes;

  /// Create a copy of VenteIn
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VenteInImplCopyWith<_$VenteInImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DepenseIn _$DepenseInFromJson(Map<String, dynamic> json) {
  return _DepenseIn.fromJson(json);
}

/// @nodoc
mixin _$DepenseIn {
  @JsonKey(name: 'id_local_smartphone')
  String get idLocal => throw _privateConstructorUsedError;
  @JsonKey(name: 'session_id')
  String? get sessionId => throw _privateConstructorUsedError;
  @JsonKey(name: 'type_transaction')
  String get typeTransaction => throw _privateConstructorUsedError;
  double get montant => throw _privateConstructorUsedError;
  String get motif => throw _privateConstructorUsedError;
  @JsonKey(name: 'date_transaction')
  DateTime? get dateTransaction => throw _privateConstructorUsedError;

  /// Serializes this DepenseIn to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DepenseIn
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DepenseInCopyWith<DepenseIn> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DepenseInCopyWith<$Res> {
  factory $DepenseInCopyWith(DepenseIn value, $Res Function(DepenseIn) then) =
      _$DepenseInCopyWithImpl<$Res, DepenseIn>;
  @useResult
  $Res call(
      {@JsonKey(name: 'id_local_smartphone') String idLocal,
      @JsonKey(name: 'session_id') String? sessionId,
      @JsonKey(name: 'type_transaction') String typeTransaction,
      double montant,
      String motif,
      @JsonKey(name: 'date_transaction') DateTime? dateTransaction});
}

/// @nodoc
class _$DepenseInCopyWithImpl<$Res, $Val extends DepenseIn>
    implements $DepenseInCopyWith<$Res> {
  _$DepenseInCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DepenseIn
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? idLocal = null,
    Object? sessionId = freezed,
    Object? typeTransaction = null,
    Object? montant = null,
    Object? motif = null,
    Object? dateTransaction = freezed,
  }) {
    return _then(_value.copyWith(
      idLocal: null == idLocal
          ? _value.idLocal
          : idLocal // ignore: cast_nullable_to_non_nullable
              as String,
      sessionId: freezed == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String?,
      typeTransaction: null == typeTransaction
          ? _value.typeTransaction
          : typeTransaction // ignore: cast_nullable_to_non_nullable
              as String,
      montant: null == montant
          ? _value.montant
          : montant // ignore: cast_nullable_to_non_nullable
              as double,
      motif: null == motif
          ? _value.motif
          : motif // ignore: cast_nullable_to_non_nullable
              as String,
      dateTransaction: freezed == dateTransaction
          ? _value.dateTransaction
          : dateTransaction // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DepenseInImplCopyWith<$Res>
    implements $DepenseInCopyWith<$Res> {
  factory _$$DepenseInImplCopyWith(
          _$DepenseInImpl value, $Res Function(_$DepenseInImpl) then) =
      __$$DepenseInImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'id_local_smartphone') String idLocal,
      @JsonKey(name: 'session_id') String? sessionId,
      @JsonKey(name: 'type_transaction') String typeTransaction,
      double montant,
      String motif,
      @JsonKey(name: 'date_transaction') DateTime? dateTransaction});
}

/// @nodoc
class __$$DepenseInImplCopyWithImpl<$Res>
    extends _$DepenseInCopyWithImpl<$Res, _$DepenseInImpl>
    implements _$$DepenseInImplCopyWith<$Res> {
  __$$DepenseInImplCopyWithImpl(
      _$DepenseInImpl _value, $Res Function(_$DepenseInImpl) _then)
      : super(_value, _then);

  /// Create a copy of DepenseIn
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? idLocal = null,
    Object? sessionId = freezed,
    Object? typeTransaction = null,
    Object? montant = null,
    Object? motif = null,
    Object? dateTransaction = freezed,
  }) {
    return _then(_$DepenseInImpl(
      idLocal: null == idLocal
          ? _value.idLocal
          : idLocal // ignore: cast_nullable_to_non_nullable
              as String,
      sessionId: freezed == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String?,
      typeTransaction: null == typeTransaction
          ? _value.typeTransaction
          : typeTransaction // ignore: cast_nullable_to_non_nullable
              as String,
      montant: null == montant
          ? _value.montant
          : montant // ignore: cast_nullable_to_non_nullable
              as double,
      motif: null == motif
          ? _value.motif
          : motif // ignore: cast_nullable_to_non_nullable
              as String,
      dateTransaction: freezed == dateTransaction
          ? _value.dateTransaction
          : dateTransaction // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DepenseInImpl implements _DepenseIn {
  const _$DepenseInImpl(
      {@JsonKey(name: 'id_local_smartphone') required this.idLocal,
      @JsonKey(name: 'session_id') this.sessionId,
      @JsonKey(name: 'type_transaction')
      this.typeTransaction = 'SORTIE_DEPENSE',
      required this.montant,
      required this.motif,
      @JsonKey(name: 'date_transaction') this.dateTransaction});

  factory _$DepenseInImpl.fromJson(Map<String, dynamic> json) =>
      _$$DepenseInImplFromJson(json);

  @override
  @JsonKey(name: 'id_local_smartphone')
  final String idLocal;
  @override
  @JsonKey(name: 'session_id')
  final String? sessionId;
  @override
  @JsonKey(name: 'type_transaction')
  final String typeTransaction;
  @override
  final double montant;
  @override
  final String motif;
  @override
  @JsonKey(name: 'date_transaction')
  final DateTime? dateTransaction;

  @override
  String toString() {
    return 'DepenseIn(idLocal: $idLocal, sessionId: $sessionId, typeTransaction: $typeTransaction, montant: $montant, motif: $motif, dateTransaction: $dateTransaction)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DepenseInImpl &&
            (identical(other.idLocal, idLocal) || other.idLocal == idLocal) &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.typeTransaction, typeTransaction) ||
                other.typeTransaction == typeTransaction) &&
            (identical(other.montant, montant) || other.montant == montant) &&
            (identical(other.motif, motif) || other.motif == motif) &&
            (identical(other.dateTransaction, dateTransaction) ||
                other.dateTransaction == dateTransaction));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, idLocal, sessionId,
      typeTransaction, montant, motif, dateTransaction);

  /// Create a copy of DepenseIn
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DepenseInImplCopyWith<_$DepenseInImpl> get copyWith =>
      __$$DepenseInImplCopyWithImpl<_$DepenseInImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DepenseInImplToJson(
      this,
    );
  }
}

abstract class _DepenseIn implements DepenseIn {
  const factory _DepenseIn(
          {@JsonKey(name: 'id_local_smartphone') required final String idLocal,
          @JsonKey(name: 'session_id') final String? sessionId,
          @JsonKey(name: 'type_transaction') final String typeTransaction,
          required final double montant,
          required final String motif,
          @JsonKey(name: 'date_transaction') final DateTime? dateTransaction}) =
      _$DepenseInImpl;

  factory _DepenseIn.fromJson(Map<String, dynamic> json) =
      _$DepenseInImpl.fromJson;

  @override
  @JsonKey(name: 'id_local_smartphone')
  String get idLocal;
  @override
  @JsonKey(name: 'session_id')
  String? get sessionId;
  @override
  @JsonKey(name: 'type_transaction')
  String get typeTransaction;
  @override
  double get montant;
  @override
  String get motif;
  @override
  @JsonKey(name: 'date_transaction')
  DateTime? get dateTransaction;

  /// Create a copy of DepenseIn
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DepenseInImplCopyWith<_$DepenseInImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MouvementStockIn _$MouvementStockInFromJson(Map<String, dynamic> json) {
  return _MouvementStockIn.fromJson(json);
}

/// @nodoc
mixin _$MouvementStockIn {
  @JsonKey(name: 'id_local_smartphone')
  String get idLocal => throw _privateConstructorUsedError;
  @JsonKey(name: 'produit_id')
  String get produitId => throw _privateConstructorUsedError;
  @JsonKey(name: 'produit_nom')
  String get produitNom => throw _privateConstructorUsedError;
  @JsonKey(name: 'type_mouvement')
  String get typeMouvement => throw _privateConstructorUsedError;
  int get quantite => throw _privateConstructorUsedError;
  String get motif => throw _privateConstructorUsedError;
  @JsonKey(name: 'auteur_nom')
  String get auteurNom => throw _privateConstructorUsedError;
  @JsonKey(name: 'date_mouvement')
  DateTime? get dateMouvement => throw _privateConstructorUsedError;

  /// Serializes this MouvementStockIn to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MouvementStockIn
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MouvementStockInCopyWith<MouvementStockIn> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MouvementStockInCopyWith<$Res> {
  factory $MouvementStockInCopyWith(
          MouvementStockIn value, $Res Function(MouvementStockIn) then) =
      _$MouvementStockInCopyWithImpl<$Res, MouvementStockIn>;
  @useResult
  $Res call(
      {@JsonKey(name: 'id_local_smartphone') String idLocal,
      @JsonKey(name: 'produit_id') String produitId,
      @JsonKey(name: 'produit_nom') String produitNom,
      @JsonKey(name: 'type_mouvement') String typeMouvement,
      int quantite,
      String motif,
      @JsonKey(name: 'auteur_nom') String auteurNom,
      @JsonKey(name: 'date_mouvement') DateTime? dateMouvement});
}

/// @nodoc
class _$MouvementStockInCopyWithImpl<$Res, $Val extends MouvementStockIn>
    implements $MouvementStockInCopyWith<$Res> {
  _$MouvementStockInCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MouvementStockIn
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? idLocal = null,
    Object? produitId = null,
    Object? produitNom = null,
    Object? typeMouvement = null,
    Object? quantite = null,
    Object? motif = null,
    Object? auteurNom = null,
    Object? dateMouvement = freezed,
  }) {
    return _then(_value.copyWith(
      idLocal: null == idLocal
          ? _value.idLocal
          : idLocal // ignore: cast_nullable_to_non_nullable
              as String,
      produitId: null == produitId
          ? _value.produitId
          : produitId // ignore: cast_nullable_to_non_nullable
              as String,
      produitNom: null == produitNom
          ? _value.produitNom
          : produitNom // ignore: cast_nullable_to_non_nullable
              as String,
      typeMouvement: null == typeMouvement
          ? _value.typeMouvement
          : typeMouvement // ignore: cast_nullable_to_non_nullable
              as String,
      quantite: null == quantite
          ? _value.quantite
          : quantite // ignore: cast_nullable_to_non_nullable
              as int,
      motif: null == motif
          ? _value.motif
          : motif // ignore: cast_nullable_to_non_nullable
              as String,
      auteurNom: null == auteurNom
          ? _value.auteurNom
          : auteurNom // ignore: cast_nullable_to_non_nullable
              as String,
      dateMouvement: freezed == dateMouvement
          ? _value.dateMouvement
          : dateMouvement // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MouvementStockInImplCopyWith<$Res>
    implements $MouvementStockInCopyWith<$Res> {
  factory _$$MouvementStockInImplCopyWith(_$MouvementStockInImpl value,
          $Res Function(_$MouvementStockInImpl) then) =
      __$$MouvementStockInImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'id_local_smartphone') String idLocal,
      @JsonKey(name: 'produit_id') String produitId,
      @JsonKey(name: 'produit_nom') String produitNom,
      @JsonKey(name: 'type_mouvement') String typeMouvement,
      int quantite,
      String motif,
      @JsonKey(name: 'auteur_nom') String auteurNom,
      @JsonKey(name: 'date_mouvement') DateTime? dateMouvement});
}

/// @nodoc
class __$$MouvementStockInImplCopyWithImpl<$Res>
    extends _$MouvementStockInCopyWithImpl<$Res, _$MouvementStockInImpl>
    implements _$$MouvementStockInImplCopyWith<$Res> {
  __$$MouvementStockInImplCopyWithImpl(_$MouvementStockInImpl _value,
      $Res Function(_$MouvementStockInImpl) _then)
      : super(_value, _then);

  /// Create a copy of MouvementStockIn
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? idLocal = null,
    Object? produitId = null,
    Object? produitNom = null,
    Object? typeMouvement = null,
    Object? quantite = null,
    Object? motif = null,
    Object? auteurNom = null,
    Object? dateMouvement = freezed,
  }) {
    return _then(_$MouvementStockInImpl(
      idLocal: null == idLocal
          ? _value.idLocal
          : idLocal // ignore: cast_nullable_to_non_nullable
              as String,
      produitId: null == produitId
          ? _value.produitId
          : produitId // ignore: cast_nullable_to_non_nullable
              as String,
      produitNom: null == produitNom
          ? _value.produitNom
          : produitNom // ignore: cast_nullable_to_non_nullable
              as String,
      typeMouvement: null == typeMouvement
          ? _value.typeMouvement
          : typeMouvement // ignore: cast_nullable_to_non_nullable
              as String,
      quantite: null == quantite
          ? _value.quantite
          : quantite // ignore: cast_nullable_to_non_nullable
              as int,
      motif: null == motif
          ? _value.motif
          : motif // ignore: cast_nullable_to_non_nullable
              as String,
      auteurNom: null == auteurNom
          ? _value.auteurNom
          : auteurNom // ignore: cast_nullable_to_non_nullable
              as String,
      dateMouvement: freezed == dateMouvement
          ? _value.dateMouvement
          : dateMouvement // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MouvementStockInImpl implements _MouvementStockIn {
  const _$MouvementStockInImpl(
      {@JsonKey(name: 'id_local_smartphone') required this.idLocal,
      @JsonKey(name: 'produit_id') required this.produitId,
      @JsonKey(name: 'produit_nom') this.produitNom = '',
      @JsonKey(name: 'type_mouvement') required this.typeMouvement,
      required this.quantite,
      required this.motif,
      @JsonKey(name: 'auteur_nom') this.auteurNom = '',
      @JsonKey(name: 'date_mouvement') this.dateMouvement});

  factory _$MouvementStockInImpl.fromJson(Map<String, dynamic> json) =>
      _$$MouvementStockInImplFromJson(json);

  @override
  @JsonKey(name: 'id_local_smartphone')
  final String idLocal;
  @override
  @JsonKey(name: 'produit_id')
  final String produitId;
  @override
  @JsonKey(name: 'produit_nom')
  final String produitNom;
  @override
  @JsonKey(name: 'type_mouvement')
  final String typeMouvement;
  @override
  final int quantite;
  @override
  final String motif;
  @override
  @JsonKey(name: 'auteur_nom')
  final String auteurNom;
  @override
  @JsonKey(name: 'date_mouvement')
  final DateTime? dateMouvement;

  @override
  String toString() {
    return 'MouvementStockIn(idLocal: $idLocal, produitId: $produitId, produitNom: $produitNom, typeMouvement: $typeMouvement, quantite: $quantite, motif: $motif, auteurNom: $auteurNom, dateMouvement: $dateMouvement)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MouvementStockInImpl &&
            (identical(other.idLocal, idLocal) || other.idLocal == idLocal) &&
            (identical(other.produitId, produitId) ||
                other.produitId == produitId) &&
            (identical(other.produitNom, produitNom) ||
                other.produitNom == produitNom) &&
            (identical(other.typeMouvement, typeMouvement) ||
                other.typeMouvement == typeMouvement) &&
            (identical(other.quantite, quantite) ||
                other.quantite == quantite) &&
            (identical(other.motif, motif) || other.motif == motif) &&
            (identical(other.auteurNom, auteurNom) ||
                other.auteurNom == auteurNom) &&
            (identical(other.dateMouvement, dateMouvement) ||
                other.dateMouvement == dateMouvement));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, idLocal, produitId, produitNom,
      typeMouvement, quantite, motif, auteurNom, dateMouvement);

  /// Create a copy of MouvementStockIn
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MouvementStockInImplCopyWith<_$MouvementStockInImpl> get copyWith =>
      __$$MouvementStockInImplCopyWithImpl<_$MouvementStockInImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MouvementStockInImplToJson(
      this,
    );
  }
}

abstract class _MouvementStockIn implements MouvementStockIn {
  const factory _MouvementStockIn(
          {@JsonKey(name: 'id_local_smartphone') required final String idLocal,
          @JsonKey(name: 'produit_id') required final String produitId,
          @JsonKey(name: 'produit_nom') final String produitNom,
          @JsonKey(name: 'type_mouvement') required final String typeMouvement,
          required final int quantite,
          required final String motif,
          @JsonKey(name: 'auteur_nom') final String auteurNom,
          @JsonKey(name: 'date_mouvement') final DateTime? dateMouvement}) =
      _$MouvementStockInImpl;

  factory _MouvementStockIn.fromJson(Map<String, dynamic> json) =
      _$MouvementStockInImpl.fromJson;

  @override
  @JsonKey(name: 'id_local_smartphone')
  String get idLocal;
  @override
  @JsonKey(name: 'produit_id')
  String get produitId;
  @override
  @JsonKey(name: 'produit_nom')
  String get produitNom;
  @override
  @JsonKey(name: 'type_mouvement')
  String get typeMouvement;
  @override
  int get quantite;
  @override
  String get motif;
  @override
  @JsonKey(name: 'auteur_nom')
  String get auteurNom;
  @override
  @JsonKey(name: 'date_mouvement')
  DateTime? get dateMouvement;

  /// Create a copy of MouvementStockIn
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MouvementStockInImplCopyWith<_$MouvementStockInImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SyncPushRequest _$SyncPushRequestFromJson(Map<String, dynamic> json) {
  return _SyncPushRequest.fromJson(json);
}

/// @nodoc
mixin _$SyncPushRequest {
  @JsonKey(name: 'boutique_id')
  String get boutiqueId => throw _privateConstructorUsedError;
  List<VenteIn> get ventes => throw _privateConstructorUsedError;
  List<DepenseIn> get depenses => throw _privateConstructorUsedError;
  @JsonKey(name: 'entrees_stock')
  List<dynamic> get entreesStock => throw _privateConstructorUsedError;
  @JsonKey(name: 'mouvements_stock')
  List<MouvementStockIn> get mouvementsStock =>
      throw _privateConstructorUsedError;

  /// Serializes this SyncPushRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SyncPushRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SyncPushRequestCopyWith<SyncPushRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SyncPushRequestCopyWith<$Res> {
  factory $SyncPushRequestCopyWith(
          SyncPushRequest value, $Res Function(SyncPushRequest) then) =
      _$SyncPushRequestCopyWithImpl<$Res, SyncPushRequest>;
  @useResult
  $Res call(
      {@JsonKey(name: 'boutique_id') String boutiqueId,
      List<VenteIn> ventes,
      List<DepenseIn> depenses,
      @JsonKey(name: 'entrees_stock') List<dynamic> entreesStock,
      @JsonKey(name: 'mouvements_stock')
      List<MouvementStockIn> mouvementsStock});
}

/// @nodoc
class _$SyncPushRequestCopyWithImpl<$Res, $Val extends SyncPushRequest>
    implements $SyncPushRequestCopyWith<$Res> {
  _$SyncPushRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SyncPushRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? boutiqueId = null,
    Object? ventes = null,
    Object? depenses = null,
    Object? entreesStock = null,
    Object? mouvementsStock = null,
  }) {
    return _then(_value.copyWith(
      boutiqueId: null == boutiqueId
          ? _value.boutiqueId
          : boutiqueId // ignore: cast_nullable_to_non_nullable
              as String,
      ventes: null == ventes
          ? _value.ventes
          : ventes // ignore: cast_nullable_to_non_nullable
              as List<VenteIn>,
      depenses: null == depenses
          ? _value.depenses
          : depenses // ignore: cast_nullable_to_non_nullable
              as List<DepenseIn>,
      entreesStock: null == entreesStock
          ? _value.entreesStock
          : entreesStock // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      mouvementsStock: null == mouvementsStock
          ? _value.mouvementsStock
          : mouvementsStock // ignore: cast_nullable_to_non_nullable
              as List<MouvementStockIn>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SyncPushRequestImplCopyWith<$Res>
    implements $SyncPushRequestCopyWith<$Res> {
  factory _$$SyncPushRequestImplCopyWith(_$SyncPushRequestImpl value,
          $Res Function(_$SyncPushRequestImpl) then) =
      __$$SyncPushRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'boutique_id') String boutiqueId,
      List<VenteIn> ventes,
      List<DepenseIn> depenses,
      @JsonKey(name: 'entrees_stock') List<dynamic> entreesStock,
      @JsonKey(name: 'mouvements_stock')
      List<MouvementStockIn> mouvementsStock});
}

/// @nodoc
class __$$SyncPushRequestImplCopyWithImpl<$Res>
    extends _$SyncPushRequestCopyWithImpl<$Res, _$SyncPushRequestImpl>
    implements _$$SyncPushRequestImplCopyWith<$Res> {
  __$$SyncPushRequestImplCopyWithImpl(
      _$SyncPushRequestImpl _value, $Res Function(_$SyncPushRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of SyncPushRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? boutiqueId = null,
    Object? ventes = null,
    Object? depenses = null,
    Object? entreesStock = null,
    Object? mouvementsStock = null,
  }) {
    return _then(_$SyncPushRequestImpl(
      boutiqueId: null == boutiqueId
          ? _value.boutiqueId
          : boutiqueId // ignore: cast_nullable_to_non_nullable
              as String,
      ventes: null == ventes
          ? _value._ventes
          : ventes // ignore: cast_nullable_to_non_nullable
              as List<VenteIn>,
      depenses: null == depenses
          ? _value._depenses
          : depenses // ignore: cast_nullable_to_non_nullable
              as List<DepenseIn>,
      entreesStock: null == entreesStock
          ? _value._entreesStock
          : entreesStock // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      mouvementsStock: null == mouvementsStock
          ? _value._mouvementsStock
          : mouvementsStock // ignore: cast_nullable_to_non_nullable
              as List<MouvementStockIn>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SyncPushRequestImpl implements _SyncPushRequest {
  const _$SyncPushRequestImpl(
      {@JsonKey(name: 'boutique_id') required this.boutiqueId,
      final List<VenteIn> ventes = const [],
      final List<DepenseIn> depenses = const [],
      @JsonKey(name: 'entrees_stock')
      final List<dynamic> entreesStock = const [],
      @JsonKey(name: 'mouvements_stock')
      final List<MouvementStockIn> mouvementsStock = const []})
      : _ventes = ventes,
        _depenses = depenses,
        _entreesStock = entreesStock,
        _mouvementsStock = mouvementsStock;

  factory _$SyncPushRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$SyncPushRequestImplFromJson(json);

  @override
  @JsonKey(name: 'boutique_id')
  final String boutiqueId;
  final List<VenteIn> _ventes;
  @override
  @JsonKey()
  List<VenteIn> get ventes {
    if (_ventes is EqualUnmodifiableListView) return _ventes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_ventes);
  }

  final List<DepenseIn> _depenses;
  @override
  @JsonKey()
  List<DepenseIn> get depenses {
    if (_depenses is EqualUnmodifiableListView) return _depenses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_depenses);
  }

  final List<dynamic> _entreesStock;
  @override
  @JsonKey(name: 'entrees_stock')
  List<dynamic> get entreesStock {
    if (_entreesStock is EqualUnmodifiableListView) return _entreesStock;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_entreesStock);
  }

  final List<MouvementStockIn> _mouvementsStock;
  @override
  @JsonKey(name: 'mouvements_stock')
  List<MouvementStockIn> get mouvementsStock {
    if (_mouvementsStock is EqualUnmodifiableListView) return _mouvementsStock;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_mouvementsStock);
  }

  @override
  String toString() {
    return 'SyncPushRequest(boutiqueId: $boutiqueId, ventes: $ventes, depenses: $depenses, entreesStock: $entreesStock, mouvementsStock: $mouvementsStock)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SyncPushRequestImpl &&
            (identical(other.boutiqueId, boutiqueId) ||
                other.boutiqueId == boutiqueId) &&
            const DeepCollectionEquality().equals(other._ventes, _ventes) &&
            const DeepCollectionEquality().equals(other._depenses, _depenses) &&
            const DeepCollectionEquality()
                .equals(other._entreesStock, _entreesStock) &&
            const DeepCollectionEquality()
                .equals(other._mouvementsStock, _mouvementsStock));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      boutiqueId,
      const DeepCollectionEquality().hash(_ventes),
      const DeepCollectionEquality().hash(_depenses),
      const DeepCollectionEquality().hash(_entreesStock),
      const DeepCollectionEquality().hash(_mouvementsStock));

  /// Create a copy of SyncPushRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SyncPushRequestImplCopyWith<_$SyncPushRequestImpl> get copyWith =>
      __$$SyncPushRequestImplCopyWithImpl<_$SyncPushRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SyncPushRequestImplToJson(
      this,
    );
  }
}

abstract class _SyncPushRequest implements SyncPushRequest {
  const factory _SyncPushRequest(
      {@JsonKey(name: 'boutique_id') required final String boutiqueId,
      final List<VenteIn> ventes,
      final List<DepenseIn> depenses,
      @JsonKey(name: 'entrees_stock') final List<dynamic> entreesStock,
      @JsonKey(name: 'mouvements_stock')
      final List<MouvementStockIn> mouvementsStock}) = _$SyncPushRequestImpl;

  factory _SyncPushRequest.fromJson(Map<String, dynamic> json) =
      _$SyncPushRequestImpl.fromJson;

  @override
  @JsonKey(name: 'boutique_id')
  String get boutiqueId;
  @override
  List<VenteIn> get ventes;
  @override
  List<DepenseIn> get depenses;
  @override
  @JsonKey(name: 'entrees_stock')
  List<dynamic> get entreesStock;
  @override
  @JsonKey(name: 'mouvements_stock')
  List<MouvementStockIn> get mouvementsStock;

  /// Create a copy of SyncPushRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SyncPushRequestImplCopyWith<_$SyncPushRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RecuLigne _$RecuLigneFromJson(Map<String, dynamic> json) {
  return _RecuLigne.fromJson(json);
}

/// @nodoc
mixin _$RecuLigne {
  String get nom => throw _privateConstructorUsedError;
  int get quantite => throw _privateConstructorUsedError;
  @JsonKey(name: 'prix_unitaire', fromJson: parseDouble)
  double get prixUnitaire => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_ligne', fromJson: parseDouble)
  double get totalLigne => throw _privateConstructorUsedError;

  /// Serializes this RecuLigne to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RecuLigne
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecuLigneCopyWith<RecuLigne> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecuLigneCopyWith<$Res> {
  factory $RecuLigneCopyWith(RecuLigne value, $Res Function(RecuLigne) then) =
      _$RecuLigneCopyWithImpl<$Res, RecuLigne>;
  @useResult
  $Res call(
      {String nom,
      int quantite,
      @JsonKey(name: 'prix_unitaire', fromJson: parseDouble)
      double prixUnitaire,
      @JsonKey(name: 'total_ligne', fromJson: parseDouble) double totalLigne});
}

/// @nodoc
class _$RecuLigneCopyWithImpl<$Res, $Val extends RecuLigne>
    implements $RecuLigneCopyWith<$Res> {
  _$RecuLigneCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecuLigne
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? nom = null,
    Object? quantite = null,
    Object? prixUnitaire = null,
    Object? totalLigne = null,
  }) {
    return _then(_value.copyWith(
      nom: null == nom
          ? _value.nom
          : nom // ignore: cast_nullable_to_non_nullable
              as String,
      quantite: null == quantite
          ? _value.quantite
          : quantite // ignore: cast_nullable_to_non_nullable
              as int,
      prixUnitaire: null == prixUnitaire
          ? _value.prixUnitaire
          : prixUnitaire // ignore: cast_nullable_to_non_nullable
              as double,
      totalLigne: null == totalLigne
          ? _value.totalLigne
          : totalLigne // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RecuLigneImplCopyWith<$Res>
    implements $RecuLigneCopyWith<$Res> {
  factory _$$RecuLigneImplCopyWith(
          _$RecuLigneImpl value, $Res Function(_$RecuLigneImpl) then) =
      __$$RecuLigneImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String nom,
      int quantite,
      @JsonKey(name: 'prix_unitaire', fromJson: parseDouble)
      double prixUnitaire,
      @JsonKey(name: 'total_ligne', fromJson: parseDouble) double totalLigne});
}

/// @nodoc
class __$$RecuLigneImplCopyWithImpl<$Res>
    extends _$RecuLigneCopyWithImpl<$Res, _$RecuLigneImpl>
    implements _$$RecuLigneImplCopyWith<$Res> {
  __$$RecuLigneImplCopyWithImpl(
      _$RecuLigneImpl _value, $Res Function(_$RecuLigneImpl) _then)
      : super(_value, _then);

  /// Create a copy of RecuLigne
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? nom = null,
    Object? quantite = null,
    Object? prixUnitaire = null,
    Object? totalLigne = null,
  }) {
    return _then(_$RecuLigneImpl(
      nom: null == nom
          ? _value.nom
          : nom // ignore: cast_nullable_to_non_nullable
              as String,
      quantite: null == quantite
          ? _value.quantite
          : quantite // ignore: cast_nullable_to_non_nullable
              as int,
      prixUnitaire: null == prixUnitaire
          ? _value.prixUnitaire
          : prixUnitaire // ignore: cast_nullable_to_non_nullable
              as double,
      totalLigne: null == totalLigne
          ? _value.totalLigne
          : totalLigne // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RecuLigneImpl implements _RecuLigne {
  const _$RecuLigneImpl(
      {required this.nom,
      required this.quantite,
      @JsonKey(name: 'prix_unitaire', fromJson: parseDouble)
      required this.prixUnitaire,
      @JsonKey(name: 'total_ligne', fromJson: parseDouble)
      required this.totalLigne});

  factory _$RecuLigneImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecuLigneImplFromJson(json);

  @override
  final String nom;
  @override
  final int quantite;
  @override
  @JsonKey(name: 'prix_unitaire', fromJson: parseDouble)
  final double prixUnitaire;
  @override
  @JsonKey(name: 'total_ligne', fromJson: parseDouble)
  final double totalLigne;

  @override
  String toString() {
    return 'RecuLigne(nom: $nom, quantite: $quantite, prixUnitaire: $prixUnitaire, totalLigne: $totalLigne)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecuLigneImpl &&
            (identical(other.nom, nom) || other.nom == nom) &&
            (identical(other.quantite, quantite) ||
                other.quantite == quantite) &&
            (identical(other.prixUnitaire, prixUnitaire) ||
                other.prixUnitaire == prixUnitaire) &&
            (identical(other.totalLigne, totalLigne) ||
                other.totalLigne == totalLigne));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, nom, quantite, prixUnitaire, totalLigne);

  /// Create a copy of RecuLigne
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecuLigneImplCopyWith<_$RecuLigneImpl> get copyWith =>
      __$$RecuLigneImplCopyWithImpl<_$RecuLigneImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecuLigneImplToJson(
      this,
    );
  }
}

abstract class _RecuLigne implements RecuLigne {
  const factory _RecuLigne(
      {required final String nom,
      required final int quantite,
      @JsonKey(name: 'prix_unitaire', fromJson: parseDouble)
      required final double prixUnitaire,
      @JsonKey(name: 'total_ligne', fromJson: parseDouble)
      required final double totalLigne}) = _$RecuLigneImpl;

  factory _RecuLigne.fromJson(Map<String, dynamic> json) =
      _$RecuLigneImpl.fromJson;

  @override
  String get nom;
  @override
  int get quantite;
  @override
  @JsonKey(name: 'prix_unitaire', fromJson: parseDouble)
  double get prixUnitaire;
  @override
  @JsonKey(name: 'total_ligne', fromJson: parseDouble)
  double get totalLigne;

  /// Create a copy of RecuLigne
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecuLigneImplCopyWith<_$RecuLigneImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RecuOut _$RecuOutFromJson(Map<String, dynamic> json) {
  return _RecuOut.fromJson(json);
}

/// @nodoc
mixin _$RecuOut {
  @JsonKey(name: 'vente_id')
  String get venteId => throw _privateConstructorUsedError;
  String get numero => throw _privateConstructorUsedError;
  @JsonKey(name: 'boutique_nom')
  String get boutiqueNom => throw _privateConstructorUsedError;
  @JsonKey(name: 'date_vente')
  DateTime get dateVente => throw _privateConstructorUsedError;
  @JsonKey(name: 'mode_paiement')
  String get modePaiement => throw _privateConstructorUsedError;
  List<RecuLigne> get lignes => throw _privateConstructorUsedError;
  @JsonKey(name: 'montant_total', fromJson: parseDouble)
  double get montantTotal => throw _privateConstructorUsedError;
  @JsonKey(name: 'client_nom')
  String? get clientNom => throw _privateConstructorUsedError;

  /// Serializes this RecuOut to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RecuOut
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecuOutCopyWith<RecuOut> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecuOutCopyWith<$Res> {
  factory $RecuOutCopyWith(RecuOut value, $Res Function(RecuOut) then) =
      _$RecuOutCopyWithImpl<$Res, RecuOut>;
  @useResult
  $Res call(
      {@JsonKey(name: 'vente_id') String venteId,
      String numero,
      @JsonKey(name: 'boutique_nom') String boutiqueNom,
      @JsonKey(name: 'date_vente') DateTime dateVente,
      @JsonKey(name: 'mode_paiement') String modePaiement,
      List<RecuLigne> lignes,
      @JsonKey(name: 'montant_total', fromJson: parseDouble)
      double montantTotal,
      @JsonKey(name: 'client_nom') String? clientNom});
}

/// @nodoc
class _$RecuOutCopyWithImpl<$Res, $Val extends RecuOut>
    implements $RecuOutCopyWith<$Res> {
  _$RecuOutCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecuOut
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? venteId = null,
    Object? numero = null,
    Object? boutiqueNom = null,
    Object? dateVente = null,
    Object? modePaiement = null,
    Object? lignes = null,
    Object? montantTotal = null,
    Object? clientNom = freezed,
  }) {
    return _then(_value.copyWith(
      venteId: null == venteId
          ? _value.venteId
          : venteId // ignore: cast_nullable_to_non_nullable
              as String,
      numero: null == numero
          ? _value.numero
          : numero // ignore: cast_nullable_to_non_nullable
              as String,
      boutiqueNom: null == boutiqueNom
          ? _value.boutiqueNom
          : boutiqueNom // ignore: cast_nullable_to_non_nullable
              as String,
      dateVente: null == dateVente
          ? _value.dateVente
          : dateVente // ignore: cast_nullable_to_non_nullable
              as DateTime,
      modePaiement: null == modePaiement
          ? _value.modePaiement
          : modePaiement // ignore: cast_nullable_to_non_nullable
              as String,
      lignes: null == lignes
          ? _value.lignes
          : lignes // ignore: cast_nullable_to_non_nullable
              as List<RecuLigne>,
      montantTotal: null == montantTotal
          ? _value.montantTotal
          : montantTotal // ignore: cast_nullable_to_non_nullable
              as double,
      clientNom: freezed == clientNom
          ? _value.clientNom
          : clientNom // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RecuOutImplCopyWith<$Res> implements $RecuOutCopyWith<$Res> {
  factory _$$RecuOutImplCopyWith(
          _$RecuOutImpl value, $Res Function(_$RecuOutImpl) then) =
      __$$RecuOutImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'vente_id') String venteId,
      String numero,
      @JsonKey(name: 'boutique_nom') String boutiqueNom,
      @JsonKey(name: 'date_vente') DateTime dateVente,
      @JsonKey(name: 'mode_paiement') String modePaiement,
      List<RecuLigne> lignes,
      @JsonKey(name: 'montant_total', fromJson: parseDouble)
      double montantTotal,
      @JsonKey(name: 'client_nom') String? clientNom});
}

/// @nodoc
class __$$RecuOutImplCopyWithImpl<$Res>
    extends _$RecuOutCopyWithImpl<$Res, _$RecuOutImpl>
    implements _$$RecuOutImplCopyWith<$Res> {
  __$$RecuOutImplCopyWithImpl(
      _$RecuOutImpl _value, $Res Function(_$RecuOutImpl) _then)
      : super(_value, _then);

  /// Create a copy of RecuOut
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? venteId = null,
    Object? numero = null,
    Object? boutiqueNom = null,
    Object? dateVente = null,
    Object? modePaiement = null,
    Object? lignes = null,
    Object? montantTotal = null,
    Object? clientNom = freezed,
  }) {
    return _then(_$RecuOutImpl(
      venteId: null == venteId
          ? _value.venteId
          : venteId // ignore: cast_nullable_to_non_nullable
              as String,
      numero: null == numero
          ? _value.numero
          : numero // ignore: cast_nullable_to_non_nullable
              as String,
      boutiqueNom: null == boutiqueNom
          ? _value.boutiqueNom
          : boutiqueNom // ignore: cast_nullable_to_non_nullable
              as String,
      dateVente: null == dateVente
          ? _value.dateVente
          : dateVente // ignore: cast_nullable_to_non_nullable
              as DateTime,
      modePaiement: null == modePaiement
          ? _value.modePaiement
          : modePaiement // ignore: cast_nullable_to_non_nullable
              as String,
      lignes: null == lignes
          ? _value._lignes
          : lignes // ignore: cast_nullable_to_non_nullable
              as List<RecuLigne>,
      montantTotal: null == montantTotal
          ? _value.montantTotal
          : montantTotal // ignore: cast_nullable_to_non_nullable
              as double,
      clientNom: freezed == clientNom
          ? _value.clientNom
          : clientNom // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RecuOutImpl implements _RecuOut {
  const _$RecuOutImpl(
      {@JsonKey(name: 'vente_id') required this.venteId,
      required this.numero,
      @JsonKey(name: 'boutique_nom') required this.boutiqueNom,
      @JsonKey(name: 'date_vente') required this.dateVente,
      @JsonKey(name: 'mode_paiement') required this.modePaiement,
      required final List<RecuLigne> lignes,
      @JsonKey(name: 'montant_total', fromJson: parseDouble)
      required this.montantTotal,
      @JsonKey(name: 'client_nom') this.clientNom})
      : _lignes = lignes;

  factory _$RecuOutImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecuOutImplFromJson(json);

  @override
  @JsonKey(name: 'vente_id')
  final String venteId;
  @override
  final String numero;
  @override
  @JsonKey(name: 'boutique_nom')
  final String boutiqueNom;
  @override
  @JsonKey(name: 'date_vente')
  final DateTime dateVente;
  @override
  @JsonKey(name: 'mode_paiement')
  final String modePaiement;
  final List<RecuLigne> _lignes;
  @override
  List<RecuLigne> get lignes {
    if (_lignes is EqualUnmodifiableListView) return _lignes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_lignes);
  }

  @override
  @JsonKey(name: 'montant_total', fromJson: parseDouble)
  final double montantTotal;
  @override
  @JsonKey(name: 'client_nom')
  final String? clientNom;

  @override
  String toString() {
    return 'RecuOut(venteId: $venteId, numero: $numero, boutiqueNom: $boutiqueNom, dateVente: $dateVente, modePaiement: $modePaiement, lignes: $lignes, montantTotal: $montantTotal, clientNom: $clientNom)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecuOutImpl &&
            (identical(other.venteId, venteId) || other.venteId == venteId) &&
            (identical(other.numero, numero) || other.numero == numero) &&
            (identical(other.boutiqueNom, boutiqueNom) ||
                other.boutiqueNom == boutiqueNom) &&
            (identical(other.dateVente, dateVente) ||
                other.dateVente == dateVente) &&
            (identical(other.modePaiement, modePaiement) ||
                other.modePaiement == modePaiement) &&
            const DeepCollectionEquality().equals(other._lignes, _lignes) &&
            (identical(other.montantTotal, montantTotal) ||
                other.montantTotal == montantTotal) &&
            (identical(other.clientNom, clientNom) ||
                other.clientNom == clientNom));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      venteId,
      numero,
      boutiqueNom,
      dateVente,
      modePaiement,
      const DeepCollectionEquality().hash(_lignes),
      montantTotal,
      clientNom);

  /// Create a copy of RecuOut
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecuOutImplCopyWith<_$RecuOutImpl> get copyWith =>
      __$$RecuOutImplCopyWithImpl<_$RecuOutImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecuOutImplToJson(
      this,
    );
  }
}

abstract class _RecuOut implements RecuOut {
  const factory _RecuOut(
      {@JsonKey(name: 'vente_id') required final String venteId,
      required final String numero,
      @JsonKey(name: 'boutique_nom') required final String boutiqueNom,
      @JsonKey(name: 'date_vente') required final DateTime dateVente,
      @JsonKey(name: 'mode_paiement') required final String modePaiement,
      required final List<RecuLigne> lignes,
      @JsonKey(name: 'montant_total', fromJson: parseDouble)
      required final double montantTotal,
      @JsonKey(name: 'client_nom') final String? clientNom}) = _$RecuOutImpl;

  factory _RecuOut.fromJson(Map<String, dynamic> json) = _$RecuOutImpl.fromJson;

  @override
  @JsonKey(name: 'vente_id')
  String get venteId;
  @override
  String get numero;
  @override
  @JsonKey(name: 'boutique_nom')
  String get boutiqueNom;
  @override
  @JsonKey(name: 'date_vente')
  DateTime get dateVente;
  @override
  @JsonKey(name: 'mode_paiement')
  String get modePaiement;
  @override
  List<RecuLigne> get lignes;
  @override
  @JsonKey(name: 'montant_total', fromJson: parseDouble)
  double get montantTotal;
  @override
  @JsonKey(name: 'client_nom')
  String? get clientNom;

  /// Create a copy of RecuOut
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecuOutImplCopyWith<_$RecuOutImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

VentePushResult _$VentePushResultFromJson(Map<String, dynamic> json) {
  return _VentePushResult.fromJson(json);
}

/// @nodoc
mixin _$VentePushResult {
  @JsonKey(name: 'id_local_smartphone')
  String get idLocal => throw _privateConstructorUsedError;
  @JsonKey(name: 'vente_id')
  String get venteId => throw _privateConstructorUsedError;
  @JsonKey(name: 'deja_synchronisee')
  bool get dejaSynchronisee => throw _privateConstructorUsedError;
  @JsonKey(name: 'signale_proprietaire')
  bool get signaleProprietaire => throw _privateConstructorUsedError;
  String? get avertissement => throw _privateConstructorUsedError;
  RecuOut? get recu => throw _privateConstructorUsedError;

  /// Serializes this VentePushResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VentePushResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VentePushResultCopyWith<VentePushResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VentePushResultCopyWith<$Res> {
  factory $VentePushResultCopyWith(
          VentePushResult value, $Res Function(VentePushResult) then) =
      _$VentePushResultCopyWithImpl<$Res, VentePushResult>;
  @useResult
  $Res call(
      {@JsonKey(name: 'id_local_smartphone') String idLocal,
      @JsonKey(name: 'vente_id') String venteId,
      @JsonKey(name: 'deja_synchronisee') bool dejaSynchronisee,
      @JsonKey(name: 'signale_proprietaire') bool signaleProprietaire,
      String? avertissement,
      RecuOut? recu});

  $RecuOutCopyWith<$Res>? get recu;
}

/// @nodoc
class _$VentePushResultCopyWithImpl<$Res, $Val extends VentePushResult>
    implements $VentePushResultCopyWith<$Res> {
  _$VentePushResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VentePushResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? idLocal = null,
    Object? venteId = null,
    Object? dejaSynchronisee = null,
    Object? signaleProprietaire = null,
    Object? avertissement = freezed,
    Object? recu = freezed,
  }) {
    return _then(_value.copyWith(
      idLocal: null == idLocal
          ? _value.idLocal
          : idLocal // ignore: cast_nullable_to_non_nullable
              as String,
      venteId: null == venteId
          ? _value.venteId
          : venteId // ignore: cast_nullable_to_non_nullable
              as String,
      dejaSynchronisee: null == dejaSynchronisee
          ? _value.dejaSynchronisee
          : dejaSynchronisee // ignore: cast_nullable_to_non_nullable
              as bool,
      signaleProprietaire: null == signaleProprietaire
          ? _value.signaleProprietaire
          : signaleProprietaire // ignore: cast_nullable_to_non_nullable
              as bool,
      avertissement: freezed == avertissement
          ? _value.avertissement
          : avertissement // ignore: cast_nullable_to_non_nullable
              as String?,
      recu: freezed == recu
          ? _value.recu
          : recu // ignore: cast_nullable_to_non_nullable
              as RecuOut?,
    ) as $Val);
  }

  /// Create a copy of VentePushResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RecuOutCopyWith<$Res>? get recu {
    if (_value.recu == null) {
      return null;
    }

    return $RecuOutCopyWith<$Res>(_value.recu!, (value) {
      return _then(_value.copyWith(recu: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$VentePushResultImplCopyWith<$Res>
    implements $VentePushResultCopyWith<$Res> {
  factory _$$VentePushResultImplCopyWith(_$VentePushResultImpl value,
          $Res Function(_$VentePushResultImpl) then) =
      __$$VentePushResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'id_local_smartphone') String idLocal,
      @JsonKey(name: 'vente_id') String venteId,
      @JsonKey(name: 'deja_synchronisee') bool dejaSynchronisee,
      @JsonKey(name: 'signale_proprietaire') bool signaleProprietaire,
      String? avertissement,
      RecuOut? recu});

  @override
  $RecuOutCopyWith<$Res>? get recu;
}

/// @nodoc
class __$$VentePushResultImplCopyWithImpl<$Res>
    extends _$VentePushResultCopyWithImpl<$Res, _$VentePushResultImpl>
    implements _$$VentePushResultImplCopyWith<$Res> {
  __$$VentePushResultImplCopyWithImpl(
      _$VentePushResultImpl _value, $Res Function(_$VentePushResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of VentePushResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? idLocal = null,
    Object? venteId = null,
    Object? dejaSynchronisee = null,
    Object? signaleProprietaire = null,
    Object? avertissement = freezed,
    Object? recu = freezed,
  }) {
    return _then(_$VentePushResultImpl(
      idLocal: null == idLocal
          ? _value.idLocal
          : idLocal // ignore: cast_nullable_to_non_nullable
              as String,
      venteId: null == venteId
          ? _value.venteId
          : venteId // ignore: cast_nullable_to_non_nullable
              as String,
      dejaSynchronisee: null == dejaSynchronisee
          ? _value.dejaSynchronisee
          : dejaSynchronisee // ignore: cast_nullable_to_non_nullable
              as bool,
      signaleProprietaire: null == signaleProprietaire
          ? _value.signaleProprietaire
          : signaleProprietaire // ignore: cast_nullable_to_non_nullable
              as bool,
      avertissement: freezed == avertissement
          ? _value.avertissement
          : avertissement // ignore: cast_nullable_to_non_nullable
              as String?,
      recu: freezed == recu
          ? _value.recu
          : recu // ignore: cast_nullable_to_non_nullable
              as RecuOut?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VentePushResultImpl implements _VentePushResult {
  const _$VentePushResultImpl(
      {@JsonKey(name: 'id_local_smartphone') required this.idLocal,
      @JsonKey(name: 'vente_id') required this.venteId,
      @JsonKey(name: 'deja_synchronisee') this.dejaSynchronisee = false,
      @JsonKey(name: 'signale_proprietaire') this.signaleProprietaire = false,
      this.avertissement,
      this.recu});

  factory _$VentePushResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$VentePushResultImplFromJson(json);

  @override
  @JsonKey(name: 'id_local_smartphone')
  final String idLocal;
  @override
  @JsonKey(name: 'vente_id')
  final String venteId;
  @override
  @JsonKey(name: 'deja_synchronisee')
  final bool dejaSynchronisee;
  @override
  @JsonKey(name: 'signale_proprietaire')
  final bool signaleProprietaire;
  @override
  final String? avertissement;
  @override
  final RecuOut? recu;

  @override
  String toString() {
    return 'VentePushResult(idLocal: $idLocal, venteId: $venteId, dejaSynchronisee: $dejaSynchronisee, signaleProprietaire: $signaleProprietaire, avertissement: $avertissement, recu: $recu)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VentePushResultImpl &&
            (identical(other.idLocal, idLocal) || other.idLocal == idLocal) &&
            (identical(other.venteId, venteId) || other.venteId == venteId) &&
            (identical(other.dejaSynchronisee, dejaSynchronisee) ||
                other.dejaSynchronisee == dejaSynchronisee) &&
            (identical(other.signaleProprietaire, signaleProprietaire) ||
                other.signaleProprietaire == signaleProprietaire) &&
            (identical(other.avertissement, avertissement) ||
                other.avertissement == avertissement) &&
            (identical(other.recu, recu) || other.recu == recu));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, idLocal, venteId,
      dejaSynchronisee, signaleProprietaire, avertissement, recu);

  /// Create a copy of VentePushResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VentePushResultImplCopyWith<_$VentePushResultImpl> get copyWith =>
      __$$VentePushResultImplCopyWithImpl<_$VentePushResultImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VentePushResultImplToJson(
      this,
    );
  }
}

abstract class _VentePushResult implements VentePushResult {
  const factory _VentePushResult(
      {@JsonKey(name: 'id_local_smartphone') required final String idLocal,
      @JsonKey(name: 'vente_id') required final String venteId,
      @JsonKey(name: 'deja_synchronisee') final bool dejaSynchronisee,
      @JsonKey(name: 'signale_proprietaire') final bool signaleProprietaire,
      final String? avertissement,
      final RecuOut? recu}) = _$VentePushResultImpl;

  factory _VentePushResult.fromJson(Map<String, dynamic> json) =
      _$VentePushResultImpl.fromJson;

  @override
  @JsonKey(name: 'id_local_smartphone')
  String get idLocal;
  @override
  @JsonKey(name: 'vente_id')
  String get venteId;
  @override
  @JsonKey(name: 'deja_synchronisee')
  bool get dejaSynchronisee;
  @override
  @JsonKey(name: 'signale_proprietaire')
  bool get signaleProprietaire;
  @override
  String? get avertissement;
  @override
  RecuOut? get recu;

  /// Create a copy of VentePushResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VentePushResultImplCopyWith<_$VentePushResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AlerteStockItem _$AlerteStockItemFromJson(Map<String, dynamic> json) {
  return _AlerteStockItem.fromJson(json);
}

/// @nodoc
mixin _$AlerteStockItem {
  @JsonKey(name: 'produit_id')
  String get produitId => throw _privateConstructorUsedError;
  String get nom => throw _privateConstructorUsedError;
  @JsonKey(name: 'stock_actuel')
  int get stockActuel => throw _privateConstructorUsedError;
  @JsonKey(name: 'stock_alerte')
  int get stockAlerte => throw _privateConstructorUsedError;
  @JsonKey(name: 'en_rupture')
  bool get enRupture => throw _privateConstructorUsedError;

  /// Serializes this AlerteStockItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AlerteStockItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AlerteStockItemCopyWith<AlerteStockItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AlerteStockItemCopyWith<$Res> {
  factory $AlerteStockItemCopyWith(
          AlerteStockItem value, $Res Function(AlerteStockItem) then) =
      _$AlerteStockItemCopyWithImpl<$Res, AlerteStockItem>;
  @useResult
  $Res call(
      {@JsonKey(name: 'produit_id') String produitId,
      String nom,
      @JsonKey(name: 'stock_actuel') int stockActuel,
      @JsonKey(name: 'stock_alerte') int stockAlerte,
      @JsonKey(name: 'en_rupture') bool enRupture});
}

/// @nodoc
class _$AlerteStockItemCopyWithImpl<$Res, $Val extends AlerteStockItem>
    implements $AlerteStockItemCopyWith<$Res> {
  _$AlerteStockItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AlerteStockItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? produitId = null,
    Object? nom = null,
    Object? stockActuel = null,
    Object? stockAlerte = null,
    Object? enRupture = null,
  }) {
    return _then(_value.copyWith(
      produitId: null == produitId
          ? _value.produitId
          : produitId // ignore: cast_nullable_to_non_nullable
              as String,
      nom: null == nom
          ? _value.nom
          : nom // ignore: cast_nullable_to_non_nullable
              as String,
      stockActuel: null == stockActuel
          ? _value.stockActuel
          : stockActuel // ignore: cast_nullable_to_non_nullable
              as int,
      stockAlerte: null == stockAlerte
          ? _value.stockAlerte
          : stockAlerte // ignore: cast_nullable_to_non_nullable
              as int,
      enRupture: null == enRupture
          ? _value.enRupture
          : enRupture // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AlerteStockItemImplCopyWith<$Res>
    implements $AlerteStockItemCopyWith<$Res> {
  factory _$$AlerteStockItemImplCopyWith(_$AlerteStockItemImpl value,
          $Res Function(_$AlerteStockItemImpl) then) =
      __$$AlerteStockItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'produit_id') String produitId,
      String nom,
      @JsonKey(name: 'stock_actuel') int stockActuel,
      @JsonKey(name: 'stock_alerte') int stockAlerte,
      @JsonKey(name: 'en_rupture') bool enRupture});
}

/// @nodoc
class __$$AlerteStockItemImplCopyWithImpl<$Res>
    extends _$AlerteStockItemCopyWithImpl<$Res, _$AlerteStockItemImpl>
    implements _$$AlerteStockItemImplCopyWith<$Res> {
  __$$AlerteStockItemImplCopyWithImpl(
      _$AlerteStockItemImpl _value, $Res Function(_$AlerteStockItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of AlerteStockItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? produitId = null,
    Object? nom = null,
    Object? stockActuel = null,
    Object? stockAlerte = null,
    Object? enRupture = null,
  }) {
    return _then(_$AlerteStockItemImpl(
      produitId: null == produitId
          ? _value.produitId
          : produitId // ignore: cast_nullable_to_non_nullable
              as String,
      nom: null == nom
          ? _value.nom
          : nom // ignore: cast_nullable_to_non_nullable
              as String,
      stockActuel: null == stockActuel
          ? _value.stockActuel
          : stockActuel // ignore: cast_nullable_to_non_nullable
              as int,
      stockAlerte: null == stockAlerte
          ? _value.stockAlerte
          : stockAlerte // ignore: cast_nullable_to_non_nullable
              as int,
      enRupture: null == enRupture
          ? _value.enRupture
          : enRupture // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AlerteStockItemImpl implements _AlerteStockItem {
  const _$AlerteStockItemImpl(
      {@JsonKey(name: 'produit_id') required this.produitId,
      required this.nom,
      @JsonKey(name: 'stock_actuel') required this.stockActuel,
      @JsonKey(name: 'stock_alerte') required this.stockAlerte,
      @JsonKey(name: 'en_rupture') required this.enRupture});

  factory _$AlerteStockItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$AlerteStockItemImplFromJson(json);

  @override
  @JsonKey(name: 'produit_id')
  final String produitId;
  @override
  final String nom;
  @override
  @JsonKey(name: 'stock_actuel')
  final int stockActuel;
  @override
  @JsonKey(name: 'stock_alerte')
  final int stockAlerte;
  @override
  @JsonKey(name: 'en_rupture')
  final bool enRupture;

  @override
  String toString() {
    return 'AlerteStockItem(produitId: $produitId, nom: $nom, stockActuel: $stockActuel, stockAlerte: $stockAlerte, enRupture: $enRupture)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AlerteStockItemImpl &&
            (identical(other.produitId, produitId) ||
                other.produitId == produitId) &&
            (identical(other.nom, nom) || other.nom == nom) &&
            (identical(other.stockActuel, stockActuel) ||
                other.stockActuel == stockActuel) &&
            (identical(other.stockAlerte, stockAlerte) ||
                other.stockAlerte == stockAlerte) &&
            (identical(other.enRupture, enRupture) ||
                other.enRupture == enRupture));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, produitId, nom, stockActuel, stockAlerte, enRupture);

  /// Create a copy of AlerteStockItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AlerteStockItemImplCopyWith<_$AlerteStockItemImpl> get copyWith =>
      __$$AlerteStockItemImplCopyWithImpl<_$AlerteStockItemImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AlerteStockItemImplToJson(
      this,
    );
  }
}

abstract class _AlerteStockItem implements AlerteStockItem {
  const factory _AlerteStockItem(
          {@JsonKey(name: 'produit_id') required final String produitId,
          required final String nom,
          @JsonKey(name: 'stock_actuel') required final int stockActuel,
          @JsonKey(name: 'stock_alerte') required final int stockAlerte,
          @JsonKey(name: 'en_rupture') required final bool enRupture}) =
      _$AlerteStockItemImpl;

  factory _AlerteStockItem.fromJson(Map<String, dynamic> json) =
      _$AlerteStockItemImpl.fromJson;

  @override
  @JsonKey(name: 'produit_id')
  String get produitId;
  @override
  String get nom;
  @override
  @JsonKey(name: 'stock_actuel')
  int get stockActuel;
  @override
  @JsonKey(name: 'stock_alerte')
  int get stockAlerte;
  @override
  @JsonKey(name: 'en_rupture')
  bool get enRupture;

  /// Create a copy of AlerteStockItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AlerteStockItemImplCopyWith<_$AlerteStockItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MouvementStockPushResult _$MouvementStockPushResultFromJson(
    Map<String, dynamic> json) {
  return _MouvementStockPushResult.fromJson(json);
}

/// @nodoc
mixin _$MouvementStockPushResult {
  @JsonKey(name: 'id_local_smartphone')
  String get idLocal => throw _privateConstructorUsedError;
  @JsonKey(name: 'mouvement_id')
  String get mouvementId => throw _privateConstructorUsedError;
  @JsonKey(name: 'deja_synchronise')
  bool get dejaSynchronise => throw _privateConstructorUsedError;
  @JsonKey(name: 'stock_actuel')
  int? get stockActuel => throw _privateConstructorUsedError;

  /// Serializes this MouvementStockPushResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MouvementStockPushResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MouvementStockPushResultCopyWith<MouvementStockPushResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MouvementStockPushResultCopyWith<$Res> {
  factory $MouvementStockPushResultCopyWith(MouvementStockPushResult value,
          $Res Function(MouvementStockPushResult) then) =
      _$MouvementStockPushResultCopyWithImpl<$Res, MouvementStockPushResult>;
  @useResult
  $Res call(
      {@JsonKey(name: 'id_local_smartphone') String idLocal,
      @JsonKey(name: 'mouvement_id') String mouvementId,
      @JsonKey(name: 'deja_synchronise') bool dejaSynchronise,
      @JsonKey(name: 'stock_actuel') int? stockActuel});
}

/// @nodoc
class _$MouvementStockPushResultCopyWithImpl<$Res,
        $Val extends MouvementStockPushResult>
    implements $MouvementStockPushResultCopyWith<$Res> {
  _$MouvementStockPushResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MouvementStockPushResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? idLocal = null,
    Object? mouvementId = null,
    Object? dejaSynchronise = null,
    Object? stockActuel = freezed,
  }) {
    return _then(_value.copyWith(
      idLocal: null == idLocal
          ? _value.idLocal
          : idLocal // ignore: cast_nullable_to_non_nullable
              as String,
      mouvementId: null == mouvementId
          ? _value.mouvementId
          : mouvementId // ignore: cast_nullable_to_non_nullable
              as String,
      dejaSynchronise: null == dejaSynchronise
          ? _value.dejaSynchronise
          : dejaSynchronise // ignore: cast_nullable_to_non_nullable
              as bool,
      stockActuel: freezed == stockActuel
          ? _value.stockActuel
          : stockActuel // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MouvementStockPushResultImplCopyWith<$Res>
    implements $MouvementStockPushResultCopyWith<$Res> {
  factory _$$MouvementStockPushResultImplCopyWith(
          _$MouvementStockPushResultImpl value,
          $Res Function(_$MouvementStockPushResultImpl) then) =
      __$$MouvementStockPushResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'id_local_smartphone') String idLocal,
      @JsonKey(name: 'mouvement_id') String mouvementId,
      @JsonKey(name: 'deja_synchronise') bool dejaSynchronise,
      @JsonKey(name: 'stock_actuel') int? stockActuel});
}

/// @nodoc
class __$$MouvementStockPushResultImplCopyWithImpl<$Res>
    extends _$MouvementStockPushResultCopyWithImpl<$Res,
        _$MouvementStockPushResultImpl>
    implements _$$MouvementStockPushResultImplCopyWith<$Res> {
  __$$MouvementStockPushResultImplCopyWithImpl(
      _$MouvementStockPushResultImpl _value,
      $Res Function(_$MouvementStockPushResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of MouvementStockPushResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? idLocal = null,
    Object? mouvementId = null,
    Object? dejaSynchronise = null,
    Object? stockActuel = freezed,
  }) {
    return _then(_$MouvementStockPushResultImpl(
      idLocal: null == idLocal
          ? _value.idLocal
          : idLocal // ignore: cast_nullable_to_non_nullable
              as String,
      mouvementId: null == mouvementId
          ? _value.mouvementId
          : mouvementId // ignore: cast_nullable_to_non_nullable
              as String,
      dejaSynchronise: null == dejaSynchronise
          ? _value.dejaSynchronise
          : dejaSynchronise // ignore: cast_nullable_to_non_nullable
              as bool,
      stockActuel: freezed == stockActuel
          ? _value.stockActuel
          : stockActuel // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MouvementStockPushResultImpl implements _MouvementStockPushResult {
  const _$MouvementStockPushResultImpl(
      {@JsonKey(name: 'id_local_smartphone') required this.idLocal,
      @JsonKey(name: 'mouvement_id') required this.mouvementId,
      @JsonKey(name: 'deja_synchronise') this.dejaSynchronise = false,
      @JsonKey(name: 'stock_actuel') this.stockActuel});

  factory _$MouvementStockPushResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$MouvementStockPushResultImplFromJson(json);

  @override
  @JsonKey(name: 'id_local_smartphone')
  final String idLocal;
  @override
  @JsonKey(name: 'mouvement_id')
  final String mouvementId;
  @override
  @JsonKey(name: 'deja_synchronise')
  final bool dejaSynchronise;
  @override
  @JsonKey(name: 'stock_actuel')
  final int? stockActuel;

  @override
  String toString() {
    return 'MouvementStockPushResult(idLocal: $idLocal, mouvementId: $mouvementId, dejaSynchronise: $dejaSynchronise, stockActuel: $stockActuel)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MouvementStockPushResultImpl &&
            (identical(other.idLocal, idLocal) || other.idLocal == idLocal) &&
            (identical(other.mouvementId, mouvementId) ||
                other.mouvementId == mouvementId) &&
            (identical(other.dejaSynchronise, dejaSynchronise) ||
                other.dejaSynchronise == dejaSynchronise) &&
            (identical(other.stockActuel, stockActuel) ||
                other.stockActuel == stockActuel));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, idLocal, mouvementId, dejaSynchronise, stockActuel);

  /// Create a copy of MouvementStockPushResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MouvementStockPushResultImplCopyWith<_$MouvementStockPushResultImpl>
      get copyWith => __$$MouvementStockPushResultImplCopyWithImpl<
          _$MouvementStockPushResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MouvementStockPushResultImplToJson(
      this,
    );
  }
}

abstract class _MouvementStockPushResult implements MouvementStockPushResult {
  const factory _MouvementStockPushResult(
          {@JsonKey(name: 'id_local_smartphone') required final String idLocal,
          @JsonKey(name: 'mouvement_id') required final String mouvementId,
          @JsonKey(name: 'deja_synchronise') final bool dejaSynchronise,
          @JsonKey(name: 'stock_actuel') final int? stockActuel}) =
      _$MouvementStockPushResultImpl;

  factory _MouvementStockPushResult.fromJson(Map<String, dynamic> json) =
      _$MouvementStockPushResultImpl.fromJson;

  @override
  @JsonKey(name: 'id_local_smartphone')
  String get idLocal;
  @override
  @JsonKey(name: 'mouvement_id')
  String get mouvementId;
  @override
  @JsonKey(name: 'deja_synchronise')
  bool get dejaSynchronise;
  @override
  @JsonKey(name: 'stock_actuel')
  int? get stockActuel;

  /// Create a copy of MouvementStockPushResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MouvementStockPushResultImplCopyWith<_$MouvementStockPushResultImpl>
      get copyWith => throw _privateConstructorUsedError;
}

SyncPushResponse _$SyncPushResponseFromJson(Map<String, dynamic> json) {
  return _SyncPushResponse.fromJson(json);
}

/// @nodoc
mixin _$SyncPushResponse {
  List<VentePushResult> get ventes => throw _privateConstructorUsedError;
  List<dynamic> get depenses => throw _privateConstructorUsedError;
  @JsonKey(name: 'mouvements_stock')
  List<MouvementStockPushResult> get mouvementsStock =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'alertes_stock')
  List<AlerteStockItem> get alertesStock => throw _privateConstructorUsedError;

  /// Serializes this SyncPushResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SyncPushResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SyncPushResponseCopyWith<SyncPushResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SyncPushResponseCopyWith<$Res> {
  factory $SyncPushResponseCopyWith(
          SyncPushResponse value, $Res Function(SyncPushResponse) then) =
      _$SyncPushResponseCopyWithImpl<$Res, SyncPushResponse>;
  @useResult
  $Res call(
      {List<VentePushResult> ventes,
      List<dynamic> depenses,
      @JsonKey(name: 'mouvements_stock')
      List<MouvementStockPushResult> mouvementsStock,
      @JsonKey(name: 'alertes_stock') List<AlerteStockItem> alertesStock});
}

/// @nodoc
class _$SyncPushResponseCopyWithImpl<$Res, $Val extends SyncPushResponse>
    implements $SyncPushResponseCopyWith<$Res> {
  _$SyncPushResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SyncPushResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ventes = null,
    Object? depenses = null,
    Object? mouvementsStock = null,
    Object? alertesStock = null,
  }) {
    return _then(_value.copyWith(
      ventes: null == ventes
          ? _value.ventes
          : ventes // ignore: cast_nullable_to_non_nullable
              as List<VentePushResult>,
      depenses: null == depenses
          ? _value.depenses
          : depenses // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      mouvementsStock: null == mouvementsStock
          ? _value.mouvementsStock
          : mouvementsStock // ignore: cast_nullable_to_non_nullable
              as List<MouvementStockPushResult>,
      alertesStock: null == alertesStock
          ? _value.alertesStock
          : alertesStock // ignore: cast_nullable_to_non_nullable
              as List<AlerteStockItem>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SyncPushResponseImplCopyWith<$Res>
    implements $SyncPushResponseCopyWith<$Res> {
  factory _$$SyncPushResponseImplCopyWith(_$SyncPushResponseImpl value,
          $Res Function(_$SyncPushResponseImpl) then) =
      __$$SyncPushResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<VentePushResult> ventes,
      List<dynamic> depenses,
      @JsonKey(name: 'mouvements_stock')
      List<MouvementStockPushResult> mouvementsStock,
      @JsonKey(name: 'alertes_stock') List<AlerteStockItem> alertesStock});
}

/// @nodoc
class __$$SyncPushResponseImplCopyWithImpl<$Res>
    extends _$SyncPushResponseCopyWithImpl<$Res, _$SyncPushResponseImpl>
    implements _$$SyncPushResponseImplCopyWith<$Res> {
  __$$SyncPushResponseImplCopyWithImpl(_$SyncPushResponseImpl _value,
      $Res Function(_$SyncPushResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of SyncPushResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ventes = null,
    Object? depenses = null,
    Object? mouvementsStock = null,
    Object? alertesStock = null,
  }) {
    return _then(_$SyncPushResponseImpl(
      ventes: null == ventes
          ? _value._ventes
          : ventes // ignore: cast_nullable_to_non_nullable
              as List<VentePushResult>,
      depenses: null == depenses
          ? _value._depenses
          : depenses // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      mouvementsStock: null == mouvementsStock
          ? _value._mouvementsStock
          : mouvementsStock // ignore: cast_nullable_to_non_nullable
              as List<MouvementStockPushResult>,
      alertesStock: null == alertesStock
          ? _value._alertesStock
          : alertesStock // ignore: cast_nullable_to_non_nullable
              as List<AlerteStockItem>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SyncPushResponseImpl implements _SyncPushResponse {
  const _$SyncPushResponseImpl(
      {final List<VentePushResult> ventes = const [],
      final List<dynamic> depenses = const [],
      @JsonKey(name: 'mouvements_stock')
      final List<MouvementStockPushResult> mouvementsStock = const [],
      @JsonKey(name: 'alertes_stock')
      final List<AlerteStockItem> alertesStock = const []})
      : _ventes = ventes,
        _depenses = depenses,
        _mouvementsStock = mouvementsStock,
        _alertesStock = alertesStock;

  factory _$SyncPushResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$SyncPushResponseImplFromJson(json);

  final List<VentePushResult> _ventes;
  @override
  @JsonKey()
  List<VentePushResult> get ventes {
    if (_ventes is EqualUnmodifiableListView) return _ventes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_ventes);
  }

  final List<dynamic> _depenses;
  @override
  @JsonKey()
  List<dynamic> get depenses {
    if (_depenses is EqualUnmodifiableListView) return _depenses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_depenses);
  }

  final List<MouvementStockPushResult> _mouvementsStock;
  @override
  @JsonKey(name: 'mouvements_stock')
  List<MouvementStockPushResult> get mouvementsStock {
    if (_mouvementsStock is EqualUnmodifiableListView) return _mouvementsStock;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_mouvementsStock);
  }

  final List<AlerteStockItem> _alertesStock;
  @override
  @JsonKey(name: 'alertes_stock')
  List<AlerteStockItem> get alertesStock {
    if (_alertesStock is EqualUnmodifiableListView) return _alertesStock;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_alertesStock);
  }

  @override
  String toString() {
    return 'SyncPushResponse(ventes: $ventes, depenses: $depenses, mouvementsStock: $mouvementsStock, alertesStock: $alertesStock)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SyncPushResponseImpl &&
            const DeepCollectionEquality().equals(other._ventes, _ventes) &&
            const DeepCollectionEquality().equals(other._depenses, _depenses) &&
            const DeepCollectionEquality()
                .equals(other._mouvementsStock, _mouvementsStock) &&
            const DeepCollectionEquality()
                .equals(other._alertesStock, _alertesStock));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_ventes),
      const DeepCollectionEquality().hash(_depenses),
      const DeepCollectionEquality().hash(_mouvementsStock),
      const DeepCollectionEquality().hash(_alertesStock));

  /// Create a copy of SyncPushResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SyncPushResponseImplCopyWith<_$SyncPushResponseImpl> get copyWith =>
      __$$SyncPushResponseImplCopyWithImpl<_$SyncPushResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SyncPushResponseImplToJson(
      this,
    );
  }
}

abstract class _SyncPushResponse implements SyncPushResponse {
  const factory _SyncPushResponse(
      {final List<VentePushResult> ventes,
      final List<dynamic> depenses,
      @JsonKey(name: 'mouvements_stock')
      final List<MouvementStockPushResult> mouvementsStock,
      @JsonKey(name: 'alertes_stock')
      final List<AlerteStockItem> alertesStock}) = _$SyncPushResponseImpl;

  factory _SyncPushResponse.fromJson(Map<String, dynamic> json) =
      _$SyncPushResponseImpl.fromJson;

  @override
  List<VentePushResult> get ventes;
  @override
  List<dynamic> get depenses;
  @override
  @JsonKey(name: 'mouvements_stock')
  List<MouvementStockPushResult> get mouvementsStock;
  @override
  @JsonKey(name: 'alertes_stock')
  List<AlerteStockItem> get alertesStock;

  /// Create a copy of SyncPushResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SyncPushResponseImplCopyWith<_$SyncPushResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SyncPullResponse _$SyncPullResponseFromJson(Map<String, dynamic> json) {
  return _SyncPullResponse.fromJson(json);
}

/// @nodoc
mixin _$SyncPullResponse {
  @JsonKey(name: 'boutique_id')
  String get boutiqueId => throw _privateConstructorUsedError;
  List<ProduitModelLite> get produits => throw _privateConstructorUsedError;
  List<CategorieModelLite> get categories => throw _privateConstructorUsedError;
  @JsonKey(name: 'server_time')
  DateTime get serverTime => throw _privateConstructorUsedError;

  /// Serializes this SyncPullResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SyncPullResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SyncPullResponseCopyWith<SyncPullResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SyncPullResponseCopyWith<$Res> {
  factory $SyncPullResponseCopyWith(
          SyncPullResponse value, $Res Function(SyncPullResponse) then) =
      _$SyncPullResponseCopyWithImpl<$Res, SyncPullResponse>;
  @useResult
  $Res call(
      {@JsonKey(name: 'boutique_id') String boutiqueId,
      List<ProduitModelLite> produits,
      List<CategorieModelLite> categories,
      @JsonKey(name: 'server_time') DateTime serverTime});
}

/// @nodoc
class _$SyncPullResponseCopyWithImpl<$Res, $Val extends SyncPullResponse>
    implements $SyncPullResponseCopyWith<$Res> {
  _$SyncPullResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SyncPullResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? boutiqueId = null,
    Object? produits = null,
    Object? categories = null,
    Object? serverTime = null,
  }) {
    return _then(_value.copyWith(
      boutiqueId: null == boutiqueId
          ? _value.boutiqueId
          : boutiqueId // ignore: cast_nullable_to_non_nullable
              as String,
      produits: null == produits
          ? _value.produits
          : produits // ignore: cast_nullable_to_non_nullable
              as List<ProduitModelLite>,
      categories: null == categories
          ? _value.categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<CategorieModelLite>,
      serverTime: null == serverTime
          ? _value.serverTime
          : serverTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SyncPullResponseImplCopyWith<$Res>
    implements $SyncPullResponseCopyWith<$Res> {
  factory _$$SyncPullResponseImplCopyWith(_$SyncPullResponseImpl value,
          $Res Function(_$SyncPullResponseImpl) then) =
      __$$SyncPullResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'boutique_id') String boutiqueId,
      List<ProduitModelLite> produits,
      List<CategorieModelLite> categories,
      @JsonKey(name: 'server_time') DateTime serverTime});
}

/// @nodoc
class __$$SyncPullResponseImplCopyWithImpl<$Res>
    extends _$SyncPullResponseCopyWithImpl<$Res, _$SyncPullResponseImpl>
    implements _$$SyncPullResponseImplCopyWith<$Res> {
  __$$SyncPullResponseImplCopyWithImpl(_$SyncPullResponseImpl _value,
      $Res Function(_$SyncPullResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of SyncPullResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? boutiqueId = null,
    Object? produits = null,
    Object? categories = null,
    Object? serverTime = null,
  }) {
    return _then(_$SyncPullResponseImpl(
      boutiqueId: null == boutiqueId
          ? _value.boutiqueId
          : boutiqueId // ignore: cast_nullable_to_non_nullable
              as String,
      produits: null == produits
          ? _value._produits
          : produits // ignore: cast_nullable_to_non_nullable
              as List<ProduitModelLite>,
      categories: null == categories
          ? _value._categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<CategorieModelLite>,
      serverTime: null == serverTime
          ? _value.serverTime
          : serverTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SyncPullResponseImpl implements _SyncPullResponse {
  const _$SyncPullResponseImpl(
      {@JsonKey(name: 'boutique_id') required this.boutiqueId,
      required final List<ProduitModelLite> produits,
      required final List<CategorieModelLite> categories,
      @JsonKey(name: 'server_time') required this.serverTime})
      : _produits = produits,
        _categories = categories;

  factory _$SyncPullResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$SyncPullResponseImplFromJson(json);

  @override
  @JsonKey(name: 'boutique_id')
  final String boutiqueId;
  final List<ProduitModelLite> _produits;
  @override
  List<ProduitModelLite> get produits {
    if (_produits is EqualUnmodifiableListView) return _produits;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_produits);
  }

  final List<CategorieModelLite> _categories;
  @override
  List<CategorieModelLite> get categories {
    if (_categories is EqualUnmodifiableListView) return _categories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_categories);
  }

  @override
  @JsonKey(name: 'server_time')
  final DateTime serverTime;

  @override
  String toString() {
    return 'SyncPullResponse(boutiqueId: $boutiqueId, produits: $produits, categories: $categories, serverTime: $serverTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SyncPullResponseImpl &&
            (identical(other.boutiqueId, boutiqueId) ||
                other.boutiqueId == boutiqueId) &&
            const DeepCollectionEquality().equals(other._produits, _produits) &&
            const DeepCollectionEquality()
                .equals(other._categories, _categories) &&
            (identical(other.serverTime, serverTime) ||
                other.serverTime == serverTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      boutiqueId,
      const DeepCollectionEquality().hash(_produits),
      const DeepCollectionEquality().hash(_categories),
      serverTime);

  /// Create a copy of SyncPullResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SyncPullResponseImplCopyWith<_$SyncPullResponseImpl> get copyWith =>
      __$$SyncPullResponseImplCopyWithImpl<_$SyncPullResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SyncPullResponseImplToJson(
      this,
    );
  }
}

abstract class _SyncPullResponse implements SyncPullResponse {
  const factory _SyncPullResponse(
          {@JsonKey(name: 'boutique_id') required final String boutiqueId,
          required final List<ProduitModelLite> produits,
          required final List<CategorieModelLite> categories,
          @JsonKey(name: 'server_time') required final DateTime serverTime}) =
      _$SyncPullResponseImpl;

  factory _SyncPullResponse.fromJson(Map<String, dynamic> json) =
      _$SyncPullResponseImpl.fromJson;

  @override
  @JsonKey(name: 'boutique_id')
  String get boutiqueId;
  @override
  List<ProduitModelLite> get produits;
  @override
  List<CategorieModelLite> get categories;
  @override
  @JsonKey(name: 'server_time')
  DateTime get serverTime;

  /// Create a copy of SyncPullResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SyncPullResponseImplCopyWith<_$SyncPullResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProduitModelLite _$ProduitModelLiteFromJson(Map<String, dynamic> json) {
  return _ProduitModelLite.fromJson(json);
}

/// @nodoc
mixin _$ProduitModelLite {
  String get id => throw _privateConstructorUsedError;
  String get nom => throw _privateConstructorUsedError;
  @JsonKey(name: 'prix_achat_moyen', fromJson: parseDouble)
  double get prixAchatMoyen => throw _privateConstructorUsedError;
  @JsonKey(name: 'prix_vente_suggere', fromJson: parseDouble)
  double get prixVenteSuggere => throw _privateConstructorUsedError;
  @JsonKey(name: 'stock_actuel')
  int get stockActuel => throw _privateConstructorUsedError;
  @JsonKey(name: 'stock_alerte')
  int get stockAlerte => throw _privateConstructorUsedError;
  @JsonKey(name: 'categorie_id')
  String? get categorieId => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_url')
  String? get imageUrl => throw _privateConstructorUsedError;

  /// Serializes this ProduitModelLite to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProduitModelLite
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProduitModelLiteCopyWith<ProduitModelLite> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProduitModelLiteCopyWith<$Res> {
  factory $ProduitModelLiteCopyWith(
          ProduitModelLite value, $Res Function(ProduitModelLite) then) =
      _$ProduitModelLiteCopyWithImpl<$Res, ProduitModelLite>;
  @useResult
  $Res call(
      {String id,
      String nom,
      @JsonKey(name: 'prix_achat_moyen', fromJson: parseDouble)
      double prixAchatMoyen,
      @JsonKey(name: 'prix_vente_suggere', fromJson: parseDouble)
      double prixVenteSuggere,
      @JsonKey(name: 'stock_actuel') int stockActuel,
      @JsonKey(name: 'stock_alerte') int stockAlerte,
      @JsonKey(name: 'categorie_id') String? categorieId,
      @JsonKey(name: 'image_url') String? imageUrl});
}

/// @nodoc
class _$ProduitModelLiteCopyWithImpl<$Res, $Val extends ProduitModelLite>
    implements $ProduitModelLiteCopyWith<$Res> {
  _$ProduitModelLiteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProduitModelLite
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nom = null,
    Object? prixAchatMoyen = null,
    Object? prixVenteSuggere = null,
    Object? stockActuel = null,
    Object? stockAlerte = null,
    Object? categorieId = freezed,
    Object? imageUrl = freezed,
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
      categorieId: freezed == categorieId
          ? _value.categorieId
          : categorieId // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProduitModelLiteImplCopyWith<$Res>
    implements $ProduitModelLiteCopyWith<$Res> {
  factory _$$ProduitModelLiteImplCopyWith(_$ProduitModelLiteImpl value,
          $Res Function(_$ProduitModelLiteImpl) then) =
      __$$ProduitModelLiteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String nom,
      @JsonKey(name: 'prix_achat_moyen', fromJson: parseDouble)
      double prixAchatMoyen,
      @JsonKey(name: 'prix_vente_suggere', fromJson: parseDouble)
      double prixVenteSuggere,
      @JsonKey(name: 'stock_actuel') int stockActuel,
      @JsonKey(name: 'stock_alerte') int stockAlerte,
      @JsonKey(name: 'categorie_id') String? categorieId,
      @JsonKey(name: 'image_url') String? imageUrl});
}

/// @nodoc
class __$$ProduitModelLiteImplCopyWithImpl<$Res>
    extends _$ProduitModelLiteCopyWithImpl<$Res, _$ProduitModelLiteImpl>
    implements _$$ProduitModelLiteImplCopyWith<$Res> {
  __$$ProduitModelLiteImplCopyWithImpl(_$ProduitModelLiteImpl _value,
      $Res Function(_$ProduitModelLiteImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProduitModelLite
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nom = null,
    Object? prixAchatMoyen = null,
    Object? prixVenteSuggere = null,
    Object? stockActuel = null,
    Object? stockAlerte = null,
    Object? categorieId = freezed,
    Object? imageUrl = freezed,
  }) {
    return _then(_$ProduitModelLiteImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
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
      categorieId: freezed == categorieId
          ? _value.categorieId
          : categorieId // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProduitModelLiteImpl implements _ProduitModelLite {
  const _$ProduitModelLiteImpl(
      {required this.id,
      required this.nom,
      @JsonKey(name: 'prix_achat_moyen', fromJson: parseDouble)
      required this.prixAchatMoyen,
      @JsonKey(name: 'prix_vente_suggere', fromJson: parseDouble)
      required this.prixVenteSuggere,
      @JsonKey(name: 'stock_actuel') required this.stockActuel,
      @JsonKey(name: 'stock_alerte') required this.stockAlerte,
      @JsonKey(name: 'categorie_id') this.categorieId,
      @JsonKey(name: 'image_url') this.imageUrl});

  factory _$ProduitModelLiteImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProduitModelLiteImplFromJson(json);

  @override
  final String id;
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
  @JsonKey(name: 'categorie_id')
  final String? categorieId;
  @override
  @JsonKey(name: 'image_url')
  final String? imageUrl;

  @override
  String toString() {
    return 'ProduitModelLite(id: $id, nom: $nom, prixAchatMoyen: $prixAchatMoyen, prixVenteSuggere: $prixVenteSuggere, stockActuel: $stockActuel, stockAlerte: $stockAlerte, categorieId: $categorieId, imageUrl: $imageUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProduitModelLiteImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nom, nom) || other.nom == nom) &&
            (identical(other.prixAchatMoyen, prixAchatMoyen) ||
                other.prixAchatMoyen == prixAchatMoyen) &&
            (identical(other.prixVenteSuggere, prixVenteSuggere) ||
                other.prixVenteSuggere == prixVenteSuggere) &&
            (identical(other.stockActuel, stockActuel) ||
                other.stockActuel == stockActuel) &&
            (identical(other.stockAlerte, stockAlerte) ||
                other.stockAlerte == stockAlerte) &&
            (identical(other.categorieId, categorieId) ||
                other.categorieId == categorieId) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, nom, prixAchatMoyen,
      prixVenteSuggere, stockActuel, stockAlerte, categorieId, imageUrl);

  /// Create a copy of ProduitModelLite
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProduitModelLiteImplCopyWith<_$ProduitModelLiteImpl> get copyWith =>
      __$$ProduitModelLiteImplCopyWithImpl<_$ProduitModelLiteImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProduitModelLiteImplToJson(
      this,
    );
  }
}

abstract class _ProduitModelLite implements ProduitModelLite {
  const factory _ProduitModelLite(
          {required final String id,
          required final String nom,
          @JsonKey(name: 'prix_achat_moyen', fromJson: parseDouble)
          required final double prixAchatMoyen,
          @JsonKey(name: 'prix_vente_suggere', fromJson: parseDouble)
          required final double prixVenteSuggere,
          @JsonKey(name: 'stock_actuel') required final int stockActuel,
          @JsonKey(name: 'stock_alerte') required final int stockAlerte,
          @JsonKey(name: 'categorie_id') final String? categorieId,
          @JsonKey(name: 'image_url') final String? imageUrl}) =
      _$ProduitModelLiteImpl;

  factory _ProduitModelLite.fromJson(Map<String, dynamic> json) =
      _$ProduitModelLiteImpl.fromJson;

  @override
  String get id;
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
  @override
  @JsonKey(name: 'categorie_id')
  String? get categorieId;
  @override
  @JsonKey(name: 'image_url')
  String? get imageUrl;

  /// Create a copy of ProduitModelLite
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProduitModelLiteImplCopyWith<_$ProduitModelLiteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CategorieModelLite _$CategorieModelLiteFromJson(Map<String, dynamic> json) {
  return _CategorieModelLite.fromJson(json);
}

/// @nodoc
mixin _$CategorieModelLite {
  String get id => throw _privateConstructorUsedError;
  String get nom => throw _privateConstructorUsedError;

  /// Serializes this CategorieModelLite to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CategorieModelLite
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CategorieModelLiteCopyWith<CategorieModelLite> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CategorieModelLiteCopyWith<$Res> {
  factory $CategorieModelLiteCopyWith(
          CategorieModelLite value, $Res Function(CategorieModelLite) then) =
      _$CategorieModelLiteCopyWithImpl<$Res, CategorieModelLite>;
  @useResult
  $Res call({String id, String nom});
}

/// @nodoc
class _$CategorieModelLiteCopyWithImpl<$Res, $Val extends CategorieModelLite>
    implements $CategorieModelLiteCopyWith<$Res> {
  _$CategorieModelLiteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CategorieModelLite
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nom = null,
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
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CategorieModelLiteImplCopyWith<$Res>
    implements $CategorieModelLiteCopyWith<$Res> {
  factory _$$CategorieModelLiteImplCopyWith(_$CategorieModelLiteImpl value,
          $Res Function(_$CategorieModelLiteImpl) then) =
      __$$CategorieModelLiteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String nom});
}

/// @nodoc
class __$$CategorieModelLiteImplCopyWithImpl<$Res>
    extends _$CategorieModelLiteCopyWithImpl<$Res, _$CategorieModelLiteImpl>
    implements _$$CategorieModelLiteImplCopyWith<$Res> {
  __$$CategorieModelLiteImplCopyWithImpl(_$CategorieModelLiteImpl _value,
      $Res Function(_$CategorieModelLiteImpl) _then)
      : super(_value, _then);

  /// Create a copy of CategorieModelLite
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nom = null,
  }) {
    return _then(_$CategorieModelLiteImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
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
class _$CategorieModelLiteImpl implements _CategorieModelLite {
  const _$CategorieModelLiteImpl({required this.id, required this.nom});

  factory _$CategorieModelLiteImpl.fromJson(Map<String, dynamic> json) =>
      _$$CategorieModelLiteImplFromJson(json);

  @override
  final String id;
  @override
  final String nom;

  @override
  String toString() {
    return 'CategorieModelLite(id: $id, nom: $nom)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CategorieModelLiteImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nom, nom) || other.nom == nom));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, nom);

  /// Create a copy of CategorieModelLite
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CategorieModelLiteImplCopyWith<_$CategorieModelLiteImpl> get copyWith =>
      __$$CategorieModelLiteImplCopyWithImpl<_$CategorieModelLiteImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CategorieModelLiteImplToJson(
      this,
    );
  }
}

abstract class _CategorieModelLite implements CategorieModelLite {
  const factory _CategorieModelLite(
      {required final String id,
      required final String nom}) = _$CategorieModelLiteImpl;

  factory _CategorieModelLite.fromJson(Map<String, dynamic> json) =
      _$CategorieModelLiteImpl.fromJson;

  @override
  String get id;
  @override
  String get nom;

  /// Create a copy of CategorieModelLite
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CategorieModelLiteImplCopyWith<_$CategorieModelLiteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
