// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'abonnement_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AbonnementOut _$AbonnementOutFromJson(Map<String, dynamic> json) {
  return _AbonnementOut.fromJson(json);
}

/// @nodoc
mixin _$AbonnementOut {
  @JsonKey(name: 'proprietaire_id')
  String get proprietaireId => throw _privateConstructorUsedError;
  String get plan => throw _privateConstructorUsedError;
  @JsonKey(name: 'quota_ventes_par_boutique')
  int get quotaVentesParBoutique => throw _privateConstructorUsedError;
  @JsonKey(name: 'prix_base')
  double get prixBase => throw _privateConstructorUsedError;
  @JsonKey(name: 'nb_boutiques')
  int get nbBoutiques => throw _privateConstructorUsedError;
  @JsonKey(name: 'prix_total_mensuel')
  double get prixTotalMensuel => throw _privateConstructorUsedError;
  DateTime? get dateFin => throw _privateConstructorUsedError;
  bool get actif => throw _privateConstructorUsedError;

  /// Serializes this AbonnementOut to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AbonnementOut
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AbonnementOutCopyWith<AbonnementOut> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AbonnementOutCopyWith<$Res> {
  factory $AbonnementOutCopyWith(
          AbonnementOut value, $Res Function(AbonnementOut) then) =
      _$AbonnementOutCopyWithImpl<$Res, AbonnementOut>;
  @useResult
  $Res call(
      {@JsonKey(name: 'proprietaire_id') String proprietaireId,
      String plan,
      @JsonKey(name: 'quota_ventes_par_boutique') int quotaVentesParBoutique,
      @JsonKey(name: 'prix_base') double prixBase,
      @JsonKey(name: 'nb_boutiques') int nbBoutiques,
      @JsonKey(name: 'prix_total_mensuel') double prixTotalMensuel,
      DateTime? dateFin,
      bool actif});
}

/// @nodoc
class _$AbonnementOutCopyWithImpl<$Res, $Val extends AbonnementOut>
    implements $AbonnementOutCopyWith<$Res> {
  _$AbonnementOutCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AbonnementOut
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? proprietaireId = null,
    Object? plan = null,
    Object? quotaVentesParBoutique = null,
    Object? prixBase = null,
    Object? nbBoutiques = null,
    Object? prixTotalMensuel = null,
    Object? dateFin = freezed,
    Object? actif = null,
  }) {
    return _then(_value.copyWith(
      proprietaireId: null == proprietaireId
          ? _value.proprietaireId
          : proprietaireId // ignore: cast_nullable_to_non_nullable
              as String,
      plan: null == plan
          ? _value.plan
          : plan // ignore: cast_nullable_to_non_nullable
              as String,
      quotaVentesParBoutique: null == quotaVentesParBoutique
          ? _value.quotaVentesParBoutique
          : quotaVentesParBoutique // ignore: cast_nullable_to_non_nullable
              as int,
      prixBase: null == prixBase
          ? _value.prixBase
          : prixBase // ignore: cast_nullable_to_non_nullable
              as double,
      nbBoutiques: null == nbBoutiques
          ? _value.nbBoutiques
          : nbBoutiques // ignore: cast_nullable_to_non_nullable
              as int,
      prixTotalMensuel: null == prixTotalMensuel
          ? _value.prixTotalMensuel
          : prixTotalMensuel // ignore: cast_nullable_to_non_nullable
              as double,
      dateFin: freezed == dateFin
          ? _value.dateFin
          : dateFin // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      actif: null == actif
          ? _value.actif
          : actif // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AbonnementOutImplCopyWith<$Res>
    implements $AbonnementOutCopyWith<$Res> {
  factory _$$AbonnementOutImplCopyWith(
          _$AbonnementOutImpl value, $Res Function(_$AbonnementOutImpl) then) =
      __$$AbonnementOutImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'proprietaire_id') String proprietaireId,
      String plan,
      @JsonKey(name: 'quota_ventes_par_boutique') int quotaVentesParBoutique,
      @JsonKey(name: 'prix_base') double prixBase,
      @JsonKey(name: 'nb_boutiques') int nbBoutiques,
      @JsonKey(name: 'prix_total_mensuel') double prixTotalMensuel,
      DateTime? dateFin,
      bool actif});
}

/// @nodoc
class __$$AbonnementOutImplCopyWithImpl<$Res>
    extends _$AbonnementOutCopyWithImpl<$Res, _$AbonnementOutImpl>
    implements _$$AbonnementOutImplCopyWith<$Res> {
  __$$AbonnementOutImplCopyWithImpl(
      _$AbonnementOutImpl _value, $Res Function(_$AbonnementOutImpl) _then)
      : super(_value, _then);

  /// Create a copy of AbonnementOut
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? proprietaireId = null,
    Object? plan = null,
    Object? quotaVentesParBoutique = null,
    Object? prixBase = null,
    Object? nbBoutiques = null,
    Object? prixTotalMensuel = null,
    Object? dateFin = freezed,
    Object? actif = null,
  }) {
    return _then(_$AbonnementOutImpl(
      proprietaireId: null == proprietaireId
          ? _value.proprietaireId
          : proprietaireId // ignore: cast_nullable_to_non_nullable
              as String,
      plan: null == plan
          ? _value.plan
          : plan // ignore: cast_nullable_to_non_nullable
              as String,
      quotaVentesParBoutique: null == quotaVentesParBoutique
          ? _value.quotaVentesParBoutique
          : quotaVentesParBoutique // ignore: cast_nullable_to_non_nullable
              as int,
      prixBase: null == prixBase
          ? _value.prixBase
          : prixBase // ignore: cast_nullable_to_non_nullable
              as double,
      nbBoutiques: null == nbBoutiques
          ? _value.nbBoutiques
          : nbBoutiques // ignore: cast_nullable_to_non_nullable
              as int,
      prixTotalMensuel: null == prixTotalMensuel
          ? _value.prixTotalMensuel
          : prixTotalMensuel // ignore: cast_nullable_to_non_nullable
              as double,
      dateFin: freezed == dateFin
          ? _value.dateFin
          : dateFin // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      actif: null == actif
          ? _value.actif
          : actif // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AbonnementOutImpl implements _AbonnementOut {
  const _$AbonnementOutImpl(
      {@JsonKey(name: 'proprietaire_id') required this.proprietaireId,
      required this.plan,
      @JsonKey(name: 'quota_ventes_par_boutique')
      required this.quotaVentesParBoutique,
      @JsonKey(name: 'prix_base') this.prixBase = 5000,
      @JsonKey(name: 'nb_boutiques') this.nbBoutiques = 1,
      @JsonKey(name: 'prix_total_mensuel') this.prixTotalMensuel = 5000,
      this.dateFin,
      this.actif = true});

  factory _$AbonnementOutImpl.fromJson(Map<String, dynamic> json) =>
      _$$AbonnementOutImplFromJson(json);

  @override
  @JsonKey(name: 'proprietaire_id')
  final String proprietaireId;
  @override
  final String plan;
  @override
  @JsonKey(name: 'quota_ventes_par_boutique')
  final int quotaVentesParBoutique;
  @override
  @JsonKey(name: 'prix_base')
  final double prixBase;
  @override
  @JsonKey(name: 'nb_boutiques')
  final int nbBoutiques;
  @override
  @JsonKey(name: 'prix_total_mensuel')
  final double prixTotalMensuel;
  @override
  final DateTime? dateFin;
  @override
  @JsonKey()
  final bool actif;

  @override
  String toString() {
    return 'AbonnementOut(proprietaireId: $proprietaireId, plan: $plan, quotaVentesParBoutique: $quotaVentesParBoutique, prixBase: $prixBase, nbBoutiques: $nbBoutiques, prixTotalMensuel: $prixTotalMensuel, dateFin: $dateFin, actif: $actif)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AbonnementOutImpl &&
            (identical(other.proprietaireId, proprietaireId) ||
                other.proprietaireId == proprietaireId) &&
            (identical(other.plan, plan) || other.plan == plan) &&
            (identical(other.quotaVentesParBoutique, quotaVentesParBoutique) ||
                other.quotaVentesParBoutique == quotaVentesParBoutique) &&
            (identical(other.prixBase, prixBase) ||
                other.prixBase == prixBase) &&
            (identical(other.nbBoutiques, nbBoutiques) ||
                other.nbBoutiques == nbBoutiques) &&
            (identical(other.prixTotalMensuel, prixTotalMensuel) ||
                other.prixTotalMensuel == prixTotalMensuel) &&
            (identical(other.dateFin, dateFin) || other.dateFin == dateFin) &&
            (identical(other.actif, actif) || other.actif == actif));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      proprietaireId,
      plan,
      quotaVentesParBoutique,
      prixBase,
      nbBoutiques,
      prixTotalMensuel,
      dateFin,
      actif);

  /// Create a copy of AbonnementOut
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AbonnementOutImplCopyWith<_$AbonnementOutImpl> get copyWith =>
      __$$AbonnementOutImplCopyWithImpl<_$AbonnementOutImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AbonnementOutImplToJson(
      this,
    );
  }
}

abstract class _AbonnementOut implements AbonnementOut {
  const factory _AbonnementOut(
      {@JsonKey(name: 'proprietaire_id') required final String proprietaireId,
      required final String plan,
      @JsonKey(name: 'quota_ventes_par_boutique')
      required final int quotaVentesParBoutique,
      @JsonKey(name: 'prix_base') final double prixBase,
      @JsonKey(name: 'nb_boutiques') final int nbBoutiques,
      @JsonKey(name: 'prix_total_mensuel') final double prixTotalMensuel,
      final DateTime? dateFin,
      final bool actif}) = _$AbonnementOutImpl;

  factory _AbonnementOut.fromJson(Map<String, dynamic> json) =
      _$AbonnementOutImpl.fromJson;

  @override
  @JsonKey(name: 'proprietaire_id')
  String get proprietaireId;
  @override
  String get plan;
  @override
  @JsonKey(name: 'quota_ventes_par_boutique')
  int get quotaVentesParBoutique;
  @override
  @JsonKey(name: 'prix_base')
  double get prixBase;
  @override
  @JsonKey(name: 'nb_boutiques')
  int get nbBoutiques;
  @override
  @JsonKey(name: 'prix_total_mensuel')
  double get prixTotalMensuel;
  @override
  DateTime? get dateFin;
  @override
  bool get actif;

  /// Create a copy of AbonnementOut
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AbonnementOutImplCopyWith<_$AbonnementOutImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

QuotaInfo _$QuotaInfoFromJson(Map<String, dynamic> json) {
  return _QuotaInfo.fromJson(json);
}

/// @nodoc
mixin _$QuotaInfo {
  @JsonKey(name: 'boutique_id')
  String get boutiqueId => throw _privateConstructorUsedError;
  String get plan => throw _privateConstructorUsedError;
  @JsonKey(name: 'quota_par_boutique')
  int get quotaParBoutique => throw _privateConstructorUsedError;
  @JsonKey(name: 'ventes_ce_mois')
  int get ventesCeMois => throw _privateConstructorUsedError;
  @JsonKey(name: 'ventes_restantes')
  int? get ventesRestantes => throw _privateConstructorUsedError;
  bool get illimite => throw _privateConstructorUsedError;

  /// Serializes this QuotaInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of QuotaInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QuotaInfoCopyWith<QuotaInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuotaInfoCopyWith<$Res> {
  factory $QuotaInfoCopyWith(QuotaInfo value, $Res Function(QuotaInfo) then) =
      _$QuotaInfoCopyWithImpl<$Res, QuotaInfo>;
  @useResult
  $Res call(
      {@JsonKey(name: 'boutique_id') String boutiqueId,
      String plan,
      @JsonKey(name: 'quota_par_boutique') int quotaParBoutique,
      @JsonKey(name: 'ventes_ce_mois') int ventesCeMois,
      @JsonKey(name: 'ventes_restantes') int? ventesRestantes,
      bool illimite});
}

/// @nodoc
class _$QuotaInfoCopyWithImpl<$Res, $Val extends QuotaInfo>
    implements $QuotaInfoCopyWith<$Res> {
  _$QuotaInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of QuotaInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? boutiqueId = null,
    Object? plan = null,
    Object? quotaParBoutique = null,
    Object? ventesCeMois = null,
    Object? ventesRestantes = freezed,
    Object? illimite = null,
  }) {
    return _then(_value.copyWith(
      boutiqueId: null == boutiqueId
          ? _value.boutiqueId
          : boutiqueId // ignore: cast_nullable_to_non_nullable
              as String,
      plan: null == plan
          ? _value.plan
          : plan // ignore: cast_nullable_to_non_nullable
              as String,
      quotaParBoutique: null == quotaParBoutique
          ? _value.quotaParBoutique
          : quotaParBoutique // ignore: cast_nullable_to_non_nullable
              as int,
      ventesCeMois: null == ventesCeMois
          ? _value.ventesCeMois
          : ventesCeMois // ignore: cast_nullable_to_non_nullable
              as int,
      ventesRestantes: freezed == ventesRestantes
          ? _value.ventesRestantes
          : ventesRestantes // ignore: cast_nullable_to_non_nullable
              as int?,
      illimite: null == illimite
          ? _value.illimite
          : illimite // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$QuotaInfoImplCopyWith<$Res>
    implements $QuotaInfoCopyWith<$Res> {
  factory _$$QuotaInfoImplCopyWith(
          _$QuotaInfoImpl value, $Res Function(_$QuotaInfoImpl) then) =
      __$$QuotaInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'boutique_id') String boutiqueId,
      String plan,
      @JsonKey(name: 'quota_par_boutique') int quotaParBoutique,
      @JsonKey(name: 'ventes_ce_mois') int ventesCeMois,
      @JsonKey(name: 'ventes_restantes') int? ventesRestantes,
      bool illimite});
}

/// @nodoc
class __$$QuotaInfoImplCopyWithImpl<$Res>
    extends _$QuotaInfoCopyWithImpl<$Res, _$QuotaInfoImpl>
    implements _$$QuotaInfoImplCopyWith<$Res> {
  __$$QuotaInfoImplCopyWithImpl(
      _$QuotaInfoImpl _value, $Res Function(_$QuotaInfoImpl) _then)
      : super(_value, _then);

  /// Create a copy of QuotaInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? boutiqueId = null,
    Object? plan = null,
    Object? quotaParBoutique = null,
    Object? ventesCeMois = null,
    Object? ventesRestantes = freezed,
    Object? illimite = null,
  }) {
    return _then(_$QuotaInfoImpl(
      boutiqueId: null == boutiqueId
          ? _value.boutiqueId
          : boutiqueId // ignore: cast_nullable_to_non_nullable
              as String,
      plan: null == plan
          ? _value.plan
          : plan // ignore: cast_nullable_to_non_nullable
              as String,
      quotaParBoutique: null == quotaParBoutique
          ? _value.quotaParBoutique
          : quotaParBoutique // ignore: cast_nullable_to_non_nullable
              as int,
      ventesCeMois: null == ventesCeMois
          ? _value.ventesCeMois
          : ventesCeMois // ignore: cast_nullable_to_non_nullable
              as int,
      ventesRestantes: freezed == ventesRestantes
          ? _value.ventesRestantes
          : ventesRestantes // ignore: cast_nullable_to_non_nullable
              as int?,
      illimite: null == illimite
          ? _value.illimite
          : illimite // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$QuotaInfoImpl implements _QuotaInfo {
  const _$QuotaInfoImpl(
      {@JsonKey(name: 'boutique_id') required this.boutiqueId,
      required this.plan,
      @JsonKey(name: 'quota_par_boutique') required this.quotaParBoutique,
      @JsonKey(name: 'ventes_ce_mois') this.ventesCeMois = 0,
      @JsonKey(name: 'ventes_restantes') this.ventesRestantes,
      this.illimite = false});

  factory _$QuotaInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$QuotaInfoImplFromJson(json);

  @override
  @JsonKey(name: 'boutique_id')
  final String boutiqueId;
  @override
  final String plan;
  @override
  @JsonKey(name: 'quota_par_boutique')
  final int quotaParBoutique;
  @override
  @JsonKey(name: 'ventes_ce_mois')
  final int ventesCeMois;
  @override
  @JsonKey(name: 'ventes_restantes')
  final int? ventesRestantes;
  @override
  @JsonKey()
  final bool illimite;

  @override
  String toString() {
    return 'QuotaInfo(boutiqueId: $boutiqueId, plan: $plan, quotaParBoutique: $quotaParBoutique, ventesCeMois: $ventesCeMois, ventesRestantes: $ventesRestantes, illimite: $illimite)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuotaInfoImpl &&
            (identical(other.boutiqueId, boutiqueId) ||
                other.boutiqueId == boutiqueId) &&
            (identical(other.plan, plan) || other.plan == plan) &&
            (identical(other.quotaParBoutique, quotaParBoutique) ||
                other.quotaParBoutique == quotaParBoutique) &&
            (identical(other.ventesCeMois, ventesCeMois) ||
                other.ventesCeMois == ventesCeMois) &&
            (identical(other.ventesRestantes, ventesRestantes) ||
                other.ventesRestantes == ventesRestantes) &&
            (identical(other.illimite, illimite) ||
                other.illimite == illimite));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, boutiqueId, plan,
      quotaParBoutique, ventesCeMois, ventesRestantes, illimite);

  /// Create a copy of QuotaInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QuotaInfoImplCopyWith<_$QuotaInfoImpl> get copyWith =>
      __$$QuotaInfoImplCopyWithImpl<_$QuotaInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QuotaInfoImplToJson(
      this,
    );
  }
}

abstract class _QuotaInfo implements QuotaInfo {
  const factory _QuotaInfo(
      {@JsonKey(name: 'boutique_id') required final String boutiqueId,
      required final String plan,
      @JsonKey(name: 'quota_par_boutique') required final int quotaParBoutique,
      @JsonKey(name: 'ventes_ce_mois') final int ventesCeMois,
      @JsonKey(name: 'ventes_restantes') final int? ventesRestantes,
      final bool illimite}) = _$QuotaInfoImpl;

  factory _QuotaInfo.fromJson(Map<String, dynamic> json) =
      _$QuotaInfoImpl.fromJson;

  @override
  @JsonKey(name: 'boutique_id')
  String get boutiqueId;
  @override
  String get plan;
  @override
  @JsonKey(name: 'quota_par_boutique')
  int get quotaParBoutique;
  @override
  @JsonKey(name: 'ventes_ce_mois')
  int get ventesCeMois;
  @override
  @JsonKey(name: 'ventes_restantes')
  int? get ventesRestantes;
  @override
  bool get illimite;

  /// Create a copy of QuotaInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QuotaInfoImplCopyWith<_$QuotaInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UpgradePlanRequest _$UpgradePlanRequestFromJson(Map<String, dynamic> json) {
  return _UpgradePlanRequest.fromJson(json);
}

/// @nodoc
mixin _$UpgradePlanRequest {
  String get plan => throw _privateConstructorUsedError;
  DateTime? get dateFin => throw _privateConstructorUsedError;

  /// Serializes this UpgradePlanRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UpgradePlanRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UpgradePlanRequestCopyWith<UpgradePlanRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpgradePlanRequestCopyWith<$Res> {
  factory $UpgradePlanRequestCopyWith(
          UpgradePlanRequest value, $Res Function(UpgradePlanRequest) then) =
      _$UpgradePlanRequestCopyWithImpl<$Res, UpgradePlanRequest>;
  @useResult
  $Res call({String plan, DateTime? dateFin});
}

/// @nodoc
class _$UpgradePlanRequestCopyWithImpl<$Res, $Val extends UpgradePlanRequest>
    implements $UpgradePlanRequestCopyWith<$Res> {
  _$UpgradePlanRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UpgradePlanRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? plan = null,
    Object? dateFin = freezed,
  }) {
    return _then(_value.copyWith(
      plan: null == plan
          ? _value.plan
          : plan // ignore: cast_nullable_to_non_nullable
              as String,
      dateFin: freezed == dateFin
          ? _value.dateFin
          : dateFin // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UpgradePlanRequestImplCopyWith<$Res>
    implements $UpgradePlanRequestCopyWith<$Res> {
  factory _$$UpgradePlanRequestImplCopyWith(_$UpgradePlanRequestImpl value,
          $Res Function(_$UpgradePlanRequestImpl) then) =
      __$$UpgradePlanRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String plan, DateTime? dateFin});
}

/// @nodoc
class __$$UpgradePlanRequestImplCopyWithImpl<$Res>
    extends _$UpgradePlanRequestCopyWithImpl<$Res, _$UpgradePlanRequestImpl>
    implements _$$UpgradePlanRequestImplCopyWith<$Res> {
  __$$UpgradePlanRequestImplCopyWithImpl(_$UpgradePlanRequestImpl _value,
      $Res Function(_$UpgradePlanRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of UpgradePlanRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? plan = null,
    Object? dateFin = freezed,
  }) {
    return _then(_$UpgradePlanRequestImpl(
      plan: null == plan
          ? _value.plan
          : plan // ignore: cast_nullable_to_non_nullable
              as String,
      dateFin: freezed == dateFin
          ? _value.dateFin
          : dateFin // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UpgradePlanRequestImpl implements _UpgradePlanRequest {
  const _$UpgradePlanRequestImpl({required this.plan, this.dateFin});

  factory _$UpgradePlanRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$UpgradePlanRequestImplFromJson(json);

  @override
  final String plan;
  @override
  final DateTime? dateFin;

  @override
  String toString() {
    return 'UpgradePlanRequest(plan: $plan, dateFin: $dateFin)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpgradePlanRequestImpl &&
            (identical(other.plan, plan) || other.plan == plan) &&
            (identical(other.dateFin, dateFin) || other.dateFin == dateFin));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, plan, dateFin);

  /// Create a copy of UpgradePlanRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpgradePlanRequestImplCopyWith<_$UpgradePlanRequestImpl> get copyWith =>
      __$$UpgradePlanRequestImplCopyWithImpl<_$UpgradePlanRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UpgradePlanRequestImplToJson(
      this,
    );
  }
}

abstract class _UpgradePlanRequest implements UpgradePlanRequest {
  const factory _UpgradePlanRequest(
      {required final String plan,
      final DateTime? dateFin}) = _$UpgradePlanRequestImpl;

  factory _UpgradePlanRequest.fromJson(Map<String, dynamic> json) =
      _$UpgradePlanRequestImpl.fromJson;

  @override
  String get plan;
  @override
  DateTime? get dateFin;

  /// Create a copy of UpgradePlanRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpgradePlanRequestImplCopyWith<_$UpgradePlanRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
