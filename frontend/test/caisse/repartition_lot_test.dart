import 'package:babicash/features/caisse/domain/repartition_lot.dart';
import 'package:babicash/features/caisse/models/panier_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('repartirHamilton', () {
    test('la somme vaut exactement le total', () {
      final r = repartirHamilton([700, 700, 700], 2000);
      expect(r.fold<int>(0, (s, x) => s + x), 2000);
    });

    test('cas maquis homogène → 667 / 667 / 666', () {
      final r = repartirHamilton([700, 700, 700], 2000);
      expect(r, [667, 667, 666]);
    });

    test('répartition au prorata des poids', () {
      // 2 unités à 700 + 1 à 1000, total 2200 (naturel 2400).
      final r = repartirHamilton([700, 700, 1000], 2200);
      expect(r.fold<int>(0, (s, x) => s + x), 2200);
      // La part de la premium reste la plus élevée.
      expect(r[2] > r[0], isTrue);
    });

    test('poids nuls → répartition égale exacte', () {
      final r = repartirHamilton([0, 0, 0], 1000);
      expect(r.fold<int>(0, (s, x) => s + x), 1000);
      expect(r, [334, 333, 333]);
    });

    test('liste vide → vide', () {
      expect(repartirHamilton([], 1000), isEmpty);
    });
  });

  group('resoudreLignesLot', () {
    PanierItem item(String id, double prix, int qte) => PanierItem(
          produitId: id,
          nom: id,
          prixUnitaire: prix,
          prixAchat: 400,
          quantite: qte,
        );

    test('maquis : 2 Flag + 1 Castel à 700, lot 2000', () {
      final lignes = resoudreLignesLot(
        [item('flag', 700, 2), item('castel', 700, 1)],
        2000,
      );
      final total = lignes.fold<double>(
          0, (s, l) => s + l.prixVenduReel * l.quantite);
      expect(total, 2000);
      // Décrément de stock correct : 2 Flag + 1 Castel.
      final qFlag = lignes
          .where((l) => l.produitId == 'flag')
          .fold<int>(0, (s, l) => s + l.quantite);
      final qCastel = lignes
          .where((l) => l.produitId == 'castel')
          .fold<int>(0, (s, l) => s + l.quantite);
      expect(qFlag, 2);
      expect(qCastel, 1);
    });

    test('la somme des lignes vaut toujours exactement le prix du lot', () {
      final lignes = resoudreLignesLot(
        [item('a', 700, 1), item('b', 1000, 1), item('c', 500, 2)],
        2500,
      );
      final total = lignes.fold<double>(
          0, (s, l) => s + l.prixVenduReel * l.quantite);
      expect(total, 2500);
    });

    test('unités de même prix regroupées en une ligne', () {
      final lignes = resoudreLignesLot([item('flag', 700, 3)], 2100);
      // 3 unités identiques au même prix → une seule ligne quantité 3.
      expect(lignes.length, 1);
      expect(lignes.first.quantite, 3);
      expect(lignes.first.prixVenduReel, 700);
    });
  });
}
