import '../models/panier_item.dart';

/// Une ligne de vente résolue à partir d'un lot : produit réel, quantité,
/// prix unitaire réparti et prix d'achat (pour la marge).
class LigneResolue {
  const LigneResolue({
    required this.produitId,
    required this.quantite,
    required this.prixVenduReel,
    required this.prixAchat,
  });

  final String? produitId;
  final int quantite;
  final double prixVenduReel; // prix unitaire en francs (2 décimales)
  final double prixAchat;

  double get margeTotale => (prixVenduReel - prixAchat) * quantite;
}

/// Répartit un [total] entier sur des parts pondérées par [poids], par la
/// **méthode du plus fort reste** (Hamilton) : la somme des valeurs rendues
/// vaut *exactement* [total], sans biais systématique.
///
/// Travaille en unités entières (centimes) pour garantir l'exactitude.
List<int> repartirHamilton(List<int> poids, int total) {
  final n = poids.length;
  if (n == 0) return const [];
  final sommePoids = poids.fold<int>(0, (s, p) => s + p);

  // Poids tous nuls (ex. articles libres à 0) → répartition égale.
  final effectifs = sommePoids == 0 ? List<int>.filled(n, 1) : poids;
  final sommeEff = sommePoids == 0 ? n : sommePoids;

  final base = List<int>.filled(n, 0);
  // Reste fractionnaire de chaque part, en numérateur sur sommeEff.
  final restes = List<int>.filled(n, 0);
  var attribue = 0;
  for (var i = 0; i < n; i++) {
    final produit = effectifs[i] * total;
    base[i] = produit ~/ sommeEff;
    restes[i] = produit % sommeEff;
    attribue += base[i];
  }

  var reste = total - attribue; // francs/centimes encore à distribuer
  // Indices triés par plus fort reste fractionnaire (départage déterministe
  // par index croissant) : on ajoute 1 à chacun jusqu'à épuisement du reste.
  final ordre = List<int>.generate(n, (i) => i)
    ..sort((a, b) {
      final cmp = restes[b].compareTo(restes[a]);
      return cmp != 0 ? cmp : a.compareTo(b);
    });
  for (var k = 0; k < reste; k++) {
    base[ordre[k % n]] += 1;
  }
  return base;
}

// Le FCFA (XOF) n'a pas de subdivision : on répartit en francs entiers.
int _franc(double montant) => montant.round();

/// Résout un ensemble d'articles groupés en lot à [prixTotalLot] : chaque
/// unité reçoit une part du prix (répartie au prorata du prix unitaire), puis
/// les unités d'un même produit au même prix sont regroupées en une ligne.
///
/// Le stock se décrémente par produit réel et la somme des lignes vaut
/// exactement [prixTotalLot] — aucun pseudo-produit « kit ».
List<LigneResolue> resoudreLignesLot(
  List<PanierItem> itemsDuLot,
  double prixTotalLot,
) {
  // 1. Expansion en unités (une part par unité), en gardant produit + achat.
  final poids = <int>[];
  final produits = <String?>[];
  final achats = <double>[];
  for (final item in itemsDuLot) {
    for (var q = 0; q < item.quantite; q++) {
      poids.add(_franc(item.prixUnitaire));
      produits.add(item.produitId);
      achats.add(item.prixAchat);
    }
  }
  if (poids.isEmpty) return const [];

  // 2. Répartition exacte au franc.
  final parts = repartirHamilton(poids, _franc(prixTotalLot));

  // 3. Regroupement (produit, prix) en lignes, dans l'ordre d'apparition.
  final lignes = <LigneResolue>[];
  for (var i = 0; i < parts.length; i++) {
    final prix = parts[i].toDouble();
    final pid = produits[i];
    final idx = lignes.indexWhere(
      (l) => l.produitId == pid && l.prixVenduReel == prix,
    );
    if (idx >= 0) {
      final l = lignes[idx];
      lignes[idx] = LigneResolue(
        produitId: l.produitId,
        quantite: l.quantite + 1,
        prixVenduReel: l.prixVenduReel,
        prixAchat: l.prixAchat,
      );
    } else {
      lignes.add(LigneResolue(
        produitId: pid,
        quantite: 1,
        prixVenduReel: prix,
        prixAchat: achats[i],
      ));
    }
  }
  return lignes;
}
