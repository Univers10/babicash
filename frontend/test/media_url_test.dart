import 'package:babicash/shared/images/media_url.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('origine dérivée de la base API', () {
    // Reproduit la logique de apiOriginProvider (Uri.origin) sans Riverpod.
    String originOf(String base) => Uri.parse(base).origin;

    test('prod : /api/v1 retiré, pas de query/fragment parasite', () {
      expect(originOf('https://pos.babicash.ci/api/v1'),
          'https://pos.babicash.ci');
    });

    test('dev LAN : port conservé', () {
      expect(originOf('http://192.168.1.29:8000/api/v1'),
          'http://192.168.1.29:8000');
    });

    test('émulateur Android : port conservé', () {
      expect(originOf('http://10.0.2.2:8000/api/v1'), 'http://10.0.2.2:8000');
    });
  });

  group('absoluteMediaUrl', () {
    const origin = 'https://pos.babicash.ci';

    test('URL relative /static → absolue', () {
      expect(
        absoluteMediaUrl(origin, '/static/uploads/produits/abc.jpg'),
        'https://pos.babicash.ci/static/uploads/produits/abc.jpg',
      );
    });

    test('chemin sans slash initial → slash ajouté', () {
      expect(absoluteMediaUrl(origin, 'static/x.jpg'),
          'https://pos.babicash.ci/static/x.jpg');
    });

    test('URL déjà absolue → inchangée', () {
      const abs = 'https://cdn.example.com/x.jpg';
      expect(absoluteMediaUrl(origin, abs), abs);
    });

    test('null ou vide → chaîne vide', () {
      expect(absoluteMediaUrl(origin, null), '');
      expect(absoluteMediaUrl(origin, ''), '');
      expect(absoluteMediaUrl(origin, '   '), '');
    });

    test('ne produit jamais d\'origine cassée (?#)', () {
      final result = absoluteMediaUrl(origin, '/static/x.jpg');
      expect(result.contains('?#'), isFalse);
    });
  });
}
