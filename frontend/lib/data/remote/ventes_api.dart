import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../models/vente_model.dart';

class VentesApi {
  VentesApi(this._dio);
  final Dio _dio;

  Future<void> retourMarchandise(String venteId) async {
    await _dio.post<Map<String, dynamic>>('/ventes/$venteId/retour');
  }

  Future<VenteListResponse> listVentes({
    required String boutiqueId,
    String? modePaiement,
    DateTime? dateDebut,
    DateTime? dateFin,
    String? search,
    bool signaleSeulement = false,
    String? caissierId,
    bool includeRetours = false,
    int limit = 50,
    int offset = 0,
  }) async {
    final resp = await _dio.get<Map<String, dynamic>>(
      '/ventes/',
      queryParameters: {
        'boutique_id': boutiqueId,
        if (modePaiement != null) 'mode_paiement': modePaiement,
        if (dateDebut != null)
          'date_debut': '${dateDebut.year}-${dateDebut.month.toString().padLeft(2, '0')}-${dateDebut.day.toString().padLeft(2, '0')}',
        if (dateFin != null)
          'date_fin': '${dateFin.year}-${dateFin.month.toString().padLeft(2, '0')}-${dateFin.day.toString().padLeft(2, '0')}',
        if (search != null && search.isNotEmpty) 'search': search,
        if (signaleSeulement) 'signale_seulement': true,
        if (caissierId != null) 'caissier_id': caissierId,
        if (includeRetours) 'include_retours': true,
        'limit': limit,
        'offset': offset,
      },
    );
    return VenteListResponse.fromJson(resp.data!);
  }
}

final ventesApiProvider = Provider<VentesApi>((ref) {
  return VentesApi(ref.watch(dioProvider));
});
