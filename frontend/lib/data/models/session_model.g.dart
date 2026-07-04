// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SessionModelImpl _$$SessionModelImplFromJson(Map<String, dynamic> json) =>
    _$SessionModelImpl(
      id: json['id'] as String,
      boutiqueId: json['boutique_id'] as String,
      utilisateurNom: json['utilisateur_nom'] as String,
      dateOuverture: DateTime.parse(json['date_ouverture'] as String),
      dateFermeture: json['date_fermeture'] == null
          ? null
          : DateTime.parse(json['date_fermeture'] as String),
      montantInitial: (json['montant_initial'] as num?)?.toDouble() ?? 0,
      montantFinalDeclare: (json['montant_final_declare'] as num?)?.toDouble(),
      statut: json['statut'] as String,
    );

Map<String, dynamic> _$$SessionModelImplToJson(_$SessionModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'boutique_id': instance.boutiqueId,
      'utilisateur_nom': instance.utilisateurNom,
      'date_ouverture': instance.dateOuverture.toIso8601String(),
      'date_fermeture': instance.dateFermeture?.toIso8601String(),
      'montant_initial': instance.montantInitial,
      'montant_final_declare': instance.montantFinalDeclare,
      'statut': instance.statut,
    };

_$SessionResumeModelImpl _$$SessionResumeModelImplFromJson(
        Map<String, dynamic> json) =>
    _$SessionResumeModelImpl(
      session: SessionModel.fromJson(json['session'] as Map<String, dynamic>),
      nbVentes: (json['nb_ventes'] as num?)?.toInt() ?? 0,
      totalVentesEspeces:
          (json['total_ventes_especes'] as num?)?.toDouble() ?? 0,
      totalVentesAutres: (json['total_ventes_autres'] as num?)?.toDouble() ?? 0,
      totalEntrees: (json['total_entrees'] as num?)?.toDouble() ?? 0,
      totalSorties: (json['total_sorties'] as num?)?.toDouble() ?? 0,
      montantTheorique: (json['montant_theorique'] as num?)?.toDouble() ?? 0,
      ecart: (json['ecart'] as num?)?.toDouble(),
      ecartSignale: json['ecart_signale'] as bool? ?? false,
    );

Map<String, dynamic> _$$SessionResumeModelImplToJson(
        _$SessionResumeModelImpl instance) =>
    <String, dynamic>{
      'session': instance.session.toJson(),
      'nb_ventes': instance.nbVentes,
      'total_ventes_especes': instance.totalVentesEspeces,
      'total_ventes_autres': instance.totalVentesAutres,
      'total_entrees': instance.totalEntrees,
      'total_sorties': instance.totalSorties,
      'montant_theorique': instance.montantTheorique,
      'ecart': instance.ecart,
      'ecart_signale': instance.ecartSignale,
    };

_$SessionOuvrirRequestImpl _$$SessionOuvrirRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$SessionOuvrirRequestImpl(
      boutiqueId: json['boutique_id'] as String,
      montantInitial: (json['montant_initial'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$$SessionOuvrirRequestImplToJson(
        _$SessionOuvrirRequestImpl instance) =>
    <String, dynamic>{
      'boutique_id': instance.boutiqueId,
      'montant_initial': instance.montantInitial,
    };

_$SessionFermerRequestImpl _$$SessionFermerRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$SessionFermerRequestImpl(
      montantFinalDeclare: (json['montant_final_declare'] as num).toDouble(),
    );

Map<String, dynamic> _$$SessionFermerRequestImplToJson(
        _$SessionFermerRequestImpl instance) =>
    <String, dynamic>{
      'montant_final_declare': instance.montantFinalDeclare,
    };
