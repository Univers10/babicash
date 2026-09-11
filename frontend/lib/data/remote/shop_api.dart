import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../models/shop_model.dart';

/// API de la boutique « Matériel & accessoires ».
class ShopApi {
  ShopApi(this._dio, {this.baseUrl});

  final Dio _dio;
  String? baseUrl;

  String get _baseUrl {
    if (baseUrl == null || baseUrl!.trim().isEmpty) return _dio.options.baseUrl;
    final url = Uri.parse(baseUrl!);
    if (url.isAbsolute) return url.toString();
    return Uri.parse(_dio.options.baseUrl).resolveUri(url).toString();
  }

  /// Catalogue des produits en vente.
  ///
  /// [actifs] = `false` permet de lire aussi les produits retirés
  /// (usage interne, non exposé dans l'app).
  Future<List<ShopApiProduit>> getProduits({bool actifs = true}) async {
    final resp = await _dio.get<List<dynamic>>(
      '$_baseUrl/shop/produits',
      queryParameters: {'actifs': actifs},
    );
    return (resp.data ?? const [])
        .map((e) => ShopApiProduit.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Enregistre une commande côté serveur (best-effort).
  ///
  /// Le total est recalculé côté serveur ; le prix du catalogue fait foi
  /// lorsque le produit est reconnu.
  Future<Map<String, dynamic>> createCommande({
    required String clientNom,
    String? clientTelephone,
    required List<Map<String, dynamic>> lignes,
  }) async {
    final resp = await _dio.post<Map<String, dynamic>>(
      '$_baseUrl/shop/commandes',
      data: {
        'client_nom': clientNom,
        if (clientTelephone != null && clientTelephone.isNotEmpty)
          'client_telephone': clientTelephone,
        'source': 'APP',
        'lignes': lignes,
      },
    );
    return resp.data ?? const {};
  }
}

final shopApiProvider = Provider<ShopApi>((ref) {
  return ShopApi(ref.watch(dioProvider));
});