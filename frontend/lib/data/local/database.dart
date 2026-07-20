import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

// ── Tables ────────────────────────────────────────────────────────────────────

class LocalProduits extends Table {
  TextColumn get id => text()();
  TextColumn get boutiqueId => text()();
  TextColumn get categorieId => text().nullable()();
  TextColumn get nom => text()();
  RealColumn get prixAchatMoyen => real().withDefault(const Constant(0))();
  RealColumn get prixVenteSuggere => real().withDefault(const Constant(0))();
  IntColumn get stockActuel => integer().withDefault(const Constant(0))();
  IntColumn get stockAlerte => integer().withDefault(const Constant(5))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalCategories extends Table {
  TextColumn get id => text()();
  TextColumn get boutiqueId => text()();
  TextColumn get nom => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalVentes extends Table {
  TextColumn get idLocal => text()();
  TextColumn get boutiqueId => text()();
  TextColumn get sessionId => text().nullable()();
  TextColumn get tierId => text().nullable()();
  TextColumn get modePaiement => text()();
  RealColumn get montantTotal => real().withDefault(const Constant(0))();
  DateTimeColumn get dateVente => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  TextColumn get serverVenteId => text().nullable()();

  @override
  Set<Column> get primaryKey => {idLocal};
}

class LocalLignesVente extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get venteIdLocal => text().references(LocalVentes, #idLocal, onDelete: KeyAction.cascade)();
  TextColumn get produitId => text().nullable()();
  IntColumn get quantite => integer().withDefault(const Constant(1))();
  RealColumn get prixVenduReel => real()();
  RealColumn get margeCalculee => real().withDefault(const Constant(0))();
  // Lot (prix de groupe) : lignes vendues ensemble à un prix négocié réparti.
  // null = ligne normale (toutes les ventes existantes).
  TextColumn get lotId => text().nullable()();
  TextColumn get lotNom => text().nullable()();
}

class LocalDepenses extends Table {
  TextColumn get idLocal => text()();
  TextColumn get boutiqueId => text()();
  TextColumn get sessionId => text().nullable()();
  RealColumn get montant => real()();
  TextColumn get motif => text()();
  DateTimeColumn get dateTransaction => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {idLocal};
}

class LocalSessions extends Table {
  TextColumn get id => text()();
  TextColumn get boutiqueId => text()();
  TextColumn get utilisateurNom => text()();
  DateTimeColumn get dateOuverture => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get dateFermeture => dateTime().nullable()();
  RealColumn get montantInitial => real().withDefault(const Constant(0))();
  RealColumn get montantFinalDeclare => real().nullable()();
  TextColumn get statut => text().withDefault(const Constant('OUVERT'))();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalTiers extends Table {
  TextColumn get id => text()();
  TextColumn get boutiqueId => text()();
  TextColumn get nom => text()();
  TextColumn get telephone => text().nullable()();
  TextColumn get typeTiers => text()();
  RealColumn get soldeDu => real().withDefault(const Constant(0))();
  BoolColumn get synced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Journal des mouvements de stock (entrées / sorties manuelles).
class LocalMouvementsStock extends Table {
  TextColumn get id => text()(); // UUID généré localement
  TextColumn get boutiqueId => text()();
  TextColumn get produitId => text()();
  TextColumn get produitNom => text().withDefault(const Constant(''))();
  TextColumn get typeMouvement => text()(); // ENTREE | SORTIE
  IntColumn get quantite => integer()();
  TextColumn get motif => text()();
  TextColumn get auteurId => text().nullable()();
  TextColumn get auteurNom => text()();
  DateTimeColumn get dateMouvement => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ── Database ──────────────────────────────────────────────────────────────────

@DriftDatabase(tables: [
  LocalProduits,
  LocalCategories,
  LocalVentes,
  LocalLignesVente,
  LocalDepenses,
  LocalSessions,
  LocalTiers,
  LocalMouvementsStock,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // v2 : journal des mouvements de stock
            await m.createTable(localMouvementsStock);
          }
          if (from < 3) {
            // v3 : lot (prix de groupe) — colonnes additives nullable,
            // les ventes locales existantes gardent lot_id/lot_nom = null.
            await m.addColumn(localLignesVente, localLignesVente.lotId);
            await m.addColumn(localLignesVente, localLignesVente.lotNom);
          }
        },
      );

  // ── Produits ──────────────────────────────────────────────────────────────

  Future<List<LocalProduit>> getProduitsByBoutique(String boutiqueId) =>
      (select(localProduits)..where((p) => p.boutiqueId.equals(boutiqueId)))
          .get();

  /// Stream réactif : l'UI stock reflète toujours l'état local (S1).
  Stream<List<LocalProduit>> watchProduitsByBoutique(String boutiqueId) =>
      (select(localProduits)
            ..where((p) => p.boutiqueId.equals(boutiqueId))
            ..orderBy([(p) => OrderingTerm.asc(p.nom)]))
          .watch();

  Future<void> upsertProduit(LocalProduitsCompanion produit) =>
      into(localProduits).insertOnConflictUpdate(produit);

  Future<void> upsertAllProduits(List<LocalProduitsCompanion> produits) =>
      batch((b) => b.insertAllOnConflictUpdate(localProduits, produits));

  // ── Catégories ────────────────────────────────────────────────────────────

  Future<List<LocalCategory>> getCategoriesByBoutique(String boutiqueId) =>
      (select(localCategories)..where((c) => c.boutiqueId.equals(boutiqueId)))
          .get();

  Future<void> upsertAllCategories(List<LocalCategoriesCompanion> cats) =>
      batch((b) => b.insertAllOnConflictUpdate(localCategories, cats));

  // ── Ventes non synchronisées ──────────────────────────────────────────────

  Future<List<LocalVente>> getVentesNonSync(String boutiqueId) =>
      (select(localVentes)
            ..where((v) => v.boutiqueId.equals(boutiqueId) & v.synced.equals(false)))
          .get();

  Future<void> insertVente(LocalVentesCompanion vente) =>
      into(localVentes).insert(vente);

  Future<void> insertLigneVente(LocalLignesVenteCompanion ligne) =>
      into(localLignesVente).insert(ligne);

  Future<List<LocalLignesVenteData>> getLignesByVente(String idLocal) =>
      (select(localLignesVente)
            ..where((l) => l.venteIdLocal.equals(idLocal)))
          .get();

  Future<void> deleteVente(String idLocal) async {
    await (delete(localLignesVente)..where((l) => l.venteIdLocal.equals(idLocal))).go();
    await (delete(localVentes)..where((v) => v.idLocal.equals(idLocal))).go();
  }

  Future<void> marquerVenteSync(String idLocal, String serverVenteId) =>
      (update(localVentes)..where((v) => v.idLocal.equals(idLocal)))
          .write(LocalVentesCompanion(
            synced: const Value(true),
            serverVenteId: Value(serverVenteId),
          ));

  // ── Dépenses non synchronisées ────────────────────────────────────────────

  Future<List<LocalDepense>> getDepensesNonSync(String boutiqueId) =>
      (select(localDepenses)
            ..where((d) => d.boutiqueId.equals(boutiqueId) & d.synced.equals(false)))
          .get();

  Future<void> insertDepense(LocalDepensesCompanion depense) =>
      into(localDepenses).insert(depense);

  Future<void> marquerDepenseSync(String idLocal) =>
      (update(localDepenses)..where((d) => d.idLocal.equals(idLocal)))
          .write(const LocalDepensesCompanion(synced: Value(true)));

  // ── Sessions ──────────────────────────────────────────────────────────────

  Future<LocalSession?> getSessionOuverte(String boutiqueId) =>
      (select(localSessions)
            ..where((s) =>
                s.boutiqueId.equals(boutiqueId) &
                s.statut.equals('OUVERT')))
          .getSingleOrNull();

  Future<void> upsertSession(LocalSessionsCompanion session) =>
      into(localSessions).insertOnConflictUpdate(session);

  // ── Mouvements de stock ───────────────────────────────────────────────────

  /// Stream du journal des mouvements, plus récents d'abord.
  Stream<List<LocalMouvementsStockData>> watchMouvementsByBoutique(
          String boutiqueId) =>
      (select(localMouvementsStock)
            ..where((m) => m.boutiqueId.equals(boutiqueId))
            ..orderBy([(m) => OrderingTerm.desc(m.dateMouvement)]))
          .watch();

  Future<List<LocalMouvementsStockData>> getMouvementsNonSync(
          String boutiqueId) =>
      (select(localMouvementsStock)
            ..where((m) =>
                m.boutiqueId.equals(boutiqueId) & m.synced.equals(false)))
          .get();

  Future<void> insertMouvementStock(LocalMouvementsStockCompanion mouvement) =>
      into(localMouvementsStock).insert(mouvement);

  Future<void> marquerMouvementSync(String id) =>
      (update(localMouvementsStock)..where((m) => m.id.equals(id)))
          .write(const LocalMouvementsStockCompanion(synced: Value(true)));

  /// Applique un mouvement de manière atomique : insertion dans le journal
  /// (`synced = false`) + recalcul du stock du produit (offline-first).
  Future<void> appliquerMouvementStock({
    required LocalMouvementsStockCompanion mouvement,
    required String produitId,
    required int nouveauStock,
  }) =>
      transaction(() async {
        await into(localMouvementsStock).insert(mouvement);
        await (update(localProduits)..where((p) => p.id.equals(produitId)))
            .write(LocalProduitsCompanion(stockActuel: Value(nouveauStock)));
      });

  // ── Tiers ────────────────────────────────────────────────────────────────

  Future<List<LocalTier>> getTiersByBoutique(String boutiqueId, {String? type}) {
    final q = select(localTiers)..where((t) => t.boutiqueId.equals(boutiqueId));
    if (type != null) q.where((t) => t.typeTiers.equals(type));
    return q.get();
  }

  Future<void> upsertTier(LocalTiersCompanion tier) =>
      into(localTiers).insertOnConflictUpdate(tier);
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'babicash.db'));
    // TODO(H9): Chiffrer la DB avec sqlcipher_flutter
    // Pour l'instant, la DB est en clair.
    // Pour activer le chiffrement, remplacer par :
    //   final factory = sqlcipherFactory(password: encryptionKey);
    //   return SqfliteDatabaseFactory.inDatabaseFactory(factory).openDatabase(file.path);
    return NativeDatabase.createInBackground(file);
  });
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
