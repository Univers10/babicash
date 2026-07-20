import 'package:flutter_test/flutter_test.dart';

import 'package:babicash/features/stock/domain/stock_calculator.dart';

void main() {
  group('recalculerStock', () {
    test('une entrée augmente le stock', () {
      expect(
        recalculerStock(
          stockActuel: 10,
          typeMouvement: TypeMouvementStock.entree,
          quantite: 5,
        ),
        15,
      );
    });

    test('une sortie diminue le stock', () {
      expect(
        recalculerStock(
          stockActuel: 10,
          typeMouvement: TypeMouvementStock.sortie,
          quantite: 4,
        ),
        6,
      );
    });

    test('une sortie peut rendre le stock négatif (garde-fou côté UI)', () {
      expect(
        recalculerStock(
          stockActuel: 3,
          typeMouvement: TypeMouvementStock.sortie,
          quantite: 5,
        ),
        -2,
      );
    });

    test('quantité nulle ou négative rejetée', () {
      expect(
        () => recalculerStock(
          stockActuel: 10,
          typeMouvement: TypeMouvementStock.entree,
          quantite: 0,
        ),
        throwsArgumentError,
      );
      expect(
        () => recalculerStock(
          stockActuel: 10,
          typeMouvement: TypeMouvementStock.entree,
          quantite: -3,
        ),
        throwsArgumentError,
      );
    });

    test('type de mouvement inconnu rejeté', () {
      expect(
        () => recalculerStock(
          stockActuel: 10,
          typeMouvement: 'AJUSTEMENT',
          quantite: 2,
        ),
        throwsArgumentError,
      );
    });
  });

  group('sortieDepasseStock', () {
    test('vrai quand la quantité dépasse le stock', () {
      expect(sortieDepasseStock(stockActuel: 5, quantite: 6), isTrue);
    });

    test('faux quand la quantité est disponible', () {
      expect(sortieDepasseStock(stockActuel: 5, quantite: 5), isFalse);
      expect(sortieDepasseStock(stockActuel: 5, quantite: 2), isFalse);
    });
  });
}
