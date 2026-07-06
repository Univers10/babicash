// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LigneVenteInImpl _$$LigneVenteInImplFromJson(Map<String, dynamic> json) =>
    _$LigneVenteInImpl(
      produitId: json['produit_id'] as String?,
      quantite: (json['quantite'] as num?)?.toInt() ?? 1,
      prixVenduReel: (json['prix_vendu_reel'] as num).toDouble(),
    );

Map<String, dynamic> _$$LigneVenteInImplToJson(_$LigneVenteInImpl instance) =>
    <String, dynamic>{
      'produit_id': instance.produitId,
      'quantite': instance.quantite,
      'prix_vendu_reel': instance.prixVenduReel,
    };

_$VenteInImpl _$$VenteInImplFromJson(Map<String, dynamic> json) =>
    _$VenteInImpl(
      idLocal: json['id_local_smartphone'] as String,
      sessionId: json['session_id'] as String?,
      tierId: json['tier_id'] as String?,
      dateVente: json['date_vente'] == null
          ? null
          : DateTime.parse(json['date_vente'] as String),
      modePaiement: json['mode_paiement'] as String,
      lignes: (json['lignes'] as List<dynamic>)
          .map((e) => LigneVenteIn.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$VenteInImplToJson(_$VenteInImpl instance) =>
    <String, dynamic>{
      'id_local_smartphone': instance.idLocal,
      'session_id': instance.sessionId,
      'tier_id': instance.tierId,
      'date_vente': instance.dateVente?.toIso8601String(),
      'mode_paiement': instance.modePaiement,
      'lignes': instance.lignes.map((e) => e.toJson()).toList(),
    };

_$DepenseInImpl _$$DepenseInImplFromJson(Map<String, dynamic> json) =>
    _$DepenseInImpl(
      idLocal: json['id_local_smartphone'] as String,
      sessionId: json['session_id'] as String?,
      typeTransaction: json['type_transaction'] as String? ?? 'SORTIE_DEPENSE',
      montant: (json['montant'] as num).toDouble(),
      motif: json['motif'] as String,
      dateTransaction: json['date_transaction'] == null
          ? null
          : DateTime.parse(json['date_transaction'] as String),
    );

Map<String, dynamic> _$$DepenseInImplToJson(_$DepenseInImpl instance) =>
    <String, dynamic>{
      'id_local_smartphone': instance.idLocal,
      'session_id': instance.sessionId,
      'type_transaction': instance.typeTransaction,
      'montant': instance.montant,
      'motif': instance.motif,
      'date_transaction': instance.dateTransaction?.toIso8601String(),
    };

_$SyncPushRequestImpl _$$SyncPushRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$SyncPushRequestImpl(
      boutiqueId: json['boutique_id'] as String,
      ventes: (json['ventes'] as List<dynamic>?)
              ?.map((e) => VenteIn.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      depenses: (json['depenses'] as List<dynamic>?)
              ?.map((e) => DepenseIn.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      entreesStock: json['entrees_stock'] as List<dynamic>? ?? const [],
    );

Map<String, dynamic> _$$SyncPushRequestImplToJson(
        _$SyncPushRequestImpl instance) =>
    <String, dynamic>{
      'boutique_id': instance.boutiqueId,
      'ventes': instance.ventes.map((e) => e.toJson()).toList(),
      'depenses': instance.depenses.map((e) => e.toJson()).toList(),
      'entrees_stock': instance.entreesStock,
    };

_$RecuLigneImpl _$$RecuLigneImplFromJson(Map<String, dynamic> json) =>
    _$RecuLigneImpl(
      nom: json['nom'] as String,
      quantite: (json['quantite'] as num).toInt(),
      prixUnitaire: parseDouble(json['prix_unitaire']),
      totalLigne: parseDouble(json['total_ligne']),
    );

Map<String, dynamic> _$$RecuLigneImplToJson(_$RecuLigneImpl instance) =>
    <String, dynamic>{
      'nom': instance.nom,
      'quantite': instance.quantite,
      'prix_unitaire': instance.prixUnitaire,
      'total_ligne': instance.totalLigne,
    };

_$RecuOutImpl _$$RecuOutImplFromJson(Map<String, dynamic> json) =>
    _$RecuOutImpl(
      venteId: json['vente_id'] as String,
      numero: json['numero'] as String,
      boutiqueNom: json['boutique_nom'] as String,
      dateVente: DateTime.parse(json['date_vente'] as String),
      modePaiement: json['mode_paiement'] as String,
      lignes: (json['lignes'] as List<dynamic>)
          .map((e) => RecuLigne.fromJson(e as Map<String, dynamic>))
          .toList(),
      montantTotal: parseDouble(json['montant_total']),
      clientNom: json['client_nom'] as String?,
    );

Map<String, dynamic> _$$RecuOutImplToJson(_$RecuOutImpl instance) =>
    <String, dynamic>{
      'vente_id': instance.venteId,
      'numero': instance.numero,
      'boutique_nom': instance.boutiqueNom,
      'date_vente': instance.dateVente.toIso8601String(),
      'mode_paiement': instance.modePaiement,
      'lignes': instance.lignes.map((e) => e.toJson()).toList(),
      'montant_total': instance.montantTotal,
      'client_nom': instance.clientNom,
    };

_$VentePushResultImpl _$$VentePushResultImplFromJson(
        Map<String, dynamic> json) =>
    _$VentePushResultImpl(
      idLocal: json['id_local_smartphone'] as String,
      venteId: json['vente_id'] as String,
      dejaSynchronisee: json['deja_synchronisee'] as bool? ?? false,
      signaleProprietaire: json['signale_proprietaire'] as bool? ?? false,
      avertissement: json['avertissement'] as String?,
      recu: json['recu'] == null
          ? null
          : RecuOut.fromJson(json['recu'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$VentePushResultImplToJson(
        _$VentePushResultImpl instance) =>
    <String, dynamic>{
      'id_local_smartphone': instance.idLocal,
      'vente_id': instance.venteId,
      'deja_synchronisee': instance.dejaSynchronisee,
      'signale_proprietaire': instance.signaleProprietaire,
      'avertissement': instance.avertissement,
      'recu': instance.recu?.toJson(),
    };

_$AlerteStockItemImpl _$$AlerteStockItemImplFromJson(
        Map<String, dynamic> json) =>
    _$AlerteStockItemImpl(
      produitId: json['produit_id'] as String,
      nom: json['nom'] as String,
      stockActuel: (json['stock_actuel'] as num).toInt(),
      stockAlerte: (json['stock_alerte'] as num).toInt(),
      enRupture: json['en_rupture'] as bool,
    );

Map<String, dynamic> _$$AlerteStockItemImplToJson(
        _$AlerteStockItemImpl instance) =>
    <String, dynamic>{
      'produit_id': instance.produitId,
      'nom': instance.nom,
      'stock_actuel': instance.stockActuel,
      'stock_alerte': instance.stockAlerte,
      'en_rupture': instance.enRupture,
    };

_$SyncPushResponseImpl _$$SyncPushResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$SyncPushResponseImpl(
      ventes: (json['ventes'] as List<dynamic>?)
              ?.map((e) => VentePushResult.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      depenses: json['depenses'] as List<dynamic>? ?? const [],
      alertesStock: (json['alertes_stock'] as List<dynamic>?)
              ?.map((e) => AlerteStockItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$SyncPushResponseImplToJson(
        _$SyncPushResponseImpl instance) =>
    <String, dynamic>{
      'ventes': instance.ventes.map((e) => e.toJson()).toList(),
      'depenses': instance.depenses,
      'alertes_stock': instance.alertesStock.map((e) => e.toJson()).toList(),
    };

_$SyncPullResponseImpl _$$SyncPullResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$SyncPullResponseImpl(
      boutiqueId: json['boutique_id'] as String,
      produits: (json['produits'] as List<dynamic>)
          .map((e) => ProduitModelLite.fromJson(e as Map<String, dynamic>))
          .toList(),
      categories: (json['categories'] as List<dynamic>)
          .map((e) => CategorieModelLite.fromJson(e as Map<String, dynamic>))
          .toList(),
      serverTime: DateTime.parse(json['server_time'] as String),
    );

Map<String, dynamic> _$$SyncPullResponseImplToJson(
        _$SyncPullResponseImpl instance) =>
    <String, dynamic>{
      'boutique_id': instance.boutiqueId,
      'produits': instance.produits.map((e) => e.toJson()).toList(),
      'categories': instance.categories.map((e) => e.toJson()).toList(),
      'server_time': instance.serverTime.toIso8601String(),
    };

_$ProduitModelLiteImpl _$$ProduitModelLiteImplFromJson(
        Map<String, dynamic> json) =>
    _$ProduitModelLiteImpl(
      id: json['id'] as String,
      nom: json['nom'] as String,
      prixAchatMoyen: parseDouble(json['prix_achat_moyen']),
      prixVenteSuggere: parseDouble(json['prix_vente_suggere']),
      stockActuel: (json['stock_actuel'] as num).toInt(),
      stockAlerte: (json['stock_alerte'] as num).toInt(),
      categorieId: json['categorie_id'] as String?,
    );

Map<String, dynamic> _$$ProduitModelLiteImplToJson(
        _$ProduitModelLiteImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nom': instance.nom,
      'prix_achat_moyen': instance.prixAchatMoyen,
      'prix_vente_suggere': instance.prixVenteSuggere,
      'stock_actuel': instance.stockActuel,
      'stock_alerte': instance.stockAlerte,
      'categorie_id': instance.categorieId,
    };

_$CategorieModelLiteImpl _$$CategorieModelLiteImplFromJson(
        Map<String, dynamic> json) =>
    _$CategorieModelLiteImpl(
      id: json['id'] as String,
      nom: json['nom'] as String,
    );

Map<String, dynamic> _$$CategorieModelLiteImplToJson(
        _$CategorieModelLiteImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nom': instance.nom,
    };
