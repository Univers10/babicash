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
    @Default(0.0) double remise, // pourcentage 0-100
  }) = _PanierItem;

  const PanierItem._();

  double get prixApresRemise => prixUnitaire * (1 - remise / 100);
  double get total => prixApresRemise * quantite;
  double get margeUnitaire => prixApresRemise - prixAchat;
  double get margeTotal => margeUnitaire * quantite;
  bool get aVendreAPerte => produitId != null && prixApresRemise < prixAchat;
}
