// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LoginRequestImpl _$$LoginRequestImplFromJson(Map<String, dynamic> json) =>
    _$LoginRequestImpl(
      email: json['email'] as String,
      motDePasse: json['mot_de_passe'] as String,
    );

Map<String, dynamic> _$$LoginRequestImplToJson(_$LoginRequestImpl instance) =>
    <String, dynamic>{
      'email': instance.email,
      'mot_de_passe': instance.motDePasse,
    };

_$LoginPinRequestImpl _$$LoginPinRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$LoginPinRequestImpl(
      telephone: json['telephone'] as String,
      codePin: json['code_pin'] as String,
    );

Map<String, dynamic> _$$LoginPinRequestImplToJson(
        _$LoginPinRequestImpl instance) =>
    <String, dynamic>{
      'telephone': instance.telephone,
      'code_pin': instance.codePin,
    };

_$RegisterRequestImpl _$$RegisterRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$RegisterRequestImpl(
      nom: json['nom'] as String,
      email: json['email'] as String,
      motDePasse: json['mot_de_passe'] as String,
      telephone: json['telephone'] as String?,
    );

Map<String, dynamic> _$$RegisterRequestImplToJson(
        _$RegisterRequestImpl instance) =>
    <String, dynamic>{
      'nom': instance.nom,
      'email': instance.email,
      'mot_de_passe': instance.motDePasse,
      'telephone': instance.telephone,
    };

_$LoginIdRequestImpl _$$LoginIdRequestImplFromJson(Map<String, dynamic> json) =>
    _$LoginIdRequestImpl(
      idProprietaire: json['id_proprietaire'] as String,
      motDePasse: json['mot_de_passe'] as String,
    );

Map<String, dynamic> _$$LoginIdRequestImplToJson(
        _$LoginIdRequestImpl instance) =>
    <String, dynamic>{
      'id_proprietaire': instance.idProprietaire,
      'mot_de_passe': instance.motDePasse,
    };

_$GoogleTokenRequestImpl _$$GoogleTokenRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$GoogleTokenRequestImpl(
      idToken: json['id_token'] as String,
    );

Map<String, dynamic> _$$GoogleTokenRequestImplToJson(
        _$GoogleTokenRequestImpl instance) =>
    <String, dynamic>{
      'id_token': instance.idToken,
    };

_$AppleTokenRequestImpl _$$AppleTokenRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$AppleTokenRequestImpl(
      identityToken: json['identity_token'] as String,
      nom: json['nom'] as String?,
    );

Map<String, dynamic> _$$AppleTokenRequestImplToJson(
        _$AppleTokenRequestImpl instance) =>
    <String, dynamic>{
      'identity_token': instance.identityToken,
      'nom': instance.nom,
    };

_$TokenResponseImpl _$$TokenResponseImplFromJson(Map<String, dynamic> json) =>
    _$TokenResponseImpl(
      accessToken: json['access_token'] as String,
      role: json['role'] as String,
      boutiqueId: json['boutique_id'] as String?,
      nom: json['nom'] as String,
      email: json['email'] as String?,
    );

Map<String, dynamic> _$$TokenResponseImplToJson(_$TokenResponseImpl instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'role': instance.role,
      'boutique_id': instance.boutiqueId,
      'nom': instance.nom,
      'email': instance.email,
    };
