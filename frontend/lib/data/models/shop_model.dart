/// DTO du catalogue boutique renvoyé par `GET /api/v1/shop/produits`.
class ShopApiProduit {
  const ShopApiProduit({
    required this.id,
    required this.nom,
    required this.description,
    required this.tagline,
    required this.prix,
    required this.categorie,
    required this.icone,
    required this.specs,
    required this.stock,
    required this.enVente,
    required this.isNew,
    required this.isPopulaire,
    this.ancienPrix,
  });

  final String id;
  final String nom;
  final String description;
  final String tagline;
  final double prix;
  final double? ancienPrix;
  final String categorie;
  final String icone;
  final List<String> specs;
  final int stock;
  final bool enVente;
  final bool isNew;
  final bool isPopulaire;

  factory ShopApiProduit.fromJson(Map<String, dynamic> json) {
    return ShopApiProduit(
      id: json['id'] as String? ?? '',
      nom: json['nom'] as String? ?? '',
      description: json['description'] as String? ?? '',
      tagline: json['tagline'] as String? ?? '',
      prix: (json['prix'] as num? ?? 0).toDouble(),
      ancienPrix: (json['ancien_prix'] as num?)?.toDouble(),
      categorie: json['categorie'] as String? ?? 'ACCESSOIRES',
      icone: json['icone'] as String? ?? 'print',
      specs: (json['specs'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      stock: json['stock'] as int? ?? 0,
      enVente: json['en_vente'] as bool? ?? true,
      isNew: json['is_new'] as bool? ?? false,
      isPopulaire: json['is_populaire'] as bool? ?? false,
    );
  }
}