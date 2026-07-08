// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vente_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LigneVenteHistoriqueImpl _$$LigneVenteHistoriqueImplFromJson(
        Map<String, dynamic> json) =>
    _$LigneVenteHistoriqueImpl(
      id: json['id'] as String,
      produitId: json['produit_id'] as String?,
      produitNom: json['produit_nom'] as String?,
      quantite: (json['quantite'] as num).toInt(),
      prixVenduReel: parseDouble(json['prix_vendu_reel']),
      margeCalculee: json['marge_calculee'] == null
          ? 0
          : parseDouble(json['marge_calculee']),
      venteAPerte: json['vente_a_perte'] as bool? ?? false,
    );

Map<String, dynamic> _$$LigneVenteHistoriqueImplToJson(
        _$LigneVenteHistoriqueImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'produit_id': instance.produitId,
      'produit_nom': instance.produitNom,
      'quantite': instance.quantite,
      'prix_vendu_reel': instance.prixVenduReel,
      'marge_calculee': instance.margeCalculee,
      'vente_a_perte': instance.venteAPerte,
    };

_$VenteHistoriqueImpl _$$VenteHistoriqueImplFromJson(
        Map<String, dynamic> json) =>
    _$VenteHistoriqueImpl(
      id: json['id'] as String,
      boutiqueId: json['boutique_id'] as String,
      dateVente: DateTime.parse(json['date_vente'] as String),
      montantTotal: parseDouble(json['montant_total']),
      modePaiement: json['mode_paiement'] as String,
      signaleProprietaire: json['signale_proprietaire'] as bool? ?? false,
      tierId: json['tier_id'] as String?,
      clientNom: json['client_nom'] as String?,
      lignes: (json['lignes'] as List<dynamic>?)
              ?.map((e) =>
                  LigneVenteHistorique.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$VenteHistoriqueImplToJson(
        _$VenteHistoriqueImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'boutique_id': instance.boutiqueId,
      'date_vente': instance.dateVente.toIso8601String(),
      'montant_total': instance.montantTotal,
      'mode_paiement': instance.modePaiement,
      'signale_proprietaire': instance.signaleProprietaire,
      'tier_id': instance.tierId,
      'client_nom': instance.clientNom,
      'lignes': instance.lignes.map((e) => e.toJson()).toList(),
    };

_$VenteListResponseImpl _$$VenteListResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$VenteListResponseImpl(
      total: (json['total'] as num).toInt(),
      ventes: (json['ventes'] as List<dynamic>)
          .map((e) => VenteHistorique.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$VenteListResponseImplToJson(
        _$VenteListResponseImpl instance) =>
    <String, dynamic>{
      'total': instance.total,
      'ventes': instance.ventes.map((e) => e.toJson()).toList(),
    };
