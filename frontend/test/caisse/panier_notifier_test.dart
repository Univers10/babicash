import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:babicash/data/local/database.dart';
import 'package:babicash/features/caisse/providers/caisse_provider.dart';

LocalProduit _produit(String id, {String nom = 'Produit', double prix = 700}) {
  return LocalProduit(
    id: id,
    boutiqueId: 'b1',
    nom: nom,
    prixAchatMoyen: prix / 2,
    prixVenteSuggere: prix,
    stockActuel: 10,
    stockAlerte: 2,
    updatedAt: DateTime(2026, 1, 1),
  );
}

void main() {
  late ProviderContainer container;
  late PanierNotifier notifier;

  setUp(() {
    container = ProviderContainer();
    notifier = container.read(panierProvider.notifier);
  });

  tearDown(() => container.dispose());

  group('PanierNotifier — ajout (base du badge C3)', () {
    test('addProduit deux fois regroupe sur une seule ligne avec quantite 2',
        () {
      notifier.addProduit(_produit('p1', nom: 'Biere'));
      notifier.addProduit(_produit('p1', nom: 'Biere'));

      final panier = container.read(panierProvider);
      expect(panier.length, 1);
      expect(panier.first.quantite, 2);
      expect(panier.first.produitId, 'p1');
    });

    test('quantites par produit agregees pour le badge du catalogue', () {
      notifier.addProduit(_produit('p1'));
      notifier.addProduit(_produit('p1'));
      notifier.addProduit(_produit('p2'));
      notifier.addLibre(500); // article libre sans produitId → pas de badge

      // Même agrégation que CatalogueGrid pour le badge quantité (C3)
      final panier = container.read(panierProvider);
      final qteAuPanier = <String, int>{};
      for (final item in panier) {
        final id = item.produitId;
        if (id != null) {
          qteAuPanier[id] = (qteAuPanier[id] ?? 0) + item.quantite;
        }
      }

      expect(qteAuPanier, {'p1': 2, 'p2': 1});
    });
  });

  group('PanierNotifier — retrait ligne par ligne (C1)', () {
    test('updateQuantite decremente une seule ligne sans toucher les autres',
        () {
      notifier.addProduit(_produit('p1'));
      notifier.addProduit(_produit('p1'));
      notifier.addProduit(_produit('p2'));

      notifier.updateQuantite(0, 1); // p1 : 2 → 1

      final panier = container.read(panierProvider);
      expect(panier.length, 2);
      expect(panier[0].produitId, 'p1');
      expect(panier[0].quantite, 1);
      expect(panier[1].produitId, 'p2');
      expect(panier[1].quantite, 1);
    });

    test('decrementer jusqu\'a 0 supprime la ligne', () {
      notifier.addProduit(_produit('p1'));
      notifier.addProduit(_produit('p2'));

      notifier.updateQuantite(0, 0); // p1 : 1 → 0 → ligne supprimée

      final panier = container.read(panierProvider);
      expect(panier.length, 1);
      expect(panier.first.produitId, 'p2');
    });

    test('remove supprime uniquement la ligne visee', () {
      notifier.addProduit(_produit('p1'));
      notifier.addProduit(_produit('p2'));
      notifier.addProduit(_produit('p3'));

      notifier.remove(1); // supprime p2

      final panier = container.read(panierProvider);
      expect(panier.map((i) => i.produitId), ['p1', 'p3']);
    });

    test('clear vide tout le panier', () {
      notifier.addProduit(_produit('p1'));
      notifier.addProduit(_produit('p2'));

      notifier.clear();

      expect(container.read(panierProvider), isEmpty);
    });
  });
}
