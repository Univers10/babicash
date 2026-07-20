import 'package:babicash/data/local/database.dart';
import 'package:babicash/features/stock/providers/stock_provider.dart';
import 'package:babicash/features/stock/widgets/produit_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final categories = [
    const LocalCategory(id: 'c1', boutiqueId: 'b1', nom: 'Boissons'),
    const LocalCategory(id: 'c2', boutiqueId: 'b1', nom: 'Épices'),
  ];

  final produit = LocalProduit(
    id: 'p1',
    boutiqueId: 'b1',
    categorieId: 'c2',
    nom: 'Piment séché',
    prixAchatMoyen: 100,
    prixVenteSuggere: 150,
    stockActuel: 8,
    stockAlerte: 5,
    updatedAt: DateTime(2026, 1, 1),
  );

  Widget wrap(Widget child) => ProviderScope(
        overrides: [
          categoriesProvider.overrideWith((ref) async => categories),
        ],
        child: MaterialApp(home: Scaffold(body: child)),
      );

  testWidgets(
      'édition : la catégorie actuelle du produit est présélectionnée (P3)',
      (tester) async {
    await tester.pumpWidget(wrap(ProduitFormDialog(produit: produit)));
    await tester.pumpAndSettle();

    expect(find.text('Modifier produit'), findsOneWidget);
    // Le champ catégorie affiche la catégorie du produit, pas
    // « Sans catégorie ».
    expect(find.text('Épices'), findsOneWidget);
    expect(find.text('Sans catégorie'), findsNothing);
  });

  testWidgets('création : « Sans catégorie » par défaut', (tester) async {
    await tester.pumpWidget(wrap(const ProduitFormDialog()));
    await tester.pumpAndSettle();

    expect(find.text('Nouveau produit'), findsOneWidget);
    expect(find.text('Sans catégorie'), findsOneWidget);
  });
}
