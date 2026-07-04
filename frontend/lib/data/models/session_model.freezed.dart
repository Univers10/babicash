// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SessionModel _$SessionModelFromJson(Map<String, dynamic> json) {
  return _SessionModel.fromJson(json);
}

/// @nodoc
mixin _$SessionModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'boutique_id')
  String get boutiqueId => throw _privateConstructorUsedError;
  @JsonKey(name: 'utilisateur_nom')
  String get utilisateurNom => throw _privateConstructorUsedError;
  @JsonKey(name: 'date_ouverture')
  DateTime get dateOuverture => throw _privateConstructorUsedError;
  @JsonKey(name: 'date_fermeture')
  DateTime? get dateFermeture => throw _privateConstructorUsedError;
  @JsonKey(name: 'montant_initial')
  double get montantInitial => throw _privateConstructorUsedError;
  @JsonKey(name: 'montant_final_declare')
  double? get montantFinalDeclare => throw _privateConstructorUsedError;
  String get statut => throw _privateConstructorUsedError;

  /// Serializes this SessionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SessionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SessionModelCopyWith<SessionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SessionModelCopyWith<$Res> {
  factory $SessionModelCopyWith(
          SessionModel value, $Res Function(SessionModel) then) =
      _$SessionModelCopyWithImpl<$Res, SessionModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'boutique_id') String boutiqueId,
      @JsonKey(name: 'utilisateur_nom') String utilisateurNom,
      @JsonKey(name: 'date_ouverture') DateTime dateOuverture,
      @JsonKey(name: 'date_fermeture') DateTime? dateFermeture,
      @JsonKey(name: 'montant_initial') double montantInitial,
      @JsonKey(name: 'montant_final_declare') double? montantFinalDeclare,
      String statut});
}

/// @nodoc
class _$SessionModelCopyWithImpl<$Res, $Val extends SessionModel>
    implements $SessionModelCopyWith<$Res> {
  _$SessionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SessionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? boutiqueId = null,
    Object? utilisateurNom = null,
    Object? dateOuverture = null,
    Object? dateFermeture = freezed,
    Object? montantInitial = null,
    Object? montantFinalDeclare = freezed,
    Object? statut = null,
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
      utilisateurNom: null == utilisateurNom
          ? _value.utilisateurNom
          : utilisateurNom // ignore: cast_nullable_to_non_nullable
              as String,
      dateOuverture: null == dateOuverture
          ? _value.dateOuverture
          : dateOuverture // ignore: cast_nullable_to_non_nullable
              as DateTime,
      dateFermeture: freezed == dateFermeture
          ? _value.dateFermeture
          : dateFermeture // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      montantInitial: null == montantInitial
          ? _value.montantInitial
          : montantInitial // ignore: cast_nullable_to_non_nullable
              as double,
      montantFinalDeclare: freezed == montantFinalDeclare
          ? _value.montantFinalDeclare
          : montantFinalDeclare // ignore: cast_nullable_to_non_nullable
              as double?,
      statut: null == statut
          ? _value.statut
          : statut // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SessionModelImplCopyWith<$Res>
    implements $SessionModelCopyWith<$Res> {
  factory _$$SessionModelImplCopyWith(
          _$SessionModelImpl value, $Res Function(_$SessionModelImpl) then) =
      __$$SessionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'boutique_id') String boutiqueId,
      @JsonKey(name: 'utilisateur_nom') String utilisateurNom,
      @JsonKey(name: 'date_ouverture') DateTime dateOuverture,
      @JsonKey(name: 'date_fermeture') DateTime? dateFermeture,
      @JsonKey(name: 'montant_initial') double montantInitial,
      @JsonKey(name: 'montant_final_declare') double? montantFinalDeclare,
      String statut});
}

/// @nodoc
class __$$SessionModelImplCopyWithImpl<$Res>
    extends _$SessionModelCopyWithImpl<$Res, _$SessionModelImpl>
    implements _$$SessionModelImplCopyWith<$Res> {
  __$$SessionModelImplCopyWithImpl(
      _$SessionModelImpl _value, $Res Function(_$SessionModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of SessionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? boutiqueId = null,
    Object? utilisateurNom = null,
    Object? dateOuverture = null,
    Object? dateFermeture = freezed,
    Object? montantInitial = null,
    Object? montantFinalDeclare = freezed,
    Object? statut = null,
  }) {
    return _then(_$SessionModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      boutiqueId: null == boutiqueId
          ? _value.boutiqueId
          : boutiqueId // ignore: cast_nullable_to_non_nullable
              as String,
      utilisateurNom: null == utilisateurNom
          ? _value.utilisateurNom
          : utilisateurNom // ignore: cast_nullable_to_non_nullable
              as String,
      dateOuverture: null == dateOuverture
          ? _value.dateOuverture
          : dateOuverture // ignore: cast_nullable_to_non_nullable
              as DateTime,
      dateFermeture: freezed == dateFermeture
          ? _value.dateFermeture
          : dateFermeture // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      montantInitial: null == montantInitial
          ? _value.montantInitial
          : montantInitial // ignore: cast_nullable_to_non_nullable
              as double,
      montantFinalDeclare: freezed == montantFinalDeclare
          ? _value.montantFinalDeclare
          : montantFinalDeclare // ignore: cast_nullable_to_non_nullable
              as double?,
      statut: null == statut
          ? _value.statut
          : statut // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SessionModelImpl implements _SessionModel {
  const _$SessionModelImpl(
      {required this.id,
      @JsonKey(name: 'boutique_id') required this.boutiqueId,
      @JsonKey(name: 'utilisateur_nom') required this.utilisateurNom,
      @JsonKey(name: 'date_ouverture') required this.dateOuverture,
      @JsonKey(name: 'date_fermeture') this.dateFermeture,
      @JsonKey(name: 'montant_initial') this.montantInitial = 0,
      @JsonKey(name: 'montant_final_declare') this.montantFinalDeclare,
      required this.statut});

  factory _$SessionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SessionModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'boutique_id')
  final String boutiqueId;
  @override
  @JsonKey(name: 'utilisateur_nom')
  final String utilisateurNom;
  @override
  @JsonKey(name: 'date_ouverture')
  final DateTime dateOuverture;
  @override
  @JsonKey(name: 'date_fermeture')
  final DateTime? dateFermeture;
  @override
  @JsonKey(name: 'montant_initial')
  final double montantInitial;
  @override
  @JsonKey(name: 'montant_final_declare')
  final double? montantFinalDeclare;
  @override
  final String statut;

  @override
  String toString() {
    return 'SessionModel(id: $id, boutiqueId: $boutiqueId, utilisateurNom: $utilisateurNom, dateOuverture: $dateOuverture, dateFermeture: $dateFermeture, montantInitial: $montantInitial, montantFinalDeclare: $montantFinalDeclare, statut: $statut)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SessionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.boutiqueId, boutiqueId) ||
                other.boutiqueId == boutiqueId) &&
            (identical(other.utilisateurNom, utilisateurNom) ||
                other.utilisateurNom == utilisateurNom) &&
            (identical(other.dateOuverture, dateOuverture) ||
                other.dateOuverture == dateOuverture) &&
            (identical(other.dateFermeture, dateFermeture) ||
                other.dateFermeture == dateFermeture) &&
            (identical(other.montantInitial, montantInitial) ||
                other.montantInitial == montantInitial) &&
            (identical(other.montantFinalDeclare, montantFinalDeclare) ||
                other.montantFinalDeclare == montantFinalDeclare) &&
            (identical(other.statut, statut) || other.statut == statut));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      boutiqueId,
      utilisateurNom,
      dateOuverture,
      dateFermeture,
      montantInitial,
      montantFinalDeclare,
      statut);

  /// Create a copy of SessionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SessionModelImplCopyWith<_$SessionModelImpl> get copyWith =>
      __$$SessionModelImplCopyWithImpl<_$SessionModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SessionModelImplToJson(
      this,
    );
  }
}

abstract class _SessionModel implements SessionModel {
  const factory _SessionModel(
      {required final String id,
      @JsonKey(name: 'boutique_id') required final String boutiqueId,
      @JsonKey(name: 'utilisateur_nom') required final String utilisateurNom,
      @JsonKey(name: 'date_ouverture') required final DateTime dateOuverture,
      @JsonKey(name: 'date_fermeture') final DateTime? dateFermeture,
      @JsonKey(name: 'montant_initial') final double montantInitial,
      @JsonKey(name: 'montant_final_declare') final double? montantFinalDeclare,
      required final String statut}) = _$SessionModelImpl;

  factory _SessionModel.fromJson(Map<String, dynamic> json) =
      _$SessionModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'boutique_id')
  String get boutiqueId;
  @override
  @JsonKey(name: 'utilisateur_nom')
  String get utilisateurNom;
  @override
  @JsonKey(name: 'date_ouverture')
  DateTime get dateOuverture;
  @override
  @JsonKey(name: 'date_fermeture')
  DateTime? get dateFermeture;
  @override
  @JsonKey(name: 'montant_initial')
  double get montantInitial;
  @override
  @JsonKey(name: 'montant_final_declare')
  double? get montantFinalDeclare;
  @override
  String get statut;

  /// Create a copy of SessionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SessionModelImplCopyWith<_$SessionModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SessionResumeModel _$SessionResumeModelFromJson(Map<String, dynamic> json) {
  return _SessionResumeModel.fromJson(json);
}

/// @nodoc
mixin _$SessionResumeModel {
  SessionModel get session => throw _privateConstructorUsedError;
  @JsonKey(name: 'nb_ventes')
  int get nbVentes => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_ventes_especes')
  double get totalVentesEspeces => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_ventes_autres')
  double get totalVentesAutres => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_entrees')
  double get totalEntrees => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_sorties')
  double get totalSorties => throw _privateConstructorUsedError;
  @JsonKey(name: 'montant_theorique')
  double get montantTheorique => throw _privateConstructorUsedError;
  double? get ecart => throw _privateConstructorUsedError;
  @JsonKey(name: 'ecart_signale')
  bool get ecartSignale => throw _privateConstructorUsedError;

  /// Serializes this SessionResumeModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SessionResumeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SessionResumeModelCopyWith<SessionResumeModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SessionResumeModelCopyWith<$Res> {
  factory $SessionResumeModelCopyWith(
          SessionResumeModel value, $Res Function(SessionResumeModel) then) =
      _$SessionResumeModelCopyWithImpl<$Res, SessionResumeModel>;
  @useResult
  $Res call(
      {SessionModel session,
      @JsonKey(name: 'nb_ventes') int nbVentes,
      @JsonKey(name: 'total_ventes_especes') double totalVentesEspeces,
      @JsonKey(name: 'total_ventes_autres') double totalVentesAutres,
      @JsonKey(name: 'total_entrees') double totalEntrees,
      @JsonKey(name: 'total_sorties') double totalSorties,
      @JsonKey(name: 'montant_theorique') double montantTheorique,
      double? ecart,
      @JsonKey(name: 'ecart_signale') bool ecartSignale});

  $SessionModelCopyWith<$Res> get session;
}

/// @nodoc
class _$SessionResumeModelCopyWithImpl<$Res, $Val extends SessionResumeModel>
    implements $SessionResumeModelCopyWith<$Res> {
  _$SessionResumeModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SessionResumeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? session = null,
    Object? nbVentes = null,
    Object? totalVentesEspeces = null,
    Object? totalVentesAutres = null,
    Object? totalEntrees = null,
    Object? totalSorties = null,
    Object? montantTheorique = null,
    Object? ecart = freezed,
    Object? ecartSignale = null,
  }) {
    return _then(_value.copyWith(
      session: null == session
          ? _value.session
          : session // ignore: cast_nullable_to_non_nullable
              as SessionModel,
      nbVentes: null == nbVentes
          ? _value.nbVentes
          : nbVentes // ignore: cast_nullable_to_non_nullable
              as int,
      totalVentesEspeces: null == totalVentesEspeces
          ? _value.totalVentesEspeces
          : totalVentesEspeces // ignore: cast_nullable_to_non_nullable
              as double,
      totalVentesAutres: null == totalVentesAutres
          ? _value.totalVentesAutres
          : totalVentesAutres // ignore: cast_nullable_to_non_nullable
              as double,
      totalEntrees: null == totalEntrees
          ? _value.totalEntrees
          : totalEntrees // ignore: cast_nullable_to_non_nullable
              as double,
      totalSorties: null == totalSorties
          ? _value.totalSorties
          : totalSorties // ignore: cast_nullable_to_non_nullable
              as double,
      montantTheorique: null == montantTheorique
          ? _value.montantTheorique
          : montantTheorique // ignore: cast_nullable_to_non_nullable
              as double,
      ecart: freezed == ecart
          ? _value.ecart
          : ecart // ignore: cast_nullable_to_non_nullable
              as double?,
      ecartSignale: null == ecartSignale
          ? _value.ecartSignale
          : ecartSignale // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  /// Create a copy of SessionResumeModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SessionModelCopyWith<$Res> get session {
    return $SessionModelCopyWith<$Res>(_value.session, (value) {
      return _then(_value.copyWith(session: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SessionResumeModelImplCopyWith<$Res>
    implements $SessionResumeModelCopyWith<$Res> {
  factory _$$SessionResumeModelImplCopyWith(_$SessionResumeModelImpl value,
          $Res Function(_$SessionResumeModelImpl) then) =
      __$$SessionResumeModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {SessionModel session,
      @JsonKey(name: 'nb_ventes') int nbVentes,
      @JsonKey(name: 'total_ventes_especes') double totalVentesEspeces,
      @JsonKey(name: 'total_ventes_autres') double totalVentesAutres,
      @JsonKey(name: 'total_entrees') double totalEntrees,
      @JsonKey(name: 'total_sorties') double totalSorties,
      @JsonKey(name: 'montant_theorique') double montantTheorique,
      double? ecart,
      @JsonKey(name: 'ecart_signale') bool ecartSignale});

  @override
  $SessionModelCopyWith<$Res> get session;
}

/// @nodoc
class __$$SessionResumeModelImplCopyWithImpl<$Res>
    extends _$SessionResumeModelCopyWithImpl<$Res, _$SessionResumeModelImpl>
    implements _$$SessionResumeModelImplCopyWith<$Res> {
  __$$SessionResumeModelImplCopyWithImpl(_$SessionResumeModelImpl _value,
      $Res Function(_$SessionResumeModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of SessionResumeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? session = null,
    Object? nbVentes = null,
    Object? totalVentesEspeces = null,
    Object? totalVentesAutres = null,
    Object? totalEntrees = null,
    Object? totalSorties = null,
    Object? montantTheorique = null,
    Object? ecart = freezed,
    Object? ecartSignale = null,
  }) {
    return _then(_$SessionResumeModelImpl(
      session: null == session
          ? _value.session
          : session // ignore: cast_nullable_to_non_nullable
              as SessionModel,
      nbVentes: null == nbVentes
          ? _value.nbVentes
          : nbVentes // ignore: cast_nullable_to_non_nullable
              as int,
      totalVentesEspeces: null == totalVentesEspeces
          ? _value.totalVentesEspeces
          : totalVentesEspeces // ignore: cast_nullable_to_non_nullable
              as double,
      totalVentesAutres: null == totalVentesAutres
          ? _value.totalVentesAutres
          : totalVentesAutres // ignore: cast_nullable_to_non_nullable
              as double,
      totalEntrees: null == totalEntrees
          ? _value.totalEntrees
          : totalEntrees // ignore: cast_nullable_to_non_nullable
              as double,
      totalSorties: null == totalSorties
          ? _value.totalSorties
          : totalSorties // ignore: cast_nullable_to_non_nullable
              as double,
      montantTheorique: null == montantTheorique
          ? _value.montantTheorique
          : montantTheorique // ignore: cast_nullable_to_non_nullable
              as double,
      ecart: freezed == ecart
          ? _value.ecart
          : ecart // ignore: cast_nullable_to_non_nullable
              as double?,
      ecartSignale: null == ecartSignale
          ? _value.ecartSignale
          : ecartSignale // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SessionResumeModelImpl implements _SessionResumeModel {
  const _$SessionResumeModelImpl(
      {required this.session,
      @JsonKey(name: 'nb_ventes') this.nbVentes = 0,
      @JsonKey(name: 'total_ventes_especes') this.totalVentesEspeces = 0,
      @JsonKey(name: 'total_ventes_autres') this.totalVentesAutres = 0,
      @JsonKey(name: 'total_entrees') this.totalEntrees = 0,
      @JsonKey(name: 'total_sorties') this.totalSorties = 0,
      @JsonKey(name: 'montant_theorique') this.montantTheorique = 0,
      this.ecart,
      @JsonKey(name: 'ecart_signale') this.ecartSignale = false});

  factory _$SessionResumeModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SessionResumeModelImplFromJson(json);

  @override
  final SessionModel session;
  @override
  @JsonKey(name: 'nb_ventes')
  final int nbVentes;
  @override
  @JsonKey(name: 'total_ventes_especes')
  final double totalVentesEspeces;
  @override
  @JsonKey(name: 'total_ventes_autres')
  final double totalVentesAutres;
  @override
  @JsonKey(name: 'total_entrees')
  final double totalEntrees;
  @override
  @JsonKey(name: 'total_sorties')
  final double totalSorties;
  @override
  @JsonKey(name: 'montant_theorique')
  final double montantTheorique;
  @override
  final double? ecart;
  @override
  @JsonKey(name: 'ecart_signale')
  final bool ecartSignale;

  @override
  String toString() {
    return 'SessionResumeModel(session: $session, nbVentes: $nbVentes, totalVentesEspeces: $totalVentesEspeces, totalVentesAutres: $totalVentesAutres, totalEntrees: $totalEntrees, totalSorties: $totalSorties, montantTheorique: $montantTheorique, ecart: $ecart, ecartSignale: $ecartSignale)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SessionResumeModelImpl &&
            (identical(other.session, session) || other.session == session) &&
            (identical(other.nbVentes, nbVentes) ||
                other.nbVentes == nbVentes) &&
            (identical(other.totalVentesEspeces, totalVentesEspeces) ||
                other.totalVentesEspeces == totalVentesEspeces) &&
            (identical(other.totalVentesAutres, totalVentesAutres) ||
                other.totalVentesAutres == totalVentesAutres) &&
            (identical(other.totalEntrees, totalEntrees) ||
                other.totalEntrees == totalEntrees) &&
            (identical(other.totalSorties, totalSorties) ||
                other.totalSorties == totalSorties) &&
            (identical(other.montantTheorique, montantTheorique) ||
                other.montantTheorique == montantTheorique) &&
            (identical(other.ecart, ecart) || other.ecart == ecart) &&
            (identical(other.ecartSignale, ecartSignale) ||
                other.ecartSignale == ecartSignale));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      session,
      nbVentes,
      totalVentesEspeces,
      totalVentesAutres,
      totalEntrees,
      totalSorties,
      montantTheorique,
      ecart,
      ecartSignale);

  /// Create a copy of SessionResumeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SessionResumeModelImplCopyWith<_$SessionResumeModelImpl> get copyWith =>
      __$$SessionResumeModelImplCopyWithImpl<_$SessionResumeModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SessionResumeModelImplToJson(
      this,
    );
  }
}

abstract class _SessionResumeModel implements SessionResumeModel {
  const factory _SessionResumeModel(
      {required final SessionModel session,
      @JsonKey(name: 'nb_ventes') final int nbVentes,
      @JsonKey(name: 'total_ventes_especes') final double totalVentesEspeces,
      @JsonKey(name: 'total_ventes_autres') final double totalVentesAutres,
      @JsonKey(name: 'total_entrees') final double totalEntrees,
      @JsonKey(name: 'total_sorties') final double totalSorties,
      @JsonKey(name: 'montant_theorique') final double montantTheorique,
      final double? ecart,
      @JsonKey(name: 'ecart_signale')
      final bool ecartSignale}) = _$SessionResumeModelImpl;

  factory _SessionResumeModel.fromJson(Map<String, dynamic> json) =
      _$SessionResumeModelImpl.fromJson;

  @override
  SessionModel get session;
  @override
  @JsonKey(name: 'nb_ventes')
  int get nbVentes;
  @override
  @JsonKey(name: 'total_ventes_especes')
  double get totalVentesEspeces;
  @override
  @JsonKey(name: 'total_ventes_autres')
  double get totalVentesAutres;
  @override
  @JsonKey(name: 'total_entrees')
  double get totalEntrees;
  @override
  @JsonKey(name: 'total_sorties')
  double get totalSorties;
  @override
  @JsonKey(name: 'montant_theorique')
  double get montantTheorique;
  @override
  double? get ecart;
  @override
  @JsonKey(name: 'ecart_signale')
  bool get ecartSignale;

  /// Create a copy of SessionResumeModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SessionResumeModelImplCopyWith<_$SessionResumeModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SessionOuvrirRequest _$SessionOuvrirRequestFromJson(Map<String, dynamic> json) {
  return _SessionOuvrirRequest.fromJson(json);
}

/// @nodoc
mixin _$SessionOuvrirRequest {
  @JsonKey(name: 'boutique_id')
  String get boutiqueId => throw _privateConstructorUsedError;
  @JsonKey(name: 'montant_initial')
  double get montantInitial => throw _privateConstructorUsedError;

  /// Serializes this SessionOuvrirRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SessionOuvrirRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SessionOuvrirRequestCopyWith<SessionOuvrirRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SessionOuvrirRequestCopyWith<$Res> {
  factory $SessionOuvrirRequestCopyWith(SessionOuvrirRequest value,
          $Res Function(SessionOuvrirRequest) then) =
      _$SessionOuvrirRequestCopyWithImpl<$Res, SessionOuvrirRequest>;
  @useResult
  $Res call(
      {@JsonKey(name: 'boutique_id') String boutiqueId,
      @JsonKey(name: 'montant_initial') double montantInitial});
}

/// @nodoc
class _$SessionOuvrirRequestCopyWithImpl<$Res,
        $Val extends SessionOuvrirRequest>
    implements $SessionOuvrirRequestCopyWith<$Res> {
  _$SessionOuvrirRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SessionOuvrirRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? boutiqueId = null,
    Object? montantInitial = null,
  }) {
    return _then(_value.copyWith(
      boutiqueId: null == boutiqueId
          ? _value.boutiqueId
          : boutiqueId // ignore: cast_nullable_to_non_nullable
              as String,
      montantInitial: null == montantInitial
          ? _value.montantInitial
          : montantInitial // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SessionOuvrirRequestImplCopyWith<$Res>
    implements $SessionOuvrirRequestCopyWith<$Res> {
  factory _$$SessionOuvrirRequestImplCopyWith(_$SessionOuvrirRequestImpl value,
          $Res Function(_$SessionOuvrirRequestImpl) then) =
      __$$SessionOuvrirRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'boutique_id') String boutiqueId,
      @JsonKey(name: 'montant_initial') double montantInitial});
}

/// @nodoc
class __$$SessionOuvrirRequestImplCopyWithImpl<$Res>
    extends _$SessionOuvrirRequestCopyWithImpl<$Res, _$SessionOuvrirRequestImpl>
    implements _$$SessionOuvrirRequestImplCopyWith<$Res> {
  __$$SessionOuvrirRequestImplCopyWithImpl(_$SessionOuvrirRequestImpl _value,
      $Res Function(_$SessionOuvrirRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of SessionOuvrirRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? boutiqueId = null,
    Object? montantInitial = null,
  }) {
    return _then(_$SessionOuvrirRequestImpl(
      boutiqueId: null == boutiqueId
          ? _value.boutiqueId
          : boutiqueId // ignore: cast_nullable_to_non_nullable
              as String,
      montantInitial: null == montantInitial
          ? _value.montantInitial
          : montantInitial // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SessionOuvrirRequestImpl implements _SessionOuvrirRequest {
  const _$SessionOuvrirRequestImpl(
      {@JsonKey(name: 'boutique_id') required this.boutiqueId,
      @JsonKey(name: 'montant_initial') this.montantInitial = 0});

  factory _$SessionOuvrirRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$SessionOuvrirRequestImplFromJson(json);

  @override
  @JsonKey(name: 'boutique_id')
  final String boutiqueId;
  @override
  @JsonKey(name: 'montant_initial')
  final double montantInitial;

  @override
  String toString() {
    return 'SessionOuvrirRequest(boutiqueId: $boutiqueId, montantInitial: $montantInitial)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SessionOuvrirRequestImpl &&
            (identical(other.boutiqueId, boutiqueId) ||
                other.boutiqueId == boutiqueId) &&
            (identical(other.montantInitial, montantInitial) ||
                other.montantInitial == montantInitial));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, boutiqueId, montantInitial);

  /// Create a copy of SessionOuvrirRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SessionOuvrirRequestImplCopyWith<_$SessionOuvrirRequestImpl>
      get copyWith =>
          __$$SessionOuvrirRequestImplCopyWithImpl<_$SessionOuvrirRequestImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SessionOuvrirRequestImplToJson(
      this,
    );
  }
}

abstract class _SessionOuvrirRequest implements SessionOuvrirRequest {
  const factory _SessionOuvrirRequest(
          {@JsonKey(name: 'boutique_id') required final String boutiqueId,
          @JsonKey(name: 'montant_initial') final double montantInitial}) =
      _$SessionOuvrirRequestImpl;

  factory _SessionOuvrirRequest.fromJson(Map<String, dynamic> json) =
      _$SessionOuvrirRequestImpl.fromJson;

  @override
  @JsonKey(name: 'boutique_id')
  String get boutiqueId;
  @override
  @JsonKey(name: 'montant_initial')
  double get montantInitial;

  /// Create a copy of SessionOuvrirRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SessionOuvrirRequestImplCopyWith<_$SessionOuvrirRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}

SessionFermerRequest _$SessionFermerRequestFromJson(Map<String, dynamic> json) {
  return _SessionFermerRequest.fromJson(json);
}

/// @nodoc
mixin _$SessionFermerRequest {
  @JsonKey(name: 'montant_final_declare')
  double get montantFinalDeclare => throw _privateConstructorUsedError;

  /// Serializes this SessionFermerRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SessionFermerRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SessionFermerRequestCopyWith<SessionFermerRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SessionFermerRequestCopyWith<$Res> {
  factory $SessionFermerRequestCopyWith(SessionFermerRequest value,
          $Res Function(SessionFermerRequest) then) =
      _$SessionFermerRequestCopyWithImpl<$Res, SessionFermerRequest>;
  @useResult
  $Res call(
      {@JsonKey(name: 'montant_final_declare') double montantFinalDeclare});
}

/// @nodoc
class _$SessionFermerRequestCopyWithImpl<$Res,
        $Val extends SessionFermerRequest>
    implements $SessionFermerRequestCopyWith<$Res> {
  _$SessionFermerRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SessionFermerRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? montantFinalDeclare = null,
  }) {
    return _then(_value.copyWith(
      montantFinalDeclare: null == montantFinalDeclare
          ? _value.montantFinalDeclare
          : montantFinalDeclare // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SessionFermerRequestImplCopyWith<$Res>
    implements $SessionFermerRequestCopyWith<$Res> {
  factory _$$SessionFermerRequestImplCopyWith(_$SessionFermerRequestImpl value,
          $Res Function(_$SessionFermerRequestImpl) then) =
      __$$SessionFermerRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'montant_final_declare') double montantFinalDeclare});
}

/// @nodoc
class __$$SessionFermerRequestImplCopyWithImpl<$Res>
    extends _$SessionFermerRequestCopyWithImpl<$Res, _$SessionFermerRequestImpl>
    implements _$$SessionFermerRequestImplCopyWith<$Res> {
  __$$SessionFermerRequestImplCopyWithImpl(_$SessionFermerRequestImpl _value,
      $Res Function(_$SessionFermerRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of SessionFermerRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? montantFinalDeclare = null,
  }) {
    return _then(_$SessionFermerRequestImpl(
      montantFinalDeclare: null == montantFinalDeclare
          ? _value.montantFinalDeclare
          : montantFinalDeclare // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SessionFermerRequestImpl implements _SessionFermerRequest {
  const _$SessionFermerRequestImpl(
      {@JsonKey(name: 'montant_final_declare')
      required this.montantFinalDeclare});

  factory _$SessionFermerRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$SessionFermerRequestImplFromJson(json);

  @override
  @JsonKey(name: 'montant_final_declare')
  final double montantFinalDeclare;

  @override
  String toString() {
    return 'SessionFermerRequest(montantFinalDeclare: $montantFinalDeclare)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SessionFermerRequestImpl &&
            (identical(other.montantFinalDeclare, montantFinalDeclare) ||
                other.montantFinalDeclare == montantFinalDeclare));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, montantFinalDeclare);

  /// Create a copy of SessionFermerRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SessionFermerRequestImplCopyWith<_$SessionFermerRequestImpl>
      get copyWith =>
          __$$SessionFermerRequestImplCopyWithImpl<_$SessionFermerRequestImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SessionFermerRequestImplToJson(
      this,
    );
  }
}

abstract class _SessionFermerRequest implements SessionFermerRequest {
  const factory _SessionFermerRequest(
      {@JsonKey(name: 'montant_final_declare')
      required final double montantFinalDeclare}) = _$SessionFermerRequestImpl;

  factory _SessionFermerRequest.fromJson(Map<String, dynamic> json) =
      _$SessionFermerRequestImpl.fromJson;

  @override
  @JsonKey(name: 'montant_final_declare')
  double get montantFinalDeclare;

  /// Create a copy of SessionFermerRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SessionFermerRequestImplCopyWith<_$SessionFermerRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}
