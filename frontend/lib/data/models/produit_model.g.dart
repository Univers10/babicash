// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'produit_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProduitModelImpl _$$ProduitModelImplFromJson(Map<String, dynamic> json) =>
    _$ProduitModelImpl(
      id: json['id'] as String,
      boutiqueId: json['boutique_id'] as String,
      categorieId: json['categorie_id'] as String?,
      nom: json['nom'] as String,
      prixAchatMoyen: parseDouble(json['prix_achat_moyen']),
      prixVenteSuggere: parseDouble(json['prix_vente_suggere']),
      stockActuel: (json['stock_actuel'] as num).toInt(),
      stockAlerte: (json['stock_alerte'] as num).toInt(),
      imageUrl: json['image_url'] as String?,
    );

Map<String, dynamic> _$$ProduitModelImplToJson(_$ProduitModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'boutique_id': instance.boutiqueId,
      'categorie_id': instance.categorieId,
      'nom': instance.nom,
      'prix_achat_moyen': instance.prixAchatMoyen,
      'prix_vente_suggere': instance.prixVenteSuggere,
      'stock_actuel': instance.stockActuel,
      'stock_alerte': instance.stockAlerte,
      'image_url': instance.imageUrl,
    };

_$CategorieModelImpl _$$CategorieModelImplFromJson(Map<String, dynamic> json) =>
    _$CategorieModelImpl(
      id: json['id'] as String,
      boutiqueId: json['boutique_id'] as String,
      nom: json['nom'] as String,
    );

Map<String, dynamic> _$$CategorieModelImplToJson(
        _$CategorieModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'boutique_id': instance.boutiqueId,
      'nom': instance.nom,
    };

_$ProduitCreateRequestImpl _$$ProduitCreateRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$ProduitCreateRequestImpl(
      boutiqueId: json['boutique_id'] as String,
      categorieId: json['categorie_id'] as String?,
      nom: json['nom'] as String,
      prixAchatMoyen: (json['prix_achat_moyen'] as num).toDouble(),
      prixVenteSuggere: (json['prix_vente_suggere'] as num).toDouble(),
      stockActuel: (json['stock_actuel'] as num).toInt(),
      stockAlerte: (json['stock_alerte'] as num).toInt(),
      imageUrl: json['image_url'] as String?,
    );

Map<String, dynamic> _$$ProduitCreateRequestImplToJson(
        _$ProduitCreateRequestImpl instance) =>
    <String, dynamic>{
      'boutique_id': instance.boutiqueId,
      'categorie_id': instance.categorieId,
      'nom': instance.nom,
      'prix_achat_moyen': instance.prixAchatMoyen,
      'prix_vente_suggere': instance.prixVenteSuggere,
      'stock_actuel': instance.stockActuel,
      'stock_alerte': instance.stockAlerte,
      if (instance.imageUrl case final value?) 'image_url': value,
    };

_$ProduitUpdateRequestImpl _$$ProduitUpdateRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$ProduitUpdateRequestImpl(
      categorieId: json['categorie_id'] as String?,
      nom: json['nom'] as String?,
      prixAchatMoyen: (json['prix_achat_moyen'] as num?)?.toDouble(),
      prixVenteSuggere: (json['prix_vente_suggere'] as num?)?.toDouble(),
      stockActuel: (json['stock_actuel'] as num?)?.toInt(),
      stockAlerte: (json['stock_alerte'] as num?)?.toInt(),
      imageUrl: json['image_url'] as String?,
    );

Map<String, dynamic> _$$ProduitUpdateRequestImplToJson(
        _$ProduitUpdateRequestImpl instance) =>
    <String, dynamic>{
      'categorie_id': instance.categorieId,
      'nom': instance.nom,
      'prix_achat_moyen': instance.prixAchatMoyen,
      'prix_vente_suggere': instance.prixVenteSuggere,
      'stock_actuel': instance.stockActuel,
      'stock_alerte': instance.stockAlerte,
      'image_url': instance.imageUrl,
    };

_$CategorieCreateRequestImpl _$$CategorieCreateRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$CategorieCreateRequestImpl(
      boutiqueId: json['boutique_id'] as String,
      nom: json['nom'] as String,
    );

Map<String, dynamic> _$$CategorieCreateRequestImplToJson(
        _$CategorieCreateRequestImpl instance) =>
    <String, dynamic>{
      'boutique_id': instance.boutiqueId,
      'nom': instance.nom,
    };

_$CategorieUpdateRequestImpl _$$CategorieUpdateRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$CategorieUpdateRequestImpl(
      nom: json['nom'] as String?,
    );

Map<String, dynamic> _$$CategorieUpdateRequestImplToJson(
        _$CategorieUpdateRequestImpl instance) =>
    <String, dynamic>{
      'nom': instance.nom,
    };
