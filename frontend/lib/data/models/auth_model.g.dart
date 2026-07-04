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

_$TokenResponseImpl _$$TokenResponseImplFromJson(Map<String, dynamic> json) =>
    _$TokenResponseImpl(
      accessToken: json['access_token'] as String,
      role: json['role'] as String,
      boutiqueId: json['boutique_id'] as String?,
      nom: json['nom'] as String,
    );

Map<String, dynamic> _$$TokenResponseImplToJson(_$TokenResponseImpl instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'role': instance.role,
      'boutique_id': instance.boutiqueId,
      'nom': instance.nom,
    };
