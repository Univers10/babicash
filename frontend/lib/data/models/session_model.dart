import 'package:freezed_annotation/freezed_annotation.dart';
import '../../core/utils/json_helpers.dart';

part 'session_model.freezed.dart';
part 'session_model.g.dart';

@freezed
class SessionModel with _$SessionModel {
  const factory SessionModel({
    required String id,
    @JsonKey(name: 'boutique_id') required String boutiqueId,
    @JsonKey(name: 'utilisateur_nom') required String utilisateurNom,
    @JsonKey(name: 'date_ouverture') required DateTime dateOuverture,
    @JsonKey(name: 'date_fermeture') DateTime? dateFermeture,
    @JsonKey(name: 'montant_initial', fromJson: parseDouble) @Default(0) double montantInitial,
    @JsonKey(name: 'montant_final_declare', fromJson: parseDoubleNullable) double? montantFinalDeclare,
    required String statut,
  }) = _SessionModel;

  factory SessionModel.fromJson(Map<String, dynamic> json) =>
      _$SessionModelFromJson(json);
}

@freezed
class SessionResumeModel with _$SessionResumeModel {
  const factory SessionResumeModel({
    required SessionModel session,
    @JsonKey(name: 'nb_ventes', fromJson: parseInt) @Default(0) int nbVentes,
    @JsonKey(name: 'total_ventes_especes', fromJson: parseDouble) @Default(0) double totalVentesEspeces,
    @JsonKey(name: 'total_ventes_autres', fromJson: parseDouble) @Default(0) double totalVentesAutres,
    @JsonKey(name: 'total_entrees', fromJson: parseDouble) @Default(0) double totalEntrees,
    @JsonKey(name: 'total_sorties', fromJson: parseDouble) @Default(0) double totalSorties,
    @JsonKey(name: 'montant_theorique', fromJson: parseDouble) @Default(0) double montantTheorique,
    @JsonKey(fromJson: parseDoubleNullable) double? ecart,
    @JsonKey(name: 'ecart_signale') @Default(false) bool ecartSignale,
  }) = _SessionResumeModel;

  factory SessionResumeModel.fromJson(Map<String, dynamic> json) =>
      _$SessionResumeModelFromJson(json);
}

@freezed
class SessionOuvrirRequest with _$SessionOuvrirRequest {
  const factory SessionOuvrirRequest({
    @JsonKey(name: 'boutique_id') required String boutiqueId,
    @JsonKey(name: 'montant_initial') @Default(0) double montantInitial,
  }) = _SessionOuvrirRequest;

  factory SessionOuvrirRequest.fromJson(Map<String, dynamic> json) =>
      _$SessionOuvrirRequestFromJson(json);
}

@freezed
class SessionFermerRequest with _$SessionFermerRequest {
  const factory SessionFermerRequest({
    @JsonKey(name: 'montant_final_declare') required double montantFinalDeclare,
  }) = _SessionFermerRequest;

  factory SessionFermerRequest.fromJson(Map<String, dynamic> json) =>
      _$SessionFermerRequestFromJson(json);
}
