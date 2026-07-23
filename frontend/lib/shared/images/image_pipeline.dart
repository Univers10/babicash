import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

import 'image_crop_screen.dart';

/// Chaîne de préparation d'image : sélection → recadrage carré → compression.
///
/// Objectif : des images légères (≈ 30–70 Ko) et uniformes, prêtes à
/// l'upload, tout en gardant une bonne qualité visuelle dans l'app.
class ImagePipeline {
  const ImagePipeline._();

  /// Compresse [raw] en JPEG carré ~[size] px, qualité [quality].
  ///
  /// Retourne [raw] tel quel si la compression échoue (plateforme non
  /// supportée, format inattendu…), pour ne jamais bloquer l'utilisateur.
  static Future<Uint8List> compressSquare(
    Uint8List raw, {
    int size = 800,
    int quality = 80,
  }) async {
    try {
      final out = await FlutterImageCompress.compressWithList(
        raw,
        minWidth: size,
        minHeight: size,
        quality: quality,
        format: CompressFormat.jpeg,
      );
      return out.isNotEmpty ? out : raw;
    } catch (_) {
      return raw;
    }
  }

  /// Sélectionne une image depuis [source], ouvre l'éditeur de recadrage
  /// carré, puis compresse. Retourne les octets JPEG prêts à l'upload, ou
  /// `null` si l'utilisateur annule à une étape.
  static Future<Uint8List?> pickCropCompress(
    BuildContext context, {
    required ImageSource source,
  }) async {
    final XFile? file = await ImagePicker().pickImage(
      source: source,
      maxWidth: 2000,
      maxHeight: 2000,
      imageQuality: 90,
    );
    if (file == null) return null;

    final raw = await file.readAsBytes();
    if (!context.mounted) return null;

    final cropped = await Navigator.of(context).push<Uint8List>(
      MaterialPageRoute(
        builder: (_) => ImageCropScreen(imageBytes: raw),
      ),
    );
    if (cropped == null) return null;

    return compressSquare(cropped);
  }
}
