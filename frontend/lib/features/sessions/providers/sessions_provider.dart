import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/app_exception.dart';
import '../../../data/local/database.dart';
import '../../../data/models/session_model.dart';
import '../../../data/remote/sessions_api.dart';
import '../../../features/auth/providers/auth_provider.dart';

/// Session active depuis le backend, sinon cache local.
final sessionActiveProvider = FutureProvider<LocalSession?>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final user = ref.watch(authStateProvider).value;
  if (user?.boutiqueId == null) return null;
  final boutiqueId = user!.boutiqueId!;

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
  final user = ref.watch(authStateProvider).value;
  if (user?.boutiqueId == null) return [];
  return (db.select(db.localSessions)
        ..where((s) => s.boutiqueId.equals(user!.boutiqueId!))
        ..orderBy([
          (s) => OrderingTerm(
              expression: s.dateOuverture, mode: OrderingMode.desc)
        ]))
      .get();
});

class SessionNotifier extends AsyncNotifier<LocalSession?> {
  @override
  Future<LocalSession?> build() async {
    return ref.watch(sessionActiveProvider.future);
  }

  Future<bool> ouvrir(double montantInitial) async {
    final user = ref.read(authStateProvider).value;
    if (user?.boutiqueId == null) return false;
    final boutiqueId = user!.boutiqueId!;
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

  Future<bool> fermer(double montantFinal) async {
    final session = state.value;
    if (session == null) return false;

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
      return true;
    } on AppException {
      return false;
    }
  }
}

final sessionNotifierProvider =
    AsyncNotifierProvider<SessionNotifier, LocalSession?>(SessionNotifier.new);
