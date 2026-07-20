import 'dart:convert';

/// Imprimante thermique Bluetooth mémorisée par l'utilisateur.
///
/// Persistée en JSON dans le secure storage (voir
/// `PrinterSettingsStorage`) : nom lisible + adresse MAC.
class SavedPrinter {
  const SavedPrinter({required this.name, required this.address});

  /// Nom lisible de l'imprimante (ex. « MTP-2 »).
  final String name;

  /// Adresse MAC Bluetooth (identifiant de connexion).
  final String address;

  factory SavedPrinter.fromJson(Map<String, dynamic> json) => SavedPrinter(
        name: json['name'] as String? ?? 'Imprimante',
        address: json['address'] as String,
      );

  Map<String, dynamic> toJson() => {'name': name, 'address': address};

  /// Sérialise en JSON pour persistance.
  String encode() => jsonEncode(toJson());

  /// Décodage tolérant : retourne `null` si [raw] est vide, mal formé
  /// ou sans adresse — jamais d'exception.
  static SavedPrinter? tryDecode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      final address = decoded['address'];
      if (address is! String || address.isEmpty) return null;
      return SavedPrinter.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  @override
  bool operator ==(Object other) =>
      other is SavedPrinter && other.name == name && other.address == address;

  @override
  int get hashCode => Object.hash(name, address);

  @override
  String toString() => 'SavedPrinter($name, $address)';
}
