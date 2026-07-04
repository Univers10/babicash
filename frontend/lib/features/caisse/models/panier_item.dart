import 'package:freezed_annotation/freezed_annotation.dart';

part 'panier_item.freezed.dart';

@freezed
class PanierItem with _$PanierItem {
  const factory PanierItem({
    String? produitId,
    required String nom,
    required double prixUnitaire,
    required double prixAchat,
    @Default(1) int quantite,
  }) = _PanierItem;

  const PanierItem._();

  double get total => prixUnitaire * quantite;
  double get margeUnitaire => prixUnitaire - prixAchat;
  double get margeTotal => margeUnitaire * quantite;
  bool get aVendreAPerte => produitId != null && prixUnitaire < prixAchat;
}
