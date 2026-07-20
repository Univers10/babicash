import 'package:babicash/core/utils/text_normalizer.dart';
import 'package:babicash/data/local/database.dart';
import 'package:babicash/shared/utils/categorie_utils.dart';
import 'package:flutter_test/flutter_test.dart';

LocalCategory cat(String id, String nom) =>
    LocalCategory(id: id, boutiqueId: 'b1', nom: nom);

LocalProduit prod(String id, String nom, {String? categorieId}) => LocalProduit(
      id: id,
      boutiqueId: 'b1',
      categorieId: categorieId,
      nom: nom,
      prixAchatMoyen: 100,
      prixVenteSuggere: 150,
      stockActuel: 10,
      stockAlerte: 5,
      updatedAt: DateTime(2026, 1, 1),
    );

void main() {
  group('normaliserTexte', () {
    test('met en minuscules et retire les accents', () {
      expect(normaliserTexte('Épices'), 'epices');
      expect(normaliserTexte('  Bière  '), 'biere');
      expect(normaliserTexte('Çà et là'), 'ca et la');
      expect(normaliserTexte('Œufs'), 'oeufs');
    });
  });

  group('comparerSansAccents', () {
    test('ignore casse et accents', () {
      expect(comparerSansAccents('épices', 'EPICES'), 0);
      expect(comparerSansAccents('École', 'Zèbre') < 0, isTrue);
      expect(comparerSansAccents('banane', 'Ananas') > 0, isTrue);
    });
  });

  group('trierCategories (P2)', () {
    test('trie alphabétiquement, insensible à la casse et aux accents', () {
      final categories = [
        cat('1', 'Épices'),
        cat('2', 'boissons'),
        cat('3', 'Alimentaire'),
        cat('4', 'école'),
        cat('5', 'Divers'),
      ];
      final triees = trierCategories(categories);
      expect(triees.map((c) => c.nom).toList(),
          ['Alimentaire', 'boissons', 'Divers', 'école', 'Épices']);
    });

    test('ne modifie pas la liste d\'origine', () {
      final categories = [cat('1', 'Zèbre'), cat('2', 'Ananas')];
      trierCategories(categories);
      expect(categories.first.nom, 'Zèbre');
    });
  });

  group('grouperProduitsParCategorie (P5)', () {
    final categories = [
      cat('c2', 'Épices'),
      cat('c1', 'Boissons'),
    ];

    test('groupes triés alphabétiquement, « Sans catégorie » en dernier', () {
      final produits = [
        prod('p1', 'Piment', categorieId: 'c2'),
        prod('p2', 'Coca', categorieId: 'c1'),
        prod('p3', 'Sachet', categorieId: null),
        prod('p4', 'Fanta', categorieId: 'c1'),
      ];
      final groupes = grouperProduitsParCategorie(produits, categories);

      expect(groupes.map((g) => g.nom).toList(),
          ['Boissons', 'Épices', sansCategorieLabel]);
      expect(groupes.last.estSansCategorie, isTrue);
      expect(groupes.last.produits.map((p) => p.nom), ['Sachet']);
      expect(groupes.first.produits.map((p) => p.nom), ['Coca', 'Fanta']);
    });

    test('categorieId inconnu (catégorie supprimée) va dans « Sans catégorie »',
        () {
      final produits = [
        prod('p1', 'Orphelin', categorieId: 'c-supprimee'),
        prod('p2', 'Coca', categorieId: 'c1'),
      ];
      final groupes = grouperProduitsParCategorie(produits, categories);

      expect(groupes.map((g) => g.nom).toList(),
          ['Boissons', sansCategorieLabel]);
      expect(groupes.last.produits.single.nom, 'Orphelin');
    });

    test('pas de groupe pour les catégories vides ni « Sans catégorie » vide',
        () {
      final produits = [prod('p1', 'Coca', categorieId: 'c1')];
      final groupes = grouperProduitsParCategorie(produits, categories);

      expect(groupes.map((g) => g.nom).toList(), ['Boissons']);
    });

    test('liste vide → aucun groupe', () {
      expect(grouperProduitsParCategorie([], categories), isEmpty);
    });
  });

  group('estProduitSansCategorie', () {
    final categories = [cat('c1', 'Boissons')];

    test('null ou id inconnu → vrai, id connu → faux', () {
      expect(estProduitSansCategorie(prod('p1', 'A'), categories), isTrue);
      expect(
          estProduitSansCategorie(
              prod('p2', 'B', categorieId: 'inconnu'), categories),
          isTrue);
      expect(
          estProduitSansCategorie(
              prod('p3', 'C', categorieId: 'c1'), categories),
          isFalse);
    });
  });
}
