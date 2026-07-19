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
class RegisterRequest with _$RegisterRequest {
  const factory RegisterRequest({
    required String nom,
    required String email,
    @JsonKey(name: 'mot_de_passe') required String motDePasse,
    String? telephone,
  }) = _RegisterRequest;
  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);
}

@freezed
class LoginIdRequest with _$LoginIdRequest {
  const factory LoginIdRequest({
    @JsonKey(name: 'id_proprietaire') required String idProprietaire,
    @JsonKey(name: 'mot_de_passe') required String motDePasse,
  }) = _LoginIdRequest;
  factory LoginIdRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginIdRequestFromJson(json);
}

@freezed
class GoogleTokenRequest with _$GoogleTokenRequest {
  const factory GoogleTokenRequest({
    @JsonKey(name: 'id_token') required String idToken,
  }) = _GoogleTokenRequest;
  factory GoogleTokenRequest.fromJson(Map<String, dynamic> json) =>
      _$GoogleTokenRequestFromJson(json);
}

@freezed
class AppleTokenRequest with _$AppleTokenRequest {
  const factory AppleTokenRequest({
    @JsonKey(name: 'identity_token') required String identityToken,
    // Apple ne fournit le nom qu'à la première autorisation, hors du token.
    String? nom,
  }) = _AppleTokenRequest;
  factory AppleTokenRequest.fromJson(Map<String, dynamic> json) =>
      _$AppleTokenRequestFromJson(json);
}

@freezed
class TokenResponse with _$TokenResponse {
  const factory TokenResponse({
    @JsonKey(name: 'access_token') required String accessToken,
    required String role,
    @JsonKey(name: 'boutique_id') String? boutiqueId,
    required String nom,
    String? email,
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
    String? email,
  }) = _SessionUser;

  const SessionUser._();
  bool get isOwner => role == 'OWNER';
  bool get isManager => role == 'MANAGER';
}
