import 'package:babicash/data/local/database.dart';
import 'package:babicash/features/settings/models/receipt_config.dart';
import 'package:babicash/features/settings/services/receipt_settings_storage.dart';
import 'package:babicash/features/settings/services/recu_config_api.dart';
import 'package:babicash/features/settings/services/recu_config_repository.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

const _boutiqueId = 'boutique-1';

/// API factice : n'effectue aucun appel réseau, enregistre les appels [put]
/// et renvoie une config serveur programmable.
class _FakeRecuConfigApi extends RecuConfigApi {
  _FakeRecuConfigApi() : super(Dio());

  RemoteRecuConfig? remote;
  final List<ReceiptConfig> putCalls = [];

  @override
  Future<RemoteRecuConfig?> get(String boutiqueId) async => remote;

  @override
  Future<RemoteRecuConfig> put(String boutiqueId, ReceiptConfig config) async {
    putCalls.add(config);
    final saved = (config: config, updatedAt: DateTime(2026, 7, 23));
    remote = saved;
    return saved;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late _FakeRecuConfigApi api;
  late RecuConfigRepository repo;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    db = AppDatabase.forTesting(NativeDatabase.memory());
    api = _FakeRecuConfigApi();
    repo = RecuConfigRepository(
      db: db,
      api: api,
      legacyStorage: const ReceiptSettingsStorage(FlutterSecureStorage()),
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('load : config par défaut quand rien en base', () async {
    final config = await repo.load(_boutiqueId);
    expect(config, const ReceiptConfig());
    expect(await db.getRecuConfig(_boutiqueId), isNull);
  });

  test('save : persiste localement en non-synchronisé', () async {
    const config = ReceiptConfig(nomBoutique: 'Chez Awa', afficherLogo: false);
    await repo.save(_boutiqueId, config);

    final row = await db.getRecuConfig(_boutiqueId);
    expect(row, isNotNull);
    expect(row!.nomBoutique, 'Chez Awa');
    expect(row.afficherLogo, isFalse);
    expect(row.synced, isFalse);
    expect(await repo.load(_boutiqueId), config);
  });

  test('push : envoie la config en attente puis la marque synchronisée', () async {
    await repo.save(_boutiqueId, const ReceiptConfig(nomBoutique: 'V1'));

    final sent = await repo.push(_boutiqueId);
    expect(sent, 1);
    expect(api.putCalls.single.nomBoutique, 'V1');
    expect((await db.getRecuConfig(_boutiqueId))!.synced, isTrue);

    // Plus rien à pousser une fois synchronisé.
    expect(await repo.push(_boutiqueId), 0);
    expect(api.putCalls.length, 1);
  });

  test('pull : écrit la config serveur quand aucun changement local', () async {
    api.remote = (
      config: const ReceiptConfig(nomBoutique: 'Serveur', piedMessage: 'Merci !'),
      updatedAt: DateTime(2026, 7, 20),
    );

    await repo.pull(_boutiqueId);

    final row = await db.getRecuConfig(_boutiqueId);
    expect(row, isNotNull);
    expect(row!.nomBoutique, 'Serveur');
    expect(row.synced, isTrue);
  });

  test("pull : n'écrase pas une modification locale en attente", () async {
    await repo.save(_boutiqueId, const ReceiptConfig(nomBoutique: 'Local'));
    api.remote = (
      config: const ReceiptConfig(nomBoutique: 'Serveur'),
      updatedAt: DateTime(2026, 7, 20),
    );

    await repo.pull(_boutiqueId);

    final row = await db.getRecuConfig(_boutiqueId);
    expect(row!.nomBoutique, 'Local'); // la modif locale a priorité
    expect(row.synced, isFalse);
  });

  test('load : migre une fois la config héritée du secure storage', () async {
    const legacy = ReceiptConfig(nomBoutique: 'Ancienne', afficherVendeur: false);
    FlutterSecureStorage.setMockInitialValues({
      ReceiptSettingsStorage.storageKey: legacy.encode(),
    });

    final loaded = await repo.load(_boutiqueId);
    expect(loaded, legacy);

    // Importée dans Drift comme à-synchroniser…
    final row = await db.getRecuConfig(_boutiqueId);
    expect(row, isNotNull);
    expect(row!.nomBoutique, 'Ancienne');
    expect(row.synced, isFalse);

    // …et le secure storage est purgé (migration unique).
    final legacyValue = await const ReceiptSettingsStorage(FlutterSecureStorage())
        .load();
    expect(legacyValue, isNull);
  });
}
