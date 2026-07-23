import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';

/// Origine (schéma + hôte) du backend, dérivée de la base URL Dio
/// (`https://host/api/v1` → `https://host`).
///
/// Les images uploadées sont servies sous `/static/...`, hors du préfixe
/// `/api/v1` — il faut donc les résoudre contre l'origine, pas la base API.
final apiOriginProvider = Provider<String>((ref) {
  final base = ref.watch(dioProvider).options.baseUrl;
  final u = Uri.parse(base);
  return u.replace(path: '', query: '', fragment: '').toString();
});

/// Convertit une URL d'image éventuellement relative (`/static/...`) renvoyée
/// par le backend en URL absolue affichable. Retourne `''` si [url] est vide.
String absoluteMediaUrl(String origin, String? url) {
  if (url == null || url.trim().isEmpty) return '';
  final u = Uri.tryParse(url);
  if (u != null && u.hasScheme) return url; // déjà absolue
  final path = url.startsWith('/') ? url : '/$url';
  return '$origin$path';
}
