import 'package:freezed_annotation/freezed_annotation.dart';
import '../../core/utils/json_helpers.dart';

part 'vente_model.freezed.dart';
part 'vente_model.g.dart';

@freezed
class LigneVenteHistorique with _$LigneVenteHistorique {
  const factory LigneVenteHistorique({
    required String id,
    @JsonKey(name: 'produit_id') String? produitId,
    @JsonKey(name: 'produit_nom') String? produitNom,
    required int quantite,
    @JsonKey(name: 'prix_vendu_reel', fromJson: parseDouble) required double prixVenduReel,
    @JsonKey(name: 'marge_calculee', fromJson: parseDouble) @Default(0) double margeCalculee,
    @JsonKey(name: 'vente_a_perte') @Default(false) bool venteAPerte,
  }) = _LigneVenteHistorique;

  factory LigneVenteHistorique.fromJson(Map<String, dynamic> json) =>
      _$LigneVenteHistoriqueFromJson(json);
}

@freezed
class VenteHistorique with _$VenteHistorique {
  const factory VenteHistorique({
    required String id,
    @JsonKey(name: 'boutique_id') required String boutiqueId,
    @JsonKey(name: 'date_vente') required DateTime dateVente,
    @JsonKey(name: 'montant_total', fromJson: parseDouble) required double montantTotal,
    @JsonKey(name: 'mode_paiement') required String modePaiement,
    @JsonKey(name: 'signale_proprietaire') @Default(false) bool signaleProprietaire,
    @JsonKey(name: 'tier_id') String? tierId,
    @JsonKey(name: 'client_nom') String? clientNom,
    @Default([]) List<LigneVenteHistorique> lignes,
  }) = _VenteHistorique;

  factory VenteHistorique.fromJson(Map<String, dynamic> json) =>
      _$VenteHistoriqueFromJson(json);
}

@freezed
class VenteListResponse with _$VenteListResponse {
  const factory VenteListResponse({
    required int total,
    required List<VenteHistorique> ventes,
  }) = _VenteListResponse;

  factory VenteListResponse.fromJson(Map<String, dynamic> json) =>
      _$VenteListResponseFromJson(json);
}
