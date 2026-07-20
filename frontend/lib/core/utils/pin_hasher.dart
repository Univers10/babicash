import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Hachage local du code PIN — permet de vérifier le PIN HORS LIGNE
/// (écran de verrouillage) sans jamais stocker le PIN en clair.
///
/// Format stocké : `salt:digest` où `digest = sha256^n(salt + pin)`.
/// Le sel est aléatoire et régénéré à chaque login PIN réussi ; les
/// itérations ralentissent une éventuelle attaque par force brute sur
/// l'espace réduit des PIN à 4 chiffres.
abstract final class PinHasher {
  static const int _iterations = 10000;
  static final Random _random = Random.secure();

  /// Hache [pin] avec un sel aléatoire (ou [salt] fourni, pour les tests).
  static String hash(String pin, {String? salt}) {
    final s = salt ?? _generateSalt();
    return '$s:${_digest(pin, s)}';
  }

  /// Vérifie [pin] contre une valeur produite par [hash].
  static bool verify(String pin, String stored) {
    final sep = stored.indexOf(':');
    if (sep <= 0) return false;
    final salt = stored.substring(0, sep);
    final expected = stored.substring(sep + 1);
    return _constantTimeEquals(_digest(pin, salt), expected);
  }

  static String _digest(String pin, String salt) {
    List<int> bytes = utf8.encode('$salt$pin');
    for (var i = 0; i < _iterations; i++) {
      bytes = sha256.convert(bytes).bytes;
    }
    return base64Url.encode(bytes);
  }

  static String _generateSalt() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    return base64Url.encode(bytes);
  }

  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }
}
