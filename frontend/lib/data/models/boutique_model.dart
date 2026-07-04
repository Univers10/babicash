import 'package:freezed_annotation/freezed_annotation.dart';

part 'boutique_model.freezed.dart';
part 'boutique_model.g.dart';

@freezed
class BoutiqueModel with _$BoutiqueModel {
  const factory BoutiqueModel({
    required String id,
    required String nom,
    @JsonKey(name: 'proprietaire_id') required String proprietaireId,
    @JsonKey(name: 'date_creation') required DateTime dateCreation,
  }) = _BoutiqueModel;
  factory BoutiqueModel.fromJson(Map<String, dynamic> json) =>
      _$BoutiqueModelFromJson(json);
}
