import 'package:dio_certificate_pinner/dio_certificate_pinner.dart';

/// Configuration du certificate pinning pour BabiCash.
///
/// Les empreintes SHA-256 sont utilisées pour valider le certificat SSL
/// du serveur lors de chaque connexion réseau.
///
/// **IMPORTANT**: Lors du renouvellement du certificat SSL (Let's Encrypt),
/// il faudra mettre à jour ces empreintes avec le nouveau certificat.
class BabiCashCertificatePinning {
  BabiCashCertificatePinning._();

  /// Hostname du serveur API
  static const String apiHost = 'babicash.ecomotionafricaci.com';

  /// Empreintes SHA-256 des certificats autorisés.
  ///
  /// Format: `sha256/XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX=`
  ///
  /// La première empreinte est le certificat principal.
  /// Les suivantes sont des backups (chaîne de certification).
  static const List<String> pinnedCertificates = [
    // Certificat principal - Let's Encrypt (valide jusqu'au 08/10/2026)
    'sha256/8809EB8129A32832A3D4343C369C40C1967A12F4C35B846E502369ED9F8AD5C3',
  ];

  /// Crée l'instance CertificatePinner pour Dio
  static CertificatePinner createPinner() {
    return CertificatePinner(
      certificates: [
        pinnedCertificates,
      ],
    );
  }
}
