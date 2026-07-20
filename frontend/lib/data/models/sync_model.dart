import 'package:freezed_annotation/freezed_annotation.dart';
import '../../core/utils/json_helpers.dart';

part 'sync_model.freezed.dart';
part 'sync_model.g.dart';

// ── PUSH ─────────────────────────────────────────────────────────────────────

@freezed
class LigneVenteIn with _$LigneVenteIn {
  const factory LigneVenteIn({
    @JsonKey(name: 'produit_id') String? produitId,
    @Default(1) int quantite,
    @JsonKey(name: 'prix_vendu_reel') required double prixVenduReel,
    @JsonKey(name: 'lot_id') String? lotId,
    @JsonKey(name: 'lot_nom') String? lotNom,
  }) = _LigneVenteIn;
  factory LigneVenteIn.fromJson(Map<String, dynamic> json) =>
      _$LigneVenteInFromJson(json);
}

@freezed
class VenteIn with _$VenteIn {
  const factory VenteIn({
    @JsonKey(name: 'id_local_smartphone') required String idLocal,
    @JsonKey(name: 'session_id') String? sessionId,
    @JsonKey(name: 'tier_id') String? tierId,
    @JsonKey(name: 'date_vente') DateTime? dateVente,
    @JsonKey(name: 'mode_paiement') required String modePaiement,
    required List<LigneVenteIn> lignes,
  }) = _VenteIn;
  factory VenteIn.fromJson(Map<String, dynamic> json) =>
      _$VenteInFromJson(json);
}

@freezed
class DepenseIn with _$DepenseIn {
  const factory DepenseIn({
    @JsonKey(name: 'id_local_smartphone') required String idLocal,
    @JsonKey(name: 'session_id') String? sessionId,
    @JsonKey(name: 'type_transaction') @Default('SORTIE_DEPENSE') String typeTransaction,
    required double montant,
    required String motif,
    @JsonKey(name: 'date_transaction') DateTime? dateTransaction,
  }) = _DepenseIn;
  factory DepenseIn.fromJson(Map<String, dynamic> json) =>
      _$DepenseInFromJson(json);
}

@freezed
class MouvementStockIn with _$MouvementStockIn {
  const factory MouvementStockIn({
    @JsonKey(name: 'id_local_smartphone') required String idLocal,
    @JsonKey(name: 'produit_id') required String produitId,
    @JsonKey(name: 'produit_nom') @Default('') String produitNom,
    @JsonKey(name: 'type_mouvement') required String typeMouvement,
    required int quantite,
    required String motif,
    @JsonKey(name: 'auteur_nom') @Default('') String auteurNom,
    @JsonKey(name: 'date_mouvement') DateTime? dateMouvement,
  }) = _MouvementStockIn;
  factory MouvementStockIn.fromJson(Map<String, dynamic> json) =>
      _$MouvementStockInFromJson(json);
}

@freezed
class SyncPushRequest with _$SyncPushRequest {
  const factory SyncPushRequest({
    @JsonKey(name: 'boutique_id') required String boutiqueId,
    @Default([]) List<VenteIn> ventes,
    @Default([]) List<DepenseIn> depenses,
    @JsonKey(name: 'entrees_stock') @Default([]) List<dynamic> entreesStock,
    @JsonKey(name: 'mouvements_stock')
    @Default([])
    List<MouvementStockIn> mouvementsStock,
  }) = _SyncPushRequest;
  factory SyncPushRequest.fromJson(Map<String, dynamic> json) =>
      _$SyncPushRequestFromJson(json);
}

// ── PUSH RESPONSE ─────────────────────────────────────────────────────────────

@freezed
class RecuLigne with _$RecuLigne {
  const factory RecuLigne({
    required String nom,
    required int quantite,
    @JsonKey(name: 'prix_unitaire', fromJson: parseDouble)
    required double prixUnitaire,
    @JsonKey(name: 'total_ligne', fromJson: parseDouble)
    required double totalLigne,
  }) = _RecuLigne;
  factory RecuLigne.fromJson(Map<String, dynamic> json) =>
      _$RecuLigneFromJson(json);
}

@freezed
class RecuOut with _$RecuOut {
  const factory RecuOut({
    @JsonKey(name: 'vente_id') required String venteId,
    required String numero,
    @JsonKey(name: 'boutique_nom') required String boutiqueNom,
    @JsonKey(name: 'date_vente') required DateTime dateVente,
    @JsonKey(name: 'mode_paiement') required String modePaiement,
    required List<RecuLigne> lignes,
    @JsonKey(name: 'montant_total', fromJson: parseDouble)
    required double montantTotal,
    @JsonKey(name: 'client_nom') String? clientNom,
  }) = _RecuOut;
  factory RecuOut.fromJson(Map<String, dynamic> json) =>
      _$RecuOutFromJson(json);
}

@freezed
class VentePushResult with _$VentePushResult {
  const factory VentePushResult({
    @JsonKey(name: 'id_local_smartphone') required String idLocal,
    @JsonKey(name: 'vente_id') required String venteId,
    @JsonKey(name: 'deja_synchronisee') @Default(false) bool dejaSynchronisee,
    @JsonKey(name: 'signale_proprietaire') @Default(false) bool signaleProprietaire,
    String? avertissement,
    RecuOut? recu,
  }) = _VentePushResult;
  factory VentePushResult.fromJson(Map<String, dynamic> json) =>
      _$VentePushResultFromJson(json);
}

@freezed
class AlerteStockItem with _$AlerteStockItem {
  const factory AlerteStockItem({
    @JsonKey(name: 'produit_id') required String produitId,
    required String nom,
    @JsonKey(name: 'stock_actuel') required int stockActuel,
    @JsonKey(name: 'stock_alerte') required int stockAlerte,
    @JsonKey(name: 'en_rupture') required bool enRupture,
  }) = _AlerteStockItem;
  factory AlerteStockItem.fromJson(Map<String, dynamic> json) =>
      _$AlerteStockItemFromJson(json);
}

@freezed
class MouvementStockPushResult with _$MouvementStockPushResult {
  const factory MouvementStockPushResult({
    @JsonKey(name: 'id_local_smartphone') required String idLocal,
    @JsonKey(name: 'mouvement_id') required String mouvementId,
    @JsonKey(name: 'deja_synchronise') @Default(false) bool dejaSynchronise,
    @JsonKey(name: 'stock_actuel') int? stockActuel,
  }) = _MouvementStockPushResult;
  factory MouvementStockPushResult.fromJson(Map<String, dynamic> json) =>
      _$MouvementStockPushResultFromJson(json);
}

@freezed
class SyncPushResponse with _$SyncPushResponse {
  const factory SyncPushResponse({
    @Default([]) List<VentePushResult> ventes,
    @Default([]) List<dynamic> depenses,
    @JsonKey(name: 'mouvements_stock')
    @Default([])
    List<MouvementStockPushResult> mouvementsStock,
    @JsonKey(name: 'alertes_stock') @Default([]) List<AlerteStockItem> alertesStock,
  }) = _SyncPushResponse;
  factory SyncPushResponse.fromJson(Map<String, dynamic> json) =>
      _$SyncPushResponseFromJson(json);
}

// ── PULL RESPONSE ─────────────────────────────────────────────────────────────

@freezed
class SyncPullResponse with _$SyncPullResponse {
  const factory SyncPullResponse({
    @JsonKey(name: 'boutique_id') required String boutiqueId,
    required List<ProduitModelLite> produits,
    required List<CategorieModelLite> categories,
    @JsonKey(name: 'server_time') required DateTime serverTime,
  }) = _SyncPullResponse;
  factory SyncPullResponse.fromJson(Map<String, dynamic> json) =>
      _$SyncPullResponseFromJson(json);
}

@freezed
class ProduitModelLite with _$ProduitModelLite {
  const factory ProduitModelLite({
    required String id,
    required String nom,
    @JsonKey(name: 'prix_achat_moyen', fromJson: parseDouble)
    required double prixAchatMoyen,
    @JsonKey(name: 'prix_vente_suggere', fromJson: parseDouble)
    required double prixVenteSuggere,
    @JsonKey(name: 'stock_actuel') required int stockActuel,
    @JsonKey(name: 'stock_alerte') required int stockAlerte,
    @JsonKey(name: 'categorie_id') String? categorieId,
  }) = _ProduitModelLite;
  factory ProduitModelLite.fromJson(Map<String, dynamic> json) =>
      _$ProduitModelLiteFromJson(json);
}

@freezed
class CategorieModelLite with _$CategorieModelLite {
  const factory CategorieModelLite({
    required String id,
    required String nom,
  }) = _CategorieModelLite;
  factory CategorieModelLite.fromJson(Map<String, dynamic> json) =>
      _$CategorieModelLiteFromJson(json);
}
