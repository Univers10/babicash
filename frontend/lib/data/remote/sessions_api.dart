import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';
import '../../core/network/api_client.dart';
import '../models/session_model.dart';

part 'sessions_api.g.dart';

@RestApi()
abstract class SessionsApi {
  factory SessionsApi(Dio dio, {String? baseUrl}) = _SessionsApi;

  @GET('/sessions/active')
  Future<SessionResumeModel?> sessionActive(
    @Query('boutique_id') String boutiqueId,
  );

  @GET('/sessions/')
  Future<List<SessionModel>> listSessions(
    @Query('boutique_id') String boutiqueId, {
    @Query('limit') int limit = 50,
    @Query('offset') int offset = 0,
  });

  @POST('/sessions/ouvrir')
  Future<SessionModel> ouvrirSession(@Body() SessionOuvrirRequest request);

  @POST('/sessions/{id}/fermer')
  Future<SessionResumeModel> fermerSession(
    @Path('id') String id,
    @Body() SessionFermerRequest request,
  );
}

final sessionsApiProvider = Provider<SessionsApi>((ref) {
  return SessionsApi(ref.watch(dioProvider));
});
