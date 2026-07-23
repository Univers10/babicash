import 'package:babicash/features/settings/models/receipt_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReceiptConfig', () {
    test('valeurs par défaut : logo + vendeur visibles, message par défaut', () {
      const config = ReceiptConfig();
      expect(config.nomBoutique, '');
      expect(config.adresse, '');
      expect(config.telephone, '');
      expect(config.entete, '');
      expect(config.piedMessage, ReceiptConfig.defaultPiedMessage);
      expect(config.afficherLogo, isTrue);
      expect(config.afficherVendeur, isTrue);
    });

    test('encode/decode : round-trip complet', () {
      const config = ReceiptConfig(
        nomBoutique: 'Chez Awa',
        adresse: 'Cocody, Abidjan',
        telephone: '+225 07 00 00 00 00',
        entete: 'RCCM: CI-ABJ-2024-B-1234\n« Qualité & prix bas »',
        piedMessage: 'Merci de votre visite !',
        afficherLogo: false,
        afficherVendeur: false,
      );

      final decoded = ReceiptConfig.tryDecode(config.encode());

      expect(decoded, isNotNull);
      expect(decoded, equals(config));
      expect(decoded!.afficherLogo, isFalse);
      expect(decoded.afficherVendeur, isFalse);
    });

    test('tryDecode : null/vide/corrompu → null (jamais d\'exception)', () {
      expect(ReceiptConfig.tryDecode(null), isNull);
      expect(ReceiptConfig.tryDecode(''), isNull);
      expect(ReceiptConfig.tryDecode('{pas du json'), isNull);
      expect(ReceiptConfig.tryDecode('[1,2,3]'), isNull);
    });

    test('fromJson : champs manquants → valeurs par défaut', () {
      final decoded = ReceiptConfig.tryDecode('{"nomBoutique":"X"}');
      expect(decoded, isNotNull);
      expect(decoded!.nomBoutique, 'X');
      expect(decoded.piedMessage, ReceiptConfig.defaultPiedMessage);
      expect(decoded.afficherLogo, isTrue);
      expect(decoded.afficherVendeur, isTrue);
    });

    test('copyWith : ne modifie que le champ ciblé', () {
      const base = ReceiptConfig(nomBoutique: 'A', afficherLogo: true);
      final updated = base.copyWith(afficherLogo: false);
      expect(updated.nomBoutique, 'A');
      expect(updated.afficherLogo, isFalse);
      expect(updated.afficherVendeur, isTrue);
    });
  });
}
