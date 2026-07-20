import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Couleur déterministe d'une catégorie (S5).
///
/// Les catégories n'ont pas de couleur choisie par l'utilisateur : on dérive
/// une couleur stable de l'identifiant de la catégorie, dans une palette de
/// tons moyens lisibles aussi bien sur fond clair que sombre.
abstract final class CategorieCouleur {
  /// Palette de tons moyens (contraste correct sur clair ET sombre).
  static const List<Color> palette = [
    Color(0xFF1B6B2F), // vert BabiCash
    Color(0xFF1565C0), // bleu
    Color(0xFF8E24AA), // violet
    Color(0xFFD84315), // terracotta
    Color(0xFF00838F), // sarcelle
    Color(0xFFBF7E0F), // or foncé
    Color(0xFFC2185B), // framboise
    Color(0xFF5D4037), // brun
    Color(0xFF455A64), // bleu-gris
    Color(0xFF7B8D42), // olive
  ];

  /// Couleur associée à une catégorie ; gris neutre pour « Sans catégorie ».
  static Color pour(String? categorieId) {
    if (categorieId == null || categorieId.isEmpty) {
      return AppColors.textTertiary;
    }
    // Hash stable (indépendant de la session) sur l'id de la catégorie.
    var hash = 0;
    for (final unit in categorieId.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return palette[hash % palette.length];
  }
}
