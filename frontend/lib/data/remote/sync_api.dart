import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';
import '../../core/network/api_client.dart';
import '../models/sync_model.dart';

part 'sync_api.g.dart';

@RestApi()
abstract class SyncApi {
  factory SyncApi(Dio dio, {String? baseUrl}) = _SyncApi;

  @POST('/sync/push')
  Future<SyncPushResponse> push(@Body() SyncPushRequest request);

  @GET('/sync/pull')
  Future<SyncPullResponse> pull(
    @Query('boutique_id') String boutiqueId,
  );
}

final syncApiProvider = Provider<SyncApi>((ref) {
  return SyncApi(ref.watch(dioProvider));
});
