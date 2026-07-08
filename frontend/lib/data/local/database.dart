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

// ── Database ──────────────────────────────────────────────────────────────────

@DriftDatabase(tables: [
  LocalProduits,
  LocalCategories,
  LocalVentes,
  LocalLignesVente,
  LocalDepenses,
  LocalSessions,
  LocalTiers,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // ── Produits ──────────────────────────────────────────────────────────────

  Future<List<LocalProduit>> getProduitsByBoutique(String boutiqueId) =>
      (select(localProduits)..where((p) => p.boutiqueId.equals(boutiqueId)))
          .get();

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
    return NativeDatabase.createInBackground(file);
  });
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
