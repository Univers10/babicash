import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/app_exception.dart';
import '../../../data/local/database.dart';
import '../../../data/models/session_model.dart';
import '../../../data/remote/sessions_api.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/boutiques/providers/boutique_provider.dart';
import '../services/session_rapport_service.dart';

/// Session active depuis le backend, sinon cache local.
final sessionActiveProvider = FutureProvider<LocalSession?>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final user = ref.watch(authStateProvider).value;
  final boutiqueId = await ref.watch(currentBoutiqueIdProvider.future);
  if (user == null || boutiqueId == null) return null;

  final connectivity = await Connectivity().checkConnectivity();
  if (!connectivity.contains(ConnectivityResult.none)) {
    try {
      final api = ref.watch(sessionsApiProvider);
      final resume = await api.sessionActive(boutiqueId);
      if (resume != null) {
        await db.upsertSession(LocalSessionsCompanion(
          id: drift.Value(resume.session.id),
          boutiqueId: drift.Value(resume.session.boutiqueId),
          utilisateurNom: drift.Value(resume.session.utilisateurNom),
          dateOuverture: drift.Value(resume.session.dateOuverture),
          montantInitial: drift.Value(resume.session.montantInitial),
          statut: drift.Value(resume.session.statut),
          synced: const drift.Value(true),
        ));
      } else {
        // Aucune session ouverte sur le serveur : fermer la locale si elle est ouverte.
        final local = await db.getSessionOuverte(boutiqueId);
        if (local != null) {
          await (db.update(db.localSessions)
                ..where((s) => s.id.equals(local.id)))
              .write(LocalSessionsCompanion(
            statut: const drift.Value('FERME'),
            dateFermeture: drift.Value(DateTime.now()),
            synced: const drift.Value(true),
          ));
        }
      }
    } on AppException {
      // Fallback local silencieux
    }
  }

  return db.getSessionOuverte(boutiqueId);
});

/// Liste des sessions locales (historique).
final sessionsHistoryProvider = FutureProvider<List<LocalSession>>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final boutiqueId = await ref.watch(currentBoutiqueIdProvider.future);
  if (boutiqueId == null) return [];
  return (db.select(db.localSessions)
        ..where((s) => s.boutiqueId.equals(boutiqueId))
        ..orderBy([
          (s) => drift.OrderingTerm(
              expression: s.dateOuverture, mode: drift.OrderingMode.desc)
        ]))
      .get();
});

/// Sessions fermées de la boutique courante, la plus récente en premier.
final sessionsFermeesProvider = FutureProvider<List<LocalSession>>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final boutiqueId = await ref.watch(currentBoutiqueIdProvider.future);
  if (boutiqueId == null) return [];
  return (db.select(db.localSessions)
        ..where((s) =>
            s.boutiqueId.equals(boutiqueId) & s.statut.equals('FERME'))
        ..orderBy([
          (s) => drift.OrderingTerm(
              expression: s.dateOuverture, mode: drift.OrderingMode.desc)
        ]))
      .get();
});

/// Total des ventes locales par session (sessionId → montant cumulé).
final ventesTotauxParSessionProvider =
    FutureProvider<Map<String, double>>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final boutiqueId = await ref.watch(currentBoutiqueIdProvider.future);
  if (boutiqueId == null) return {};
  final ventes = await (db.select(db.localVentes)
        ..where((v) =>
            v.boutiqueId.equals(boutiqueId) & v.sessionId.isNotNull()))
      .get();
  final totaux = <String, double>{};
  for (final v in ventes) {
    totaux[v.sessionId!] = (totaux[v.sessionId!] ?? 0) + v.montantTotal;
  }
  return totaux;
});

/// Détail complet d'une session : rapport calculé + ventes rattachées.
class SessionDetail {
  const SessionDetail({
    required this.session,
    required this.rapport,
    required this.ventes,
    required this.depenses,
    required this.clientNoms,
  });

  final LocalSession session;
  final SessionRapport rapport;

  /// Ventes de la session, la plus récente en premier.
  final List<LocalVente> ventes;
  final List<LocalDepense> depenses;

  /// tierId → nom du client (pour affichage).
  final Map<String, String> clientNoms;
}

/// Charge une session locale et régénère son rapport depuis Drift.
final sessionDetailProvider =
    FutureProvider.family<SessionDetail?, String>((ref, sessionId) async {
  final db = ref.watch(appDatabaseProvider);
  final boutiqueId = await ref.watch(currentBoutiqueIdProvider.future);
  if (boutiqueId == null) return null;

  final session = await (db.select(db.localSessions)
        ..where((s) =>
            s.id.equals(sessionId) & s.boutiqueId.equals(boutiqueId)))
      .getSingleOrNull();
  if (session == null) return null;

  final ventes = await (db.select(db.localVentes)
        ..where((v) =>
            v.boutiqueId.equals(boutiqueId) & v.sessionId.equals(sessionId))
        ..orderBy([
          (v) => drift.OrderingTerm(
              expression: v.dateVente, mode: drift.OrderingMode.desc)
        ]))
      .get();

  final depenses = await (db.select(db.localDepenses)
        ..where((d) =>
            d.boutiqueId.equals(boutiqueId) & d.sessionId.equals(sessionId)))
      .get();

  final tiers = await db.getTiersByBoutique(boutiqueId);
  final clientNoms = {for (final t in tiers) t.id: t.nom};

  return SessionDetail(
    session: session,
    rapport: SessionRapport.compute(
      session: session,
      ventes: ventes,
      depenses: depenses,
    ),
    ventes: ventes,
    depenses: depenses,
    clientNoms: clientNoms,
  );
});

class SessionNotifier extends AsyncNotifier<LocalSession?> {
  @override
  Future<LocalSession?> build() async {
    return ref.watch(sessionActiveProvider.future);
  }

  Future<bool> ouvrir(double montantInitial) async {
    final user = ref.read(authStateProvider).value;
    final boutiqueId = await ref.read(currentBoutiqueIdProvider.future);
    if (user == null || boutiqueId == null) return false;
    final db = ref.read(appDatabaseProvider);

    try {
      final api = ref.read(sessionsApiProvider);
      final session = await api.ouvrirSession(SessionOuvrirRequest(
        boutiqueId: boutiqueId,
        montantInitial: montantInitial,
      ));

      await db.upsertSession(LocalSessionsCompanion(
        id: drift.Value(session.id),
        boutiqueId: drift.Value(session.boutiqueId),
        utilisateurNom: drift.Value(session.utilisateurNom),
        dateOuverture: drift.Value(session.dateOuverture),
        montantInitial: drift.Value(session.montantInitial),
        statut: drift.Value(session.statut),
        synced: const drift.Value(true),
      ));

      ref.invalidate(sessionActiveProvider);
      return true;
    } on AppException {
      return false;
    }
  }

  Future<SessionResumeModel?> fermer(double montantFinal) async {
    final session = state.value;
    if (session == null) return null;

    try {
      final api = ref.read(sessionsApiProvider);
      final resume = await api.fermerSession(
        session.id,
        SessionFermerRequest(montantFinalDeclare: montantFinal),
      );

      final db = ref.read(appDatabaseProvider);
      await (db.update(db.localSessions)
            ..where((s) => s.id.equals(session.id)))
          .write(LocalSessionsCompanion(
        dateFermeture: drift.Value(resume.session.dateFermeture ?? DateTime.now()),
        montantFinalDeclare: drift.Value(resume.session.montantFinalDeclare),
        statut: const drift.Value('FERME'),
        synced: const drift.Value(true),
      ));

      ref.invalidate(sessionActiveProvider);
      return resume;
    } on AppException {
      return null;
    }
  }
}

final sessionNotifierProvider =
    AsyncNotifierProvider<SessionNotifier, LocalSession?>(SessionNotifier.new);
