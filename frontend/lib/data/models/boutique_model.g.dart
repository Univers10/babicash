// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'boutique_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BoutiqueModelImpl _$$BoutiqueModelImplFromJson(Map<String, dynamic> json) =>
    _$BoutiqueModelImpl(
      id: json['id'] as String,
      nom: json['nom'] as String,
      proprietaireId: json['proprietaire_id'] as String,
      dateCreation: DateTime.parse(json['date_creation'] as String),
    );

Map<String, dynamic> _$$BoutiqueModelImplToJson(_$BoutiqueModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nom': instance.nom,
      'proprietaire_id': instance.proprietaireId,
      'date_creation': instance.dateCreation.toIso8601String(),
    };
