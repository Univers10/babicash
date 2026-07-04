import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';
import '../../core/network/api_client.dart';
import '../models/tier_model.dart';

part 'tiers_api.g.dart';

@RestApi()
abstract class TiersApi {
  factory TiersApi(Dio dio, {String? baseUrl}) = _TiersApi;

  @GET('/tiers/')
  Future<List<TierModel>> listTiers(
    @Query('boutique_id') String boutiqueId, {
    @Query('type_tiers') String? typeTiers,
    @Query('limit') int limit = 200,
    @Query('offset') int offset = 0,
  });

  @POST('/tiers/')
  Future<TierModel> createTier(@Body() TierCreateRequest request);

  @PATCH('/tiers/{id}')
  Future<TierModel> updateTier(
    @Path('id') String id,
    @Body() TierUpdateRequest request,
  );

  @POST('/tiers/{id}/paiement')
  Future<TierModel> enregistrerPaiement(
    @Path('id') String id,
    @Body() PaiementTierRequest request,
  );
}

final tiersApiProvider = Provider<TiersApi>((ref) {
  return TiersApi(ref.watch(dioProvider));
});
