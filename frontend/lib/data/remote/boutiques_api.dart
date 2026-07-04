import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';
import '../../core/network/api_client.dart';
import '../models/boutique_model.dart';

part 'boutiques_api.g.dart';

@RestApi()
abstract class BoutiquesApi {
  factory BoutiquesApi(Dio dio, {String? baseUrl}) = _BoutiquesApi;

  @GET('/boutiques/')
  Future<List<BoutiqueModel>> listBoutiques();

  @POST('/boutiques/')
  Future<BoutiqueModel> createBoutique(@Body() Map<String, dynamic> body);
}

final boutiquesApiProvider = Provider<BoutiquesApi>((ref) {
  return BoutiquesApi(ref.watch(dioProvider));
});
