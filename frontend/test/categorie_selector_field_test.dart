import 'package:babicash/data/local/database.dart';
import 'package:babicash/features/stock/widgets/categorie_selector_field.dart';
import 'package:babicash/shared/utils/categorie_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

LocalCategory cat(String id, String nom) =>
    LocalCategory(id: id, boutiqueId: 'b1', nom: nom);

Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  final categories = [
    cat('c1', 'Boissons'),
    cat('c2', 'Épices'),
    cat('c3', 'Savons'),
  ];

  testWidgets('affiche la catégorie sélectionnée (P3)', (tester) async {
    await tester.pumpWidget(wrap(CategorieSelectorField(
      categories: categories,
      selectedId: 'c2',
      onChanged: (_) {},
    )));
    expect(find.text('Épices'), findsOneWidget);
  });

  testWidgets('affiche « Sans catégorie » quand selectedId est null',
      (tester) async {
    await tester.pumpWidget(wrap(CategorieSelectorField(
      categories: categories,
      selectedId: null,
      onChanged: (_) {},
    )));
    expect(find.text(sansCategorieLabel), findsOneWidget);
  });

  testWidgets('la recherche filtre la liste, insensible aux accents (P4)',
      (tester) async {
    await tester.pumpWidget(wrap(CategorieSelectorField(
      categories: categories,
      selectedId: null,
      onChanged: (_) {},
    )));

    // Ouvre la feuille de sélection.
    await tester.tap(find.byType(CategorieSelectorField));
    await tester.pumpAndSettle();
    expect(find.text('Boissons'), findsOneWidget);
    expect(find.text('Épices'), findsOneWidget);
    expect(find.text('Savons'), findsOneWidget);

    // « epice » (sans accent, minuscule) doit matcher « Épices ».
    await tester.enterText(
        find.widgetWithText(TextField, 'Rechercher une catégorie...'), 'epice');
    await tester.pumpAndSettle();
    expect(find.text('Épices'), findsOneWidget);
    expect(find.text('Boissons'), findsNothing);
    expect(find.text('Savons'), findsNothing);
  });

  testWidgets('sélectionner une catégorie renvoie son id', (tester) async {
    String? changedTo = 'sentinelle';
    await tester.pumpWidget(wrap(CategorieSelectorField(
      categories: categories,
      selectedId: null,
      onChanged: (v) => changedTo = v,
    )));

    await tester.tap(find.byType(CategorieSelectorField));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Savons'));
    await tester.pumpAndSettle();

    expect(changedTo, 'c3');
  });

  testWidgets('sélectionner « Sans catégorie » renvoie null', (tester) async {
    String? changedTo = 'sentinelle';
    await tester.pumpWidget(wrap(CategorieSelectorField(
      categories: categories,
      selectedId: 'c1',
      onChanged: (v) => changedTo = v,
    )));

    await tester.tap(find.byType(CategorieSelectorField));
    await tester.pumpAndSettle();
    // Le libellé apparaît dans la feuille (une seule occurrence dans la liste).
    await tester.tap(find.text(sansCategorieLabel).last);
    await tester.pumpAndSettle();

    expect(changedTo, isNull);
  });
}
