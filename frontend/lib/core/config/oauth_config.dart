/// Identifiants OAuth pour la connexion sociale.
///
/// Google : le [googleServerClientId] est le Client ID **Web** créé dans la
/// Google Cloud Console (pas le client Android). C'est aussi la valeur de
/// GOOGLE_CLIENT_ID côté backend — le `aud` du token émis correspond au
/// client Web.
///
/// Apple : le [appleServiceId] est un "Services ID" créé dans le portail
/// Apple Developer avec "Sign in with Apple" activé, configuré avec le
/// domaine et la [appleRedirectUri] exacte (flux web, pas d'app iOS).
class OAuthConfig {
  OAuthConfig._();

  // Client ID Web de la Google Cloud Console (projet BabiCash).
  // Doit rester identique à GOOGLE_CLIENT_ID côté backend.
  static const googleServerClientId =
      '888445557233-ec33fb0s4jgnvbi9f13vfkhp6vq250q3.apps.googleusercontent.com';

  // TODO: remplacer par le Services ID du portail Apple Developer.
  static const appleServiceId = 'com.babicash.app.signin';

  static final appleRedirectUri = Uri.parse(
    'https://babicash.ecomotionafricaci.com/api/v1/auth/oauth/apple/callback',
  );

  static bool get googleConfigured =>
      !googleServerClientId.startsWith('REMPLACER-MOI');
}
