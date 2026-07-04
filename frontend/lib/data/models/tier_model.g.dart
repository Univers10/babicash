// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tier_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TierModelImpl _$$TierModelImplFromJson(Map<String, dynamic> json) =>
    _$TierModelImpl(
      id: json['id'] as String,
      boutiqueId: json['boutique_id'] as String,
      nom: json['nom'] as String,
      telephone: json['telephone'] as String?,
      typeTiers: json['type_tiers'] as String,
      soldeDu: (json['solde_du'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$$TierModelImplToJson(_$TierModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'boutique_id': instance.boutiqueId,
      'nom': instance.nom,
      'telephone': instance.telephone,
      'type_tiers': instance.typeTiers,
      'solde_du': instance.soldeDu,
    };

_$TierCreateRequestImpl _$$TierCreateRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$TierCreateRequestImpl(
      boutiqueId: json['boutique_id'] as String,
      nom: json['nom'] as String,
      telephone: json['telephone'] as String?,
      typeTiers: json['type_tiers'] as String,
    );

Map<String, dynamic> _$$TierCreateRequestImplToJson(
        _$TierCreateRequestImpl instance) =>
    <String, dynamic>{
      'boutique_id': instance.boutiqueId,
      'nom': instance.nom,
      'telephone': instance.telephone,
      'type_tiers': instance.typeTiers,
    };

_$TierUpdateRequestImpl _$$TierUpdateRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$TierUpdateRequestImpl(
      nom: json['nom'] as String?,
      telephone: json['telephone'] as String?,
    );

Map<String, dynamic> _$$TierUpdateRequestImplToJson(
        _$TierUpdateRequestImpl instance) =>
    <String, dynamic>{
      'nom': instance.nom,
      'telephone': instance.telephone,
    };

_$PaiementTierRequestImpl _$$PaiementTierRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$PaiementTierRequestImpl(
      montant: (json['montant'] as num).toDouble(),
      motif: json['motif'] as String?,
    );

Map<String, dynamic> _$$PaiementTierRequestImplToJson(
        _$PaiementTierRequestImpl instance) =>
    <String, dynamic>{
      'montant': instance.montant,
      'motif': instance.motif,
    };
