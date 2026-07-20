import '../../core/utils/text_normalizer.dart';
import '../../data/local/database.dart';

/// Libellé du groupe virtuel des produits sans catégorie.
/// Ce groupe n'existe JAMAIS en base : c'est un regroupement d'affichage
/// des produits dont `categorieId == null` (ou pointe vers une catégorie
/// supprimée).
const String sansCategorieLabel = 'Sans catégorie';

/// Retourne une copie de [categories] triée par ordre alphabétique,
/// insensible à la casse et aux accents.
List<LocalCategory> trierCategories(List<LocalCategory> categories) {
  final triees = [...categories];
  triees.sort((a, b) => comparerSansAccents(a.nom, b.nom));
  return triees;
}

/// Groupe de produits affiché sous un en-tête de catégorie.
/// [categorie] vaut `null` pour le groupe virtuel « Sans catégorie ».
class GroupeProduits {
  const GroupeProduits({this.categorie, required this.produits});

  final LocalCategory? categorie;
  final List<LocalProduit> produits;

  String get nom => categorie?.nom ?? sansCategorieLabel;
  bool get estSansCategorie => categorie == null;
}

/// Groupe [produits] par catégorie :
/// - les catégories sont triées alphabétiquement (casse/accents ignorés) ;
/// - les catégories sans produit ne produisent pas de groupe ;
/// - les produits avec `categorieId == null` ou pointant vers une catégorie
///   inconnue forment le groupe virtuel « Sans catégorie », toujours dernier.
List<GroupeProduits> grouperProduitsParCategorie(
  List<LocalProduit> produits,
  List<LocalCategory> categories,
) {
  final idsConnus = {for (final c in categories) c.id};
  final parCategorie = <String?, List<LocalProduit>>{};
  for (final p in produits) {
    final id = p.categorieId;
    final cle = (id != null && idsConnus.contains(id)) ? id : null;
    parCategorie.putIfAbsent(cle, () => []).add(p);
  }

  return [
    for (final c in trierCategories(categories))
      if (parCategorie.containsKey(c.id))
        GroupeProduits(categorie: c, produits: parCategorie[c.id]!),
    if (parCategorie.containsKey(null))
      GroupeProduits(produits: parCategorie[null]!),
  ];
}

/// Vrai si [produit] appartient au groupe virtuel « Sans catégorie »
/// pour l'ensemble de catégories connues [categories].
bool estProduitSansCategorie(
  LocalProduit produit,
  List<LocalCategory> categories,
) {
  final id = produit.categorieId;
  return id == null || !categories.any((c) => c.id == id);
}
