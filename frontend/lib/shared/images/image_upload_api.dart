import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';

/// Envoi d'images (produits, logos) au backend.
///
/// Les octets sont déjà recadrés et compressés (JPEG) côté application ; cet
/// appel se contente d'un POST multipart et renvoie l'URL relative que le
/// backend a attribuée (`/static/uploads/...`).
class ImageUploadApi {
  ImageUploadApi(this._dio);

  final Dio _dio;

  /// [kind] : dossier serveur — `produits` ou `logos`.
  Future<String> uploadImage(Uint8List bytes, {String kind = 'produits'}) async {
    final form = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        bytes,
        filename: 'image.jpg',
        contentType: DioMediaType('image', 'jpeg'),
      ),
    });
    final resp = await _dio.post<Map<String, dynamic>>(
      '${_dio.options.baseUrl}/uploads/image',
      queryParameters: {'kind': kind},
      data: form,
    );
    return resp.data!['url'] as String;
  }
}

final imageUploadApiProvider = Provider<ImageUploadApi>((ref) {
  return ImageUploadApi(ref.watch(dioProvider));
});
