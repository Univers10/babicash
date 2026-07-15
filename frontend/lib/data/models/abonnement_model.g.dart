// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'abonnement_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AbonnementOutImpl _$$AbonnementOutImplFromJson(Map<String, dynamic> json) =>
    _$AbonnementOutImpl(
      proprietaireId: json['proprietaire_id'] as String,
      plan: json['plan'] as String,
      quotaVentesParBoutique:
          (json['quota_ventes_par_boutique'] as num).toInt(),
      prixBase:
          json['prix_base'] == null ? 5000 : parseDouble(json['prix_base']),
      nbBoutiques: (json['nb_boutiques'] as num?)?.toInt() ?? 1,
      prixTotalMensuel: json['prix_total_mensuel'] == null
          ? 5000
          : parseDouble(json['prix_total_mensuel']),
      dateFin: json['date_fin'] == null
          ? null
          : DateTime.parse(json['date_fin'] as String),
      actif: json['actif'] as bool? ?? true,
    );

Map<String, dynamic> _$$AbonnementOutImplToJson(_$AbonnementOutImpl instance) =>
    <String, dynamic>{
      'proprietaire_id': instance.proprietaireId,
      'plan': instance.plan,
      'quota_ventes_par_boutique': instance.quotaVentesParBoutique,
      'prix_base': instance.prixBase,
      'nb_boutiques': instance.nbBoutiques,
      'prix_total_mensuel': instance.prixTotalMensuel,
      'date_fin': instance.dateFin?.toIso8601String(),
      'actif': instance.actif,
    };

_$QuotaInfoImpl _$$QuotaInfoImplFromJson(Map<String, dynamic> json) =>
    _$QuotaInfoImpl(
      boutiqueId: json['boutique_id'] as String,
      plan: json['plan'] as String,
      quotaParBoutique: (json['quota_par_boutique'] as num).toInt(),
      ventesCeMois: (json['ventes_ce_mois'] as num?)?.toInt() ?? 0,
      ventesRestantes: (json['ventes_restantes'] as num?)?.toInt(),
      illimite: json['illimite'] as bool? ?? false,
    );

Map<String, dynamic> _$$QuotaInfoImplToJson(_$QuotaInfoImpl instance) =>
    <String, dynamic>{
      'boutique_id': instance.boutiqueId,
      'plan': instance.plan,
      'quota_par_boutique': instance.quotaParBoutique,
      'ventes_ce_mois': instance.ventesCeMois,
      'ventes_restantes': instance.ventesRestantes,
      'illimite': instance.illimite,
    };

_$UpgradePlanRequestImpl _$$UpgradePlanRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$UpgradePlanRequestImpl(
      plan: json['plan'] as String,
      dateFin: json['date_fin'] == null
          ? null
          : DateTime.parse(json['date_fin'] as String),
    );

Map<String, dynamic> _$$UpgradePlanRequestImplToJson(
        _$UpgradePlanRequestImpl instance) =>
    <String, dynamic>{
      'plan': instance.plan,
      'date_fin': instance.dateFin?.toIso8601String(),
    };
