import 'package:freezed_annotation/freezed_annotation.dart';

part 'produit_model.freezed.dart';
part 'produit_model.g.dart';

@freezed
class ProduitModel with _$ProduitModel {
  const factory ProduitModel({
    required String id,
    @JsonKey(name: 'boutique_id') required String boutiqueId,
    @JsonKey(name: 'categorie_id') String? categorieId,
    required String nom,
    @JsonKey(name: 'prix_achat_moyen') required double prixAchatMoyen,
    @JsonKey(name: 'prix_vente_suggere') required double prixVenteSuggere,
    @JsonKey(name: 'stock_actuel') required int stockActuel,
    @JsonKey(name: 'stock_alerte') required int stockAlerte,
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
