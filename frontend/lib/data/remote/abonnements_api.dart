import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';
import '../../core/network/api_client.dart';
import '../models/abonnement_model.dart';

part 'abonnements_api.g.dart';

@RestApi()
abstract class AbonnementsApi {
  factory AbonnementsApi(Dio dio, {String? baseUrl}) = _AbonnementsApi;

  @GET('/abonnements/mon-plan')
  Future<AbonnementOut> monPlan();

  @GET('/abonnements/quota/{boutique_id}')
  Future<QuotaInfo> quotaBoutique(@Path('boutique_id') String boutiqueId);

  @POST('/abonnements/upgrade')
  Future<AbonnementOut> upgrade(@Body() UpgradePlanRequest request);
}

final abonnementsApiProvider = Provider<AbonnementsApi>((ref) {
  return AbonnementsApi(ref.watch(dioProvider));
});
