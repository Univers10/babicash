// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) {
  return _LoginRequest.fromJson(json);
}

/// @nodoc
mixin _$LoginRequest {
  String get email => throw _privateConstructorUsedError;
  @JsonKey(name: 'mot_de_passe')
  String get motDePasse => throw _privateConstructorUsedError;

  /// Serializes this LoginRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LoginRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LoginRequestCopyWith<LoginRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoginRequestCopyWith<$Res> {
  factory $LoginRequestCopyWith(
          LoginRequest value, $Res Function(LoginRequest) then) =
      _$LoginRequestCopyWithImpl<$Res, LoginRequest>;
  @useResult
  $Res call({String email, @JsonKey(name: 'mot_de_passe') String motDePasse});
}

/// @nodoc
class _$LoginRequestCopyWithImpl<$Res, $Val extends LoginRequest>
    implements $LoginRequestCopyWith<$Res> {
  _$LoginRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LoginRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? motDePasse = null,
  }) {
    return _then(_value.copyWith(
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      motDePasse: null == motDePasse
          ? _value.motDePasse
          : motDePasse // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LoginRequestImplCopyWith<$Res>
    implements $LoginRequestCopyWith<$Res> {
  factory _$$LoginRequestImplCopyWith(
          _$LoginRequestImpl value, $Res Function(_$LoginRequestImpl) then) =
      __$$LoginRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String email, @JsonKey(name: 'mot_de_passe') String motDePasse});
}

/// @nodoc
class __$$LoginRequestImplCopyWithImpl<$Res>
    extends _$LoginRequestCopyWithImpl<$Res, _$LoginRequestImpl>
    implements _$$LoginRequestImplCopyWith<$Res> {
  __$$LoginRequestImplCopyWithImpl(
      _$LoginRequestImpl _value, $Res Function(_$LoginRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of LoginRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? motDePasse = null,
  }) {
    return _then(_$LoginRequestImpl(
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      motDePasse: null == motDePasse
          ? _value.motDePasse
          : motDePasse // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LoginRequestImpl implements _LoginRequest {
  const _$LoginRequestImpl(
      {required this.email,
      @JsonKey(name: 'mot_de_passe') required this.motDePasse});

  factory _$LoginRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$LoginRequestImplFromJson(json);

  @override
  final String email;
  @override
  @JsonKey(name: 'mot_de_passe')
  final String motDePasse;

  @override
  String toString() {
    return 'LoginRequest(email: $email, motDePasse: $motDePasse)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoginRequestImpl &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.motDePasse, motDePasse) ||
                other.motDePasse == motDePasse));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, email, motDePasse);

  /// Create a copy of LoginRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoginRequestImplCopyWith<_$LoginRequestImpl> get copyWith =>
      __$$LoginRequestImplCopyWithImpl<_$LoginRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LoginRequestImplToJson(
      this,
    );
  }
}

abstract class _LoginRequest implements LoginRequest {
  const factory _LoginRequest(
          {required final String email,
          @JsonKey(name: 'mot_de_passe') required final String motDePasse}) =
      _$LoginRequestImpl;

  factory _LoginRequest.fromJson(Map<String, dynamic> json) =
      _$LoginRequestImpl.fromJson;

  @override
  String get email;
  @override
  @JsonKey(name: 'mot_de_passe')
  String get motDePasse;

  /// Create a copy of LoginRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoginRequestImplCopyWith<_$LoginRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LoginPinRequest _$LoginPinRequestFromJson(Map<String, dynamic> json) {
  return _LoginPinRequest.fromJson(json);
}

/// @nodoc
mixin _$LoginPinRequest {
  String get telephone => throw _privateConstructorUsedError;
  @JsonKey(name: 'code_pin')
  String get codePin => throw _privateConstructorUsedError;

  /// Serializes this LoginPinRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LoginPinRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LoginPinRequestCopyWith<LoginPinRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoginPinRequestCopyWith<$Res> {
  factory $LoginPinRequestCopyWith(
          LoginPinRequest value, $Res Function(LoginPinRequest) then) =
      _$LoginPinRequestCopyWithImpl<$Res, LoginPinRequest>;
  @useResult
  $Res call({String telephone, @JsonKey(name: 'code_pin') String codePin});
}

/// @nodoc
class _$LoginPinRequestCopyWithImpl<$Res, $Val extends LoginPinRequest>
    implements $LoginPinRequestCopyWith<$Res> {
  _$LoginPinRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LoginPinRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? telephone = null,
    Object? codePin = null,
  }) {
    return _then(_value.copyWith(
      telephone: null == telephone
          ? _value.telephone
          : telephone // ignore: cast_nullable_to_non_nullable
              as String,
      codePin: null == codePin
          ? _value.codePin
          : codePin // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LoginPinRequestImplCopyWith<$Res>
    implements $LoginPinRequestCopyWith<$Res> {
  factory _$$LoginPinRequestImplCopyWith(_$LoginPinRequestImpl value,
          $Res Function(_$LoginPinRequestImpl) then) =
      __$$LoginPinRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String telephone, @JsonKey(name: 'code_pin') String codePin});
}

/// @nodoc
class __$$LoginPinRequestImplCopyWithImpl<$Res>
    extends _$LoginPinRequestCopyWithImpl<$Res, _$LoginPinRequestImpl>
    implements _$$LoginPinRequestImplCopyWith<$Res> {
  __$$LoginPinRequestImplCopyWithImpl(
      _$LoginPinRequestImpl _value, $Res Function(_$LoginPinRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of LoginPinRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? telephone = null,
    Object? codePin = null,
  }) {
    return _then(_$LoginPinRequestImpl(
      telephone: null == telephone
          ? _value.telephone
          : telephone // ignore: cast_nullable_to_non_nullable
              as String,
      codePin: null == codePin
          ? _value.codePin
          : codePin // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LoginPinRequestImpl implements _LoginPinRequest {
  const _$LoginPinRequestImpl(
      {required this.telephone,
      @JsonKey(name: 'code_pin') required this.codePin});

  factory _$LoginPinRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$LoginPinRequestImplFromJson(json);

  @override
  final String telephone;
  @override
  @JsonKey(name: 'code_pin')
  final String codePin;

  @override
  String toString() {
    return 'LoginPinRequest(telephone: $telephone, codePin: $codePin)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoginPinRequestImpl &&
            (identical(other.telephone, telephone) ||
                other.telephone == telephone) &&
            (identical(other.codePin, codePin) || other.codePin == codePin));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, telephone, codePin);

  /// Create a copy of LoginPinRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoginPinRequestImplCopyWith<_$LoginPinRequestImpl> get copyWith =>
      __$$LoginPinRequestImplCopyWithImpl<_$LoginPinRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LoginPinRequestImplToJson(
      this,
    );
  }
}

abstract class _LoginPinRequest implements LoginPinRequest {
  const factory _LoginPinRequest(
          {required final String telephone,
          @JsonKey(name: 'code_pin') required final String codePin}) =
      _$LoginPinRequestImpl;

  factory _LoginPinRequest.fromJson(Map<String, dynamic> json) =
      _$LoginPinRequestImpl.fromJson;

  @override
  String get telephone;
  @override
  @JsonKey(name: 'code_pin')
  String get codePin;

  /// Create a copy of LoginPinRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoginPinRequestImplCopyWith<_$LoginPinRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RegisterRequest _$RegisterRequestFromJson(Map<String, dynamic> json) {
  return _RegisterRequest.fromJson(json);
}

/// @nodoc
mixin _$RegisterRequest {
  String get nom => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  @JsonKey(name: 'mot_de_passe')
  String get motDePasse => throw _privateConstructorUsedError;
  String? get telephone => throw _privateConstructorUsedError;

  /// Serializes this RegisterRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RegisterRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RegisterRequestCopyWith<RegisterRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RegisterRequestCopyWith<$Res> {
  factory $RegisterRequestCopyWith(
          RegisterRequest value, $Res Function(RegisterRequest) then) =
      _$RegisterRequestCopyWithImpl<$Res, RegisterRequest>;
  @useResult
  $Res call(
      {String nom,
      String email,
      @JsonKey(name: 'mot_de_passe') String motDePasse,
      String? telephone});
}

/// @nodoc
class _$RegisterRequestCopyWithImpl<$Res, $Val extends RegisterRequest>
    implements $RegisterRequestCopyWith<$Res> {
  _$RegisterRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RegisterRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? nom = null,
    Object? email = null,
    Object? motDePasse = null,
    Object? telephone = freezed,
  }) {
    return _then(_value.copyWith(
      nom: null == nom
          ? _value.nom
          : nom // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      motDePasse: null == motDePasse
          ? _value.motDePasse
          : motDePasse // ignore: cast_nullable_to_non_nullable
              as String,
      telephone: freezed == telephone
          ? _value.telephone
          : telephone // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RegisterRequestImplCopyWith<$Res>
    implements $RegisterRequestCopyWith<$Res> {
  factory _$$RegisterRequestImplCopyWith(_$RegisterRequestImpl value,
          $Res Function(_$RegisterRequestImpl) then) =
      __$$RegisterRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String nom,
      String email,
      @JsonKey(name: 'mot_de_passe') String motDePasse,
      String? telephone});
}

/// @nodoc
class __$$RegisterRequestImplCopyWithImpl<$Res>
    extends _$RegisterRequestCopyWithImpl<$Res, _$RegisterRequestImpl>
    implements _$$RegisterRequestImplCopyWith<$Res> {
  __$$RegisterRequestImplCopyWithImpl(
      _$RegisterRequestImpl _value, $Res Function(_$RegisterRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of RegisterRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? nom = null,
    Object? email = null,
    Object? motDePasse = null,
    Object? telephone = freezed,
  }) {
    return _then(_$RegisterRequestImpl(
      nom: null == nom
          ? _value.nom
          : nom // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      motDePasse: null == motDePasse
          ? _value.motDePasse
          : motDePasse // ignore: cast_nullable_to_non_nullable
              as String,
      telephone: freezed == telephone
          ? _value.telephone
          : telephone // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RegisterRequestImpl implements _RegisterRequest {
  const _$RegisterRequestImpl(
      {required this.nom,
      required this.email,
      @JsonKey(name: 'mot_de_passe') required this.motDePasse,
      this.telephone});

  factory _$RegisterRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$RegisterRequestImplFromJson(json);

  @override
  final String nom;
  @override
  final String email;
  @override
  @JsonKey(name: 'mot_de_passe')
  final String motDePasse;
  @override
  final String? telephone;

  @override
  String toString() {
    return 'RegisterRequest(nom: $nom, email: $email, motDePasse: $motDePasse, telephone: $telephone)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RegisterRequestImpl &&
            (identical(other.nom, nom) || other.nom == nom) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.motDePasse, motDePasse) ||
                other.motDePasse == motDePasse) &&
            (identical(other.telephone, telephone) ||
                other.telephone == telephone));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, nom, email, motDePasse, telephone);

  /// Create a copy of RegisterRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RegisterRequestImplCopyWith<_$RegisterRequestImpl> get copyWith =>
      __$$RegisterRequestImplCopyWithImpl<_$RegisterRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RegisterRequestImplToJson(
      this,
    );
  }
}

abstract class _RegisterRequest implements RegisterRequest {
  const factory _RegisterRequest(
      {required final String nom,
      required final String email,
      @JsonKey(name: 'mot_de_passe') required final String motDePasse,
      final String? telephone}) = _$RegisterRequestImpl;

  factory _RegisterRequest.fromJson(Map<String, dynamic> json) =
      _$RegisterRequestImpl.fromJson;

  @override
  String get nom;
  @override
  String get email;
  @override
  @JsonKey(name: 'mot_de_passe')
  String get motDePasse;
  @override
  String? get telephone;

  /// Create a copy of RegisterRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RegisterRequestImplCopyWith<_$RegisterRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LoginIdRequest _$LoginIdRequestFromJson(Map<String, dynamic> json) {
  return _LoginIdRequest.fromJson(json);
}

/// @nodoc
mixin _$LoginIdRequest {
  @JsonKey(name: 'id_proprietaire')
  String get idProprietaire => throw _privateConstructorUsedError;
  @JsonKey(name: 'mot_de_passe')
  String get motDePasse => throw _privateConstructorUsedError;

  /// Serializes this LoginIdRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LoginIdRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LoginIdRequestCopyWith<LoginIdRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoginIdRequestCopyWith<$Res> {
  factory $LoginIdRequestCopyWith(
          LoginIdRequest value, $Res Function(LoginIdRequest) then) =
      _$LoginIdRequestCopyWithImpl<$Res, LoginIdRequest>;
  @useResult
  $Res call(
      {@JsonKey(name: 'id_proprietaire') String idProprietaire,
      @JsonKey(name: 'mot_de_passe') String motDePasse});
}

/// @nodoc
class _$LoginIdRequestCopyWithImpl<$Res, $Val extends LoginIdRequest>
    implements $LoginIdRequestCopyWith<$Res> {
  _$LoginIdRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LoginIdRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? idProprietaire = null,
    Object? motDePasse = null,
  }) {
    return _then(_value.copyWith(
      idProprietaire: null == idProprietaire
          ? _value.idProprietaire
          : idProprietaire // ignore: cast_nullable_to_non_nullable
              as String,
      motDePasse: null == motDePasse
          ? _value.motDePasse
          : motDePasse // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LoginIdRequestImplCopyWith<$Res>
    implements $LoginIdRequestCopyWith<$Res> {
  factory _$$LoginIdRequestImplCopyWith(_$LoginIdRequestImpl value,
          $Res Function(_$LoginIdRequestImpl) then) =
      __$$LoginIdRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'id_proprietaire') String idProprietaire,
      @JsonKey(name: 'mot_de_passe') String motDePasse});
}

/// @nodoc
class __$$LoginIdRequestImplCopyWithImpl<$Res>
    extends _$LoginIdRequestCopyWithImpl<$Res, _$LoginIdRequestImpl>
    implements _$$LoginIdRequestImplCopyWith<$Res> {
  __$$LoginIdRequestImplCopyWithImpl(
      _$LoginIdRequestImpl _value, $Res Function(_$LoginIdRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of LoginIdRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? idProprietaire = null,
    Object? motDePasse = null,
  }) {
    return _then(_$LoginIdRequestImpl(
      idProprietaire: null == idProprietaire
          ? _value.idProprietaire
          : idProprietaire // ignore: cast_nullable_to_non_nullable
              as String,
      motDePasse: null == motDePasse
          ? _value.motDePasse
          : motDePasse // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LoginIdRequestImpl implements _LoginIdRequest {
  const _$LoginIdRequestImpl(
      {@JsonKey(name: 'id_proprietaire') required this.idProprietaire,
      @JsonKey(name: 'mot_de_passe') required this.motDePasse});

  factory _$LoginIdRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$LoginIdRequestImplFromJson(json);

  @override
  @JsonKey(name: 'id_proprietaire')
  final String idProprietaire;
  @override
  @JsonKey(name: 'mot_de_passe')
  final String motDePasse;

  @override
  String toString() {
    return 'LoginIdRequest(idProprietaire: $idProprietaire, motDePasse: $motDePasse)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoginIdRequestImpl &&
            (identical(other.idProprietaire, idProprietaire) ||
                other.idProprietaire == idProprietaire) &&
            (identical(other.motDePasse, motDePasse) ||
                other.motDePasse == motDePasse));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, idProprietaire, motDePasse);

  /// Create a copy of LoginIdRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoginIdRequestImplCopyWith<_$LoginIdRequestImpl> get copyWith =>
      __$$LoginIdRequestImplCopyWithImpl<_$LoginIdRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LoginIdRequestImplToJson(
      this,
    );
  }
}

abstract class _LoginIdRequest implements LoginIdRequest {
  const factory _LoginIdRequest(
      {@JsonKey(name: 'id_proprietaire') required final String idProprietaire,
      @JsonKey(name: 'mot_de_passe')
      required final String motDePasse}) = _$LoginIdRequestImpl;

  factory _LoginIdRequest.fromJson(Map<String, dynamic> json) =
      _$LoginIdRequestImpl.fromJson;

  @override
  @JsonKey(name: 'id_proprietaire')
  String get idProprietaire;
  @override
  @JsonKey(name: 'mot_de_passe')
  String get motDePasse;

  /// Create a copy of LoginIdRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoginIdRequestImplCopyWith<_$LoginIdRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TokenResponse _$TokenResponseFromJson(Map<String, dynamic> json) {
  return _TokenResponse.fromJson(json);
}

/// @nodoc
mixin _$TokenResponse {
  @JsonKey(name: 'access_token')
  String get accessToken => throw _privateConstructorUsedError;
  String get role => throw _privateConstructorUsedError;
  @JsonKey(name: 'boutique_id')
  String? get boutiqueId => throw _privateConstructorUsedError;
  String get nom => throw _privateConstructorUsedError;

  /// Serializes this TokenResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TokenResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TokenResponseCopyWith<TokenResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TokenResponseCopyWith<$Res> {
  factory $TokenResponseCopyWith(
          TokenResponse value, $Res Function(TokenResponse) then) =
      _$TokenResponseCopyWithImpl<$Res, TokenResponse>;
  @useResult
  $Res call(
      {@JsonKey(name: 'access_token') String accessToken,
      String role,
      @JsonKey(name: 'boutique_id') String? boutiqueId,
      String nom});
}

/// @nodoc
class _$TokenResponseCopyWithImpl<$Res, $Val extends TokenResponse>
    implements $TokenResponseCopyWith<$Res> {
  _$TokenResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TokenResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = null,
    Object? role = null,
    Object? boutiqueId = freezed,
    Object? nom = null,
  }) {
    return _then(_value.copyWith(
      accessToken: null == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      boutiqueId: freezed == boutiqueId
          ? _value.boutiqueId
          : boutiqueId // ignore: cast_nullable_to_non_nullable
              as String?,
      nom: null == nom
          ? _value.nom
          : nom // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TokenResponseImplCopyWith<$Res>
    implements $TokenResponseCopyWith<$Res> {
  factory _$$TokenResponseImplCopyWith(
          _$TokenResponseImpl value, $Res Function(_$TokenResponseImpl) then) =
      __$$TokenResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'access_token') String accessToken,
      String role,
      @JsonKey(name: 'boutique_id') String? boutiqueId,
      String nom});
}

/// @nodoc
class __$$TokenResponseImplCopyWithImpl<$Res>
    extends _$TokenResponseCopyWithImpl<$Res, _$TokenResponseImpl>
    implements _$$TokenResponseImplCopyWith<$Res> {
  __$$TokenResponseImplCopyWithImpl(
      _$TokenResponseImpl _value, $Res Function(_$TokenResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of TokenResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = null,
    Object? role = null,
    Object? boutiqueId = freezed,
    Object? nom = null,
  }) {
    return _then(_$TokenResponseImpl(
      accessToken: null == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      boutiqueId: freezed == boutiqueId
          ? _value.boutiqueId
          : boutiqueId // ignore: cast_nullable_to_non_nullable
              as String?,
      nom: null == nom
          ? _value.nom
          : nom // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TokenResponseImpl implements _TokenResponse {
  const _$TokenResponseImpl(
      {@JsonKey(name: 'access_token') required this.accessToken,
      required this.role,
      @JsonKey(name: 'boutique_id') this.boutiqueId,
      required this.nom});

  factory _$TokenResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$TokenResponseImplFromJson(json);

  @override
  @JsonKey(name: 'access_token')
  final String accessToken;
  @override
  final String role;
  @override
  @JsonKey(name: 'boutique_id')
  final String? boutiqueId;
  @override
  final String nom;

  @override
  String toString() {
    return 'TokenResponse(accessToken: $accessToken, role: $role, boutiqueId: $boutiqueId, nom: $nom)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TokenResponseImpl &&
            (identical(other.accessToken, accessToken) ||
                other.accessToken == accessToken) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.boutiqueId, boutiqueId) ||
                other.boutiqueId == boutiqueId) &&
            (identical(other.nom, nom) || other.nom == nom));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, accessToken, role, boutiqueId, nom);

  /// Create a copy of TokenResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TokenResponseImplCopyWith<_$TokenResponseImpl> get copyWith =>
      __$$TokenResponseImplCopyWithImpl<_$TokenResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TokenResponseImplToJson(
      this,
    );
  }
}

abstract class _TokenResponse implements TokenResponse {
  const factory _TokenResponse(
      {@JsonKey(name: 'access_token') required final String accessToken,
      required final String role,
      @JsonKey(name: 'boutique_id') final String? boutiqueId,
      required final String nom}) = _$TokenResponseImpl;

  factory _TokenResponse.fromJson(Map<String, dynamic> json) =
      _$TokenResponseImpl.fromJson;

  @override
  @JsonKey(name: 'access_token')
  String get accessToken;
  @override
  String get role;
  @override
  @JsonKey(name: 'boutique_id')
  String? get boutiqueId;
  @override
  String get nom;

  /// Create a copy of TokenResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TokenResponseImplCopyWith<_$TokenResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$SessionUser {
  String get token => throw _privateConstructorUsedError;
  String get role => throw _privateConstructorUsedError;
  String get nom => throw _privateConstructorUsedError;
  String? get boutiqueId => throw _privateConstructorUsedError;

  /// Create a copy of SessionUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SessionUserCopyWith<SessionUser> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SessionUserCopyWith<$Res> {
  factory $SessionUserCopyWith(
          SessionUser value, $Res Function(SessionUser) then) =
      _$SessionUserCopyWithImpl<$Res, SessionUser>;
  @useResult
  $Res call({String token, String role, String nom, String? boutiqueId});
}

/// @nodoc
class _$SessionUserCopyWithImpl<$Res, $Val extends SessionUser>
    implements $SessionUserCopyWith<$Res> {
  _$SessionUserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SessionUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? token = null,
    Object? role = null,
    Object? nom = null,
    Object? boutiqueId = freezed,
  }) {
    return _then(_value.copyWith(
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      nom: null == nom
          ? _value.nom
          : nom // ignore: cast_nullable_to_non_nullable
              as String,
      boutiqueId: freezed == boutiqueId
          ? _value.boutiqueId
          : boutiqueId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SessionUserImplCopyWith<$Res>
    implements $SessionUserCopyWith<$Res> {
  factory _$$SessionUserImplCopyWith(
          _$SessionUserImpl value, $Res Function(_$SessionUserImpl) then) =
      __$$SessionUserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String token, String role, String nom, String? boutiqueId});
}

/// @nodoc
class __$$SessionUserImplCopyWithImpl<$Res>
    extends _$SessionUserCopyWithImpl<$Res, _$SessionUserImpl>
    implements _$$SessionUserImplCopyWith<$Res> {
  __$$SessionUserImplCopyWithImpl(
      _$SessionUserImpl _value, $Res Function(_$SessionUserImpl) _then)
      : super(_value, _then);

  /// Create a copy of SessionUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? token = null,
    Object? role = null,
    Object? nom = null,
    Object? boutiqueId = freezed,
  }) {
    return _then(_$SessionUserImpl(
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      nom: null == nom
          ? _value.nom
          : nom // ignore: cast_nullable_to_non_nullable
              as String,
      boutiqueId: freezed == boutiqueId
          ? _value.boutiqueId
          : boutiqueId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$SessionUserImpl extends _SessionUser {
  const _$SessionUserImpl(
      {required this.token,
      required this.role,
      required this.nom,
      this.boutiqueId})
      : super._();

  @override
  final String token;
  @override
  final String role;
  @override
  final String nom;
  @override
  final String? boutiqueId;

  @override
  String toString() {
    return 'SessionUser(token: $token, role: $role, nom: $nom, boutiqueId: $boutiqueId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SessionUserImpl &&
            (identical(other.token, token) || other.token == token) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.nom, nom) || other.nom == nom) &&
            (identical(other.boutiqueId, boutiqueId) ||
                other.boutiqueId == boutiqueId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, token, role, nom, boutiqueId);

  /// Create a copy of SessionUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SessionUserImplCopyWith<_$SessionUserImpl> get copyWith =>
      __$$SessionUserImplCopyWithImpl<_$SessionUserImpl>(this, _$identity);
}

abstract class _SessionUser extends SessionUser {
  const factory _SessionUser(
      {required final String token,
      required final String role,
      required final String nom,
      final String? boutiqueId}) = _$SessionUserImpl;
  const _SessionUser._() : super._();

  @override
  String get token;
  @override
  String get role;
  @override
  String get nom;
  @override
  String? get boutiqueId;

  /// Create a copy of SessionUser
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SessionUserImplCopyWith<_$SessionUserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
