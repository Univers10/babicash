import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core/utils/json_helpers.dart';

part 'abonnement_model.freezed.dart';
part 'abonnement_model.g.dart';

@freezed
class AbonnementOut with _$AbonnementOut {
  const factory AbonnementOut({
    @JsonKey(name: 'proprietaire_id') required String proprietaireId,
    required String plan,
    @JsonKey(name: 'quota_ventes_par_boutique') required int quotaVentesParBoutique,
    // Le backend (Pydantic v2) sérialise les Decimal en chaînes ("5000.00")
    @JsonKey(name: 'prix_base', fromJson: parseDouble) @Default(5000) double prixBase,
    @JsonKey(name: 'nb_boutiques') @Default(1) int nbBoutiques,
    @JsonKey(name: 'prix_total_mensuel', fromJson: parseDouble) @Default(5000) double prixTotalMensuel,
    @JsonKey(name: 'date_fin') DateTime? dateFin,
    @Default(true) bool actif,
  }) = _AbonnementOut;

  factory AbonnementOut.fromJson(Map<String, dynamic> json) =>
      _$AbonnementOutFromJson(json);
}

@freezed
class QuotaInfo with _$QuotaInfo {
  const factory QuotaInfo({
    @JsonKey(name: 'boutique_id') required String boutiqueId,
    required String plan,
    @JsonKey(name: 'quota_par_boutique') required int quotaParBoutique,
    @JsonKey(name: 'ventes_ce_mois') @Default(0) int ventesCeMois,
    @JsonKey(name: 'ventes_restantes') int? ventesRestantes,
    @Default(false) bool illimite,
  }) = _QuotaInfo;

  factory QuotaInfo.fromJson(Map<String, dynamic> json) =>
      _$QuotaInfoFromJson(json);
}

@freezed
class UpgradePlanRequest with _$UpgradePlanRequest {
  const factory UpgradePlanRequest({
    required String plan,
    @JsonKey(name: 'date_fin') DateTime? dateFin,
  }) = _UpgradePlanRequest;

  factory UpgradePlanRequest.fromJson(Map<String, dynamic> json) =>
      _$UpgradePlanRequestFromJson(json);
}
