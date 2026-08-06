import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../models/receipt_config.dart';

/// Config du reçu telle que renvoyée par le serveur, avec l'horodatage
/// d'arbitrage (dernier-écrivain-gagne).
typedef RemoteRecuConfig = ({ReceiptConfig config, DateTime updatedAt});

/// Accès REST à la personnalisation du reçu (`/boutiques/{id}/recu-config`).
///
/// Les erreurs Dio sont converties en [AppException] pour être traitées
/// silencieusement par le [SyncService] (retentées au prochain cycle).
class RecuConfigApi {
  RecuConfigApi(this._dio);

  final Dio _dio;

  String _url(String boutiqueId) =>
      '${_dio.options.baseUrl}/boutiques/$boutiqueId/recu-config';

  /// Récupère la config serveur, ou `null` si la boutique n'en a pas encore.
  Future<RemoteRecuConfig?> get(String boutiqueId) async {
    try {
      final resp = await _dio.get<dynamic>(_url(boutiqueId));
      final data = resp.data;
      if (data is! Map) return null; // corps `null` => aucune config serveur
      return _fromApi(Map<String, dynamic>.from(data));
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// Enregistre (upsert) la config et retourne la version serveur horodatée.
  Future<RemoteRecuConfig> put(String boutiqueId, ReceiptConfig config) async {
    try {
      final resp = await _dio.put<Map<String, dynamic>>(
        _url(boutiqueId),
        data: _toApi(config),
      );
      return _fromApi(resp.data!);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  static Map<String, dynamic> _toApi(ReceiptConfig c) => {
        'nom_boutique': c.nomBoutique,
        'adresse': c.adresse,
        'telephone': c.telephone,
        'entete': c.entete,
        'pied_message': c.piedMessage,
        'afficher_logo': c.afficherLogo,
        'afficher_vendeur': c.afficherVendeur,
      };

  static RemoteRecuConfig _fromApi(Map<String, dynamic> j) => (
        config: ReceiptConfig(
          nomBoutique: j['nom_boutique'] as String? ?? '',
          adresse: j['adresse'] as String? ?? '',
          telephone: j['telephone'] as String? ?? '',
          entete: j['entete'] as String? ?? '',
          piedMessage:
              j['pied_message'] as String? ?? ReceiptConfig.defaultPiedMessage,
          afficherLogo: j['afficher_logo'] as bool? ?? true,
          afficherVendeur: j['afficher_vendeur'] as bool? ?? true,
        ),
        updatedAt:
            DateTime.tryParse(j['updated_at'] as String? ?? '') ?? DateTime.now(),
      );
}

final recuConfigApiProvider = Provider<RecuConfigApi>((ref) {
  return RecuConfigApi(ref.watch(dioProvider));
});
