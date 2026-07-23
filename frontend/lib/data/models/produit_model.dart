import 'package:freezed_annotation/freezed_annotation.dart';
import '../../core/utils/json_helpers.dart';

part 'produit_model.freezed.dart';
part 'produit_model.g.dart';

@freezed
class ProduitModel with _$ProduitModel {
  const factory ProduitModel({
    required String id,
    @JsonKey(name: 'boutique_id') required String boutiqueId,
    @JsonKey(name: 'categorie_id') String? categorieId,
    required String nom,
    @JsonKey(name: 'prix_achat_moyen', fromJson: parseDouble)
    required double prixAchatMoyen,
    @JsonKey(name: 'prix_vente_suggere', fromJson: parseDouble)
    required double prixVenteSuggere,
    @JsonKey(name: 'stock_actuel') required int stockActuel,
    @JsonKey(name: 'stock_alerte') required int stockAlerte,
    @JsonKey(name: 'image_url') String? imageUrl,
  }) = _ProduitModel;
  factory ProduitModel.fromJson(Map<String, dynamic> json) =>
      _$ProduitModelFromJson(json);
}

@freezed
class CategorieModel with _$CategorieModel {
  const factory CategorieModel({
    required String id,
    @JsonKey(name: 'boutique_id') required String boutiqueId,
    required String nom,
  }) = _CategorieModel;
  factory CategorieModel.fromJson(Map<String, dynamic> json) =>
      _$CategorieModelFromJson(json);
}

@freezed
class ProduitCreateRequest with _$ProduitCreateRequest {
  const factory ProduitCreateRequest({
    @JsonKey(name: 'boutique_id') required String boutiqueId,
    @JsonKey(name: 'categorie_id') String? categorieId,
    required String nom,
    @JsonKey(name: 'prix_achat_moyen') required double prixAchatMoyen,
    @JsonKey(name: 'prix_vente_suggere') required double prixVenteSuggere,
    @JsonKey(name: 'stock_actuel') required int stockActuel,
    @JsonKey(name: 'stock_alerte') required int stockAlerte,
    @JsonKey(name: 'image_url', includeIfNull: false) String? imageUrl,
  }) = _ProduitCreateRequest;
  factory ProduitCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$ProduitCreateRequestFromJson(json);
}

@freezed
class ProduitUpdateRequest with _$ProduitUpdateRequest {
  const factory ProduitUpdateRequest({
    @JsonKey(name: 'categorie_id') String? categorieId,
    String? nom,
    @JsonKey(name: 'prix_achat_moyen') double? prixAchatMoyen,
    @JsonKey(name: 'prix_vente_suggere') double? prixVenteSuggere,
    @JsonKey(name: 'stock_actuel') int? stockActuel,
    @JsonKey(name: 'stock_alerte') int? stockAlerte,
    // Toujours sérialisé : l'appelant envoie l'état final (URL, ou `null`
    // pour retirer l'image) — même logique que `categorie_id`.
    @JsonKey(name: 'image_url') String? imageUrl,
  }) = _ProduitUpdateRequest;
  factory ProduitUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$ProduitUpdateRequestFromJson(json);
}

@freezed
class CategorieCreateRequest with _$CategorieCreateRequest {
  const factory CategorieCreateRequest({
    @JsonKey(name: 'boutique_id') required String boutiqueId,
    required String nom,
  }) = _CategorieCreateRequest;
  factory CategorieCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$CategorieCreateRequestFromJson(json);
}

@freezed
class CategorieUpdateRequest with _$CategorieUpdateRequest {
  const factory CategorieUpdateRequest({
    String? nom,
  }) = _CategorieUpdateRequest;
  factory CategorieUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$CategorieUpdateRequestFromJson(json);
}
