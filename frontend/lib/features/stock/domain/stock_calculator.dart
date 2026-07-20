/// Types de mouvement de stock.
class TypeMouvementStock {
  static const entree = 'ENTREE';
  static const sortie = 'SORTIE';

  const TypeMouvementStock._();
}

/// Recalcule la quantité d'un produit à partir d'un mouvement de stock.
///
/// - `ENTREE` : le stock augmente de [quantite].
/// - `SORTIE` : le stock diminue de [quantite].
///
/// Lève [ArgumentError] si la quantité n'est pas strictement positive ou si
/// le type de mouvement est inconnu.
int recalculerStock({
  required int stockActuel,
  required String typeMouvement,
  required int quantite,
}) {
  if (quantite <= 0) {
    throw ArgumentError.value(
        quantite, 'quantite', 'La quantité doit être supérieure à zéro');
  }
  switch (typeMouvement) {
    case TypeMouvementStock.entree:
      return stockActuel + quantite;
    case TypeMouvementStock.sortie:
      return stockActuel - quantite;
    default:
      throw ArgumentError.value(
          typeMouvement, 'typeMouvement', 'Type de mouvement inconnu');
  }
}

/// Vrai si une sortie de [quantite] dépasserait le stock disponible.
bool sortieDepasseStock({required int stockActuel, required int quantite}) =>
    quantite > stockActuel;
