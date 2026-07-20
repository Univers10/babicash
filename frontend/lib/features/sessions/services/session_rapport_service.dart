import 'package:intl/intl.dart';
import '../../../data/local/database.dart';

/// Rapport de session calculé à partir des données locales (Drift).
///
/// Toutes les valeurs sont dérivées de `LocalSessions`, `LocalVentes`
/// et `LocalDepenses` — aucune dépendance réseau.
class SessionRapport {
  const SessionRapport({
    required this.session,
    required this.nbVentes,
    required this.totalVentes,
    required this.totalEspeces,
    required this.totalMobile,
    required this.totalCredit,
    required this.totalDepenses,
    required this.montantTheorique,
    this.ecart,
  });

  final LocalSession session;
  final int nbVentes;
  final double totalVentes;
  final double totalEspeces;
  final double totalMobile;
  final double totalCredit;
  final double totalDepenses;

  /// Fond théorique en caisse : fond initial + ventes espèces − dépenses.
  final double montantTheorique;

  /// Écart = fond déclaré − fond théorique. `null` si aucun fond déclaré.
  final double? ecart;

  /// Calcule le rapport à partir des enregistrements locaux.
  ///
  /// Seules les ventes/dépenses rattachées à [session] (même `sessionId`)
  /// sont prises en compte — le filtrage par boutique est fait en amont
  /// par les requêtes Drift.
  static SessionRapport compute({
    required LocalSession session,
    required List<LocalVente> ventes,
    required List<LocalDepense> depenses,
  }) {
    final ventesSession =
        ventes.where((v) => v.sessionId == session.id).toList();
    final depensesSession =
        depenses.where((d) => d.sessionId == session.id).toList();

    double sumMode(String mode) => ventesSession
        .where((v) => v.modePaiement == mode)
        .fold(0.0, (s, v) => s + v.montantTotal);

    final totalEspeces = sumMode('ESPECES');
    final totalMobile = sumMode('MOBILE_MONEY');
    final totalCredit = sumMode('CREDIT');
    final totalVentes =
        ventesSession.fold(0.0, (s, v) => s + v.montantTotal);
    final totalDepenses =
        depensesSession.fold(0.0, (s, d) => s + d.montant);

    final montantTheorique =
        session.montantInitial + totalEspeces - totalDepenses;
    final ecart = session.montantFinalDeclare == null
        ? null
        : session.montantFinalDeclare! - montantTheorique;

    return SessionRapport(
      session: session,
      nbVentes: ventesSession.length,
      totalVentes: totalVentes,
      totalEspeces: totalEspeces,
      totalMobile: totalMobile,
      totalCredit: totalCredit,
      totalDepenses: totalDepenses,
      montantTheorique: montantTheorique,
      ecart: ecart,
    );
  }
}

/// Génère les lignes texte du rapport pour l'imprimante thermique (58 mm).
List<String> buildRapportLines(
  SessionRapport rapport, {
  String nomBoutique = 'BabiCash',
  int width = 32,
}) {
  final fmt = DateFormat('dd/MM/yyyy HH:mm');
  final s = rapport.session;

  String center(String text) {
    if (text.length >= width) return text;
    final pad = (width - text.length) ~/ 2;
    return '${' ' * pad}$text';
  }

  String lr(String left, String right) {
    final spaces = width - left.length - right.length;
    return spaces > 0 ? left + ' ' * spaces + right : '$left $right';
  }

  String fcfa(double montant) =>
      '${montant.round()} F';

  final lines = <String>[
    center(nomBoutique),
    center('RAPPORT DE SESSION'),
    '',
    lr('Caissier', s.utilisateurNom),
    lr('Ouverture', fmt.format(s.dateOuverture.toLocal())),
    if (s.dateFermeture != null)
      lr('Fermeture', fmt.format(s.dateFermeture!.toLocal())),
    '-' * width,
    lr('Nb ventes', '${rapport.nbVentes}'),
    lr('Ventes especes', fcfa(rapport.totalEspeces)),
    lr('Ventes mobile', fcfa(rapport.totalMobile)),
    lr('Ventes credit', fcfa(rapport.totalCredit)),
    lr('Total ventes', fcfa(rapport.totalVentes)),
    lr('Depenses', fcfa(rapport.totalDepenses)),
    '-' * width,
    lr('Fond initial', fcfa(s.montantInitial)),
    if (s.montantFinalDeclare != null)
      lr('Fond declare', fcfa(s.montantFinalDeclare!)),
    lr('Theorique caisse', fcfa(rapport.montantTheorique)),
    '=' * width,
    if (rapport.ecart != null)
      lr('ECART',
          '${rapport.ecart! >= 0 ? '+' : ''}${fcfa(rapport.ecart!)}'),
    '=' * width,
  ];
  return lines;
}
