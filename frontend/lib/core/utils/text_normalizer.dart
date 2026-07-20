/// Normalisation de texte pour les tris et recherches insensibles
/// à la casse et aux accents (français).
library;

const Map<String, String> _diacritiques = {
  'à': 'a', 'â': 'a', 'ä': 'a', 'á': 'a', 'ã': 'a', 'å': 'a',
  'ç': 'c',
  'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e',
  'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i',
  'ñ': 'n',
  'ò': 'o', 'ó': 'o', 'ô': 'o', 'ö': 'o', 'õ': 'o',
  'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u',
  'ý': 'y', 'ÿ': 'y',
  'œ': 'oe', 'æ': 'ae',
};

/// Retourne [texte] en minuscules, sans accents et sans espaces
/// de début/fin — clé de tri et de recherche.
String normaliserTexte(String texte) {
  final minuscules = texte.trim().toLowerCase();
  final buffer = StringBuffer();
  for (final rune in minuscules.runes) {
    final char = String.fromCharCode(rune);
    buffer.write(_diacritiques[char] ?? char);
  }
  return buffer.toString();
}

/// Comparaison alphabétique insensible à la casse et aux accents.
/// Deux textes qui ne diffèrent que par la casse ou les accents sont
/// considérés égaux (retourne 0).
int comparerSansAccents(String a, String b) =>
    normaliserTexte(a).compareTo(normaliserTexte(b));
