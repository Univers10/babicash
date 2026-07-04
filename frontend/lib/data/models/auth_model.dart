import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_model.freezed.dart';
part 'auth_model.g.dart';

@freezed
class LoginRequest with _$LoginRequest {
  const factory LoginRequest({
    required String email,
    @JsonKey(name: 'mot_de_passe') required String motDePasse,
  }) = _LoginRequest;
  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
}

@freezed
class LoginPinRequest with _$LoginPinRequest {
  const factory LoginPinRequest({
    required String telephone,
    @JsonKey(name: 'code_pin') required String codePin,
  }) = _LoginPinRequest;
  factory LoginPinRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginPinRequestFromJson(json);
}

@freezed
class TokenResponse with _$TokenResponse {
  const factory TokenResponse({
    @JsonKey(name: 'access_token') required String accessToken,
    required String role,
    @JsonKey(name: 'boutique_id') String? boutiqueId,
    required String nom,
  }) = _TokenResponse;
  factory TokenResponse.fromJson(Map<String, dynamic> json) =>
      _$TokenResponseFromJson(json);
}

@freezed
class SessionUser with _$SessionUser {
  const factory SessionUser({
    required String token,
    required String role,
    required String nom,
    String? boutiqueId,
  }) = _SessionUser;

  const SessionUser._();
  bool get isOwner => role == 'OWNER';
  bool get isManager => role == 'MANAGER';
}
