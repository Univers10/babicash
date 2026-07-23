import 'dart:convert';

/// Personnalisation du reçu de caisse (ticket de vente).
///
/// Persistée en JSON dans le secure storage (voir [ReceiptSettingsStorage]) :
/// infos boutique affichées en en-tête, en-tête libre (slogan / RCCM / NCC),
/// message de pied de page et options d'affichage. Aucune modification du
/// schéma Drift ni du backend — le reçu reste imprimable hors-ligne.
class ReceiptConfig {
  const ReceiptConfig({
    this.nomBoutique = '',
    this.adresse = '',
    this.telephone = '',
    this.entete = '',
    this.piedMessage = defaultPiedMessage,
    this.afficherLogo = true,
    this.afficherVendeur = true,
  });

  /// Message de remerciement par défaut (rétro-compatible avec l'ancien ticket).
  static const String defaultPiedMessage = 'Merci pour votre achat !';

  /// Nom de la boutique affiché en tête du reçu (pré-rempli depuis la boutique).
  final String nomBoutique;

  /// Adresse affichée sous le nom (facultative).
  final String adresse;

  /// Téléphone affiché sous l'adresse (facultatif).
  final String telephone;

  /// En-tête libre multi-lignes : slogan, n° RCCM, NCC… (facultatif).
  final String entete;

  /// Message affiché en bas du reçu (remerciement, politique de retour…).
  final String piedMessage;

  /// Afficher le logo en tête du reçu.
  final bool afficherLogo;

  /// Afficher le nom du vendeur / caissier.
  final bool afficherVendeur;

  ReceiptConfig copyWith({
    String? nomBoutique,
    String? adresse,
    String? telephone,
    String? entete,
    String? piedMessage,
    bool? afficherLogo,
    bool? afficherVendeur,
  }) =>
      ReceiptConfig(
        nomBoutique: nomBoutique ?? this.nomBoutique,
        adresse: adresse ?? this.adresse,
        telephone: telephone ?? this.telephone,
        entete: entete ?? this.entete,
        piedMessage: piedMessage ?? this.piedMessage,
        afficherLogo: afficherLogo ?? this.afficherLogo,
        afficherVendeur: afficherVendeur ?? this.afficherVendeur,
      );

  Map<String, dynamic> toJson() => {
        'nomBoutique': nomBoutique,
        'adresse': adresse,
        'telephone': telephone,
        'entete': entete,
        'piedMessage': piedMessage,
        'afficherLogo': afficherLogo,
        'afficherVendeur': afficherVendeur,
      };

  factory ReceiptConfig.fromJson(Map<String, dynamic> json) => ReceiptConfig(
        nomBoutique: json['nomBoutique'] as String? ?? '',
        adresse: json['adresse'] as String? ?? '',
        telephone: json['telephone'] as String? ?? '',
        entete: json['entete'] as String? ?? '',
        piedMessage: json['piedMessage'] as String? ?? defaultPiedMessage,
        afficherLogo: json['afficherLogo'] as bool? ?? true,
        afficherVendeur: json['afficherVendeur'] as bool? ?? true,
      );

  /// Sérialise en JSON pour persistance.
  String encode() => jsonEncode(toJson());

  /// Décodage tolérant : retourne `null` si [raw] est vide ou mal formé —
  /// jamais d'exception. L'appelant utilise alors la config par défaut.
  static ReceiptConfig? tryDecode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      return ReceiptConfig.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  @override
  bool operator ==(Object other) =>
      other is ReceiptConfig &&
      other.nomBoutique == nomBoutique &&
      other.adresse == adresse &&
      other.telephone == telephone &&
      other.entete == entete &&
      other.piedMessage == piedMessage &&
      other.afficherLogo == afficherLogo &&
      other.afficherVendeur == afficherVendeur;

  @override
  int get hashCode => Object.hash(nomBoutique, adresse, telephone, entete,
      piedMessage, afficherLogo, afficherVendeur);
}
