import 'package:freezed_annotation/freezed_annotation.dart';
import '../../core/utils/json_helpers.dart';

part 'tier_model.freezed.dart';
part 'tier_model.g.dart';

@freezed
class TierModel with _$TierModel {
  const factory TierModel({
    required String id,
    @JsonKey(name: 'boutique_id') required String boutiqueId,
    required String nom,
    String? telephone,
    @JsonKey(name: 'type_tiers') required String typeTiers,
    @JsonKey(name: 'solde_du', fromJson: parseDouble) @Default(0) double soldeDu,
  }) = _TierModel;

  factory TierModel.fromJson(Map<String, dynamic> json) =>
      _$TierModelFromJson(json);
}

@freezed
class TierCreateRequest with _$TierCreateRequest {
  const factory TierCreateRequest({
    @JsonKey(name: 'boutique_id') required String boutiqueId,
    required String nom,
    String? telephone,
    @JsonKey(name: 'type_tiers') required String typeTiers,
  }) = _TierCreateRequest;

  factory TierCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$TierCreateRequestFromJson(json);
}

@freezed
class TierUpdateRequest with _$TierUpdateRequest {
  const factory TierUpdateRequest({
    String? nom,
    String? telephone,
  }) = _TierUpdateRequest;

  factory TierUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$TierUpdateRequestFromJson(json);
}

@freezed
class PaiementTierRequest with _$PaiementTierRequest {
  const factory PaiementTierRequest({
    required double montant,
    String? motif,
  }) = _PaiementTierRequest;

  factory PaiementTierRequest.fromJson(Map<String, dynamic> json) =>
      _$PaiementTierRequestFromJson(json);
}
