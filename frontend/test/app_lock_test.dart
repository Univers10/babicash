import 'package:babicash/core/utils/pin_hasher.dart';
import 'package:babicash/data/models/auth_model.dart';
import 'package:babicash/features/auth/providers/app_lock_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const manager = SessionUser(token: 't', role: 'MANAGER', nom: 'Awa');
  const owner = SessionUser(token: 't', role: 'OWNER', nom: 'Koffi');
  final now = DateTime(2026, 7, 18, 12, 0, 0);

  group('AppLockPolicy.shouldLock — délai de 60 s', () {
    test('verrouille un gérant PIN après plus de 60 s en arrière-plan', () {
      expect(
        AppLockPolicy.shouldLock(
          backgroundedAt: now.subtract(const Duration(seconds: 61)),
          now: now,
          user: manager,
          hasLocalPinHash: true,
        ),
        isTrue,
      );
    });

    test('ne verrouille pas à 60 s pile ou moins', () {
      for (final elapsed in const [
        Duration(seconds: 60),
        Duration(seconds: 59),
        Duration(seconds: 5),
        Duration.zero,
      ]) {
        expect(
          AppLockPolicy.shouldLock(
            backgroundedAt: now.subtract(elapsed),
            now: now,
            user: manager,
            hasLocalPinHash: true,
          ),
          isFalse,
          reason: 'elapsed=$elapsed ne doit pas verrouiller',
        );
      }
    });

    test('verrouille aussi après une très longue absence', () {
      expect(
        AppLockPolicy.shouldLock(
          backgroundedAt: now.subtract(const Duration(hours: 8)),
          now: now,
          user: manager,
          hasLocalPinHash: true,
        ),
        isTrue,
      );
    });

    test('ne verrouille pas sans passage en arrière-plan enregistré', () {
      expect(
        AppLockPolicy.shouldLock(
          backgroundedAt: null,
          now: now,
          user: manager,
          hasLocalPinHash: true,
        ),
        isFalse,
      );
    });
  });

  group('AppLockPolicy.shouldLock — exemptions', () {
    test('un OWNER (email/Google/Apple) n\'est jamais verrouillé', () {
      expect(
        AppLockPolicy.shouldLock(
          backgroundedAt: now.subtract(const Duration(minutes: 30)),
          now: now,
          user: owner,
          hasLocalPinHash: true,
        ),
        isFalse,
      );
    });

    test('aucun verrouillage si personne n\'est connecté (écrans de login, '
        'flux OAuth en Custom Tab)', () {
      expect(
        AppLockPolicy.shouldLock(
          backgroundedAt: now.subtract(const Duration(minutes: 30)),
          now: now,
          user: null,
          hasLocalPinHash: false,
        ),
        isFalse,
      );
    });

    test('pas de verrouillage sans empreinte locale du PIN '
        '(vérification hors ligne impossible)', () {
      expect(
        AppLockPolicy.shouldLock(
          backgroundedAt: now.subtract(const Duration(minutes: 5)),
          now: now,
          user: manager,
          hasLocalPinHash: false,
        ),
        isFalse,
      );
    });
  });

  group('PinHasher — vérification hors ligne du PIN', () {
    test('le bon PIN est accepté', () {
      final stored = PinHasher.hash('1234');
      expect(PinHasher.verify('1234', stored), isTrue);
    });

    test('un mauvais PIN est refusé', () {
      final stored = PinHasher.hash('1234');
      expect(PinHasher.verify('4321', stored), isFalse);
      expect(PinHasher.verify('0000', stored), isFalse);
      expect(PinHasher.verify('', stored), isFalse);
    });

    test('le PIN n\'est jamais stocké en clair', () {
      final stored = PinHasher.hash('1234');
      expect(stored, isNot(contains('1234')));
    });

    test('deux hachages du même PIN diffèrent (sel aléatoire) '
        'mais se vérifient tous les deux', () {
      final a = PinHasher.hash('1234');
      final b = PinHasher.hash('1234');
      expect(a, isNot(equals(b)));
      expect(PinHasher.verify('1234', a), isTrue);
      expect(PinHasher.verify('1234', b), isTrue);
    });

    test('une valeur stockée corrompue est refusée', () {
      expect(PinHasher.verify('1234', ''), isFalse);
      expect(PinHasher.verify('1234', 'pasdeformat'), isFalse);
      expect(PinHasher.verify('1234', ':digestsanssel'), isFalse);
    });
  });
}
