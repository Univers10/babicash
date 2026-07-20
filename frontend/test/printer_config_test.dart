import 'package:babicash/features/settings/models/saved_printer.dart';
import 'package:babicash/features/settings/providers/printer_config_provider.dart';
import 'package:babicash/features/settings/services/printer_settings_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_universal_printer/pos_universal_printer.dart';

/// Connecteur factice : ne touche aucun matériel Bluetooth réel.
class _FakeConnector extends PrinterConnector {
  _FakeConnector({this.connectResult = true});

  bool connectResult;
  bool _connected = false;
  SavedPrinter? lastConnected;
  int disconnectCount = 0;
  int testCount = 0;

  @override
  Stream<PrinterDevice> scan() => const Stream.empty();

  @override
  Future<bool> connect(SavedPrinter printer) async {
    lastConnected = printer;
    _connected = connectResult;
    return connectResult;
  }

  @override
  Future<void> disconnect() async {
    disconnectCount++;
    _connected = false;
  }

  @override
  bool get isConnected => _connected;

  @override
  Future<void> printTest({required String nomBoutique}) async {
    testCount++;
  }
}

ProviderContainer _container(PrinterConnector connector) {
  return ProviderContainer(overrides: [
    printerSettingsStorageProvider.overrideWithValue(
      const PrinterSettingsStorage(FlutterSecureStorage()),
    ),
    printerConnectorProvider.overrideWithValue(connector),
  ]);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Storage vierge avant chaque test (mock in-memory du secure storage).
    FlutterSecureStorage.setMockInitialValues({});
  });

  group('SavedPrinter', () {
    test('encode/tryDecode fait un aller-retour fidèle', () {
      const p = SavedPrinter(name: 'MTP-2', address: '00:11:22:33:44:55');
      final decoded = SavedPrinter.tryDecode(p.encode());
      expect(decoded, p);
      expect(decoded!.name, 'MTP-2');
      expect(decoded.address, '00:11:22:33:44:55');
    });

    test('tryDecode retourne null sur entrée nulle/vide/corrompue', () {
      expect(SavedPrinter.tryDecode(null), isNull);
      expect(SavedPrinter.tryDecode(''), isNull);
      expect(SavedPrinter.tryDecode('pas du json'), isNull);
      expect(SavedPrinter.tryDecode('{"name":"X"}'), isNull); // sans adresse
    });
  });

  group('PrinterSettingsStorage', () {
    test('save puis load renvoie l\'imprimante mémorisée', () async {
      const storage = PrinterSettingsStorage(FlutterSecureStorage());
      const printer = SavedPrinter(name: 'Epson', address: 'AA:BB:CC:DD:EE:FF');

      expect(await storage.load(), isNull);
      await storage.save(printer);
      expect(await storage.load(), printer);
    });

    test('clear oublie l\'imprimante', () async {
      const storage = PrinterSettingsStorage(FlutterSecureStorage());
      await storage.save(const SavedPrinter(name: 'X', address: 'A:B'));
      await storage.clear();
      expect(await storage.load(), isNull);
    });
  });

  group('PrinterConfigNotifier', () {
    test('selectPrinter mémorise (MAC+nom) et connecte', () async {
      final connector = _FakeConnector(connectResult: true);
      final container = _container(connector);
      addTearDown(container.dispose);

      await container.read(printerConfigProvider.future);
      final ok = await container
          .read(printerConfigProvider.notifier)
          .selectPrinter(name: 'MTP-2', address: '00:11:22:33:44:55');

      expect(ok, isTrue);
      expect(connector.lastConnected,
          const SavedPrinter(name: 'MTP-2', address: '00:11:22:33:44:55'));

      final state = container.read(printerConfigProvider).value!;
      expect(state.saved?.address, '00:11:22:33:44:55');
      expect(state.connected, isTrue);

      // Persistance effective : rechargée par une nouvelle instance de storage.
      const storage = PrinterSettingsStorage(FlutterSecureStorage());
      expect((await storage.load())?.name, 'MTP-2');
    });

    test('selectPrinter persiste même si la connexion échoue', () async {
      final connector = _FakeConnector(connectResult: false);
      final container = _container(connector);
      addTearDown(container.dispose);

      await container.read(printerConfigProvider.future);
      final ok = await container
          .read(printerConfigProvider.notifier)
          .selectPrinter(name: 'HS', address: 'DE:AD:BE:EF:00:01');

      expect(ok, isFalse);
      final state = container.read(printerConfigProvider).value!;
      expect(state.saved?.address, 'DE:AD:BE:EF:00:01'); // mémorisée
      expect(state.connected, isFalse);
    });

    test('build recharge l\'imprimante déjà persistée', () async {
      const storage = PrinterSettingsStorage(FlutterSecureStorage());
      await storage.save(const SavedPrinter(name: 'Persist', address: 'M:A:C'));

      final container = _container(_FakeConnector());
      addTearDown(container.dispose);

      final state = await container.read(printerConfigProvider.future);
      expect(state.saved?.name, 'Persist');
    });

    test('forget déconnecte et efface la persistance', () async {
      final connector = _FakeConnector(connectResult: true);
      final container = _container(connector);
      addTearDown(container.dispose);

      await container.read(printerConfigProvider.future);
      await container
          .read(printerConfigProvider.notifier)
          .selectPrinter(name: 'X', address: 'A:B');

      await container.read(printerConfigProvider.notifier).forget();

      expect(connector.disconnectCount, 1);
      expect(container.read(printerConfigProvider).value!.saved, isNull);

      const storage = PrinterSettingsStorage(FlutterSecureStorage());
      expect(await storage.load(), isNull);
    });

    test('reconnect retourne false sans imprimante mémorisée', () async {
      final container = _container(_FakeConnector());
      addTearDown(container.dispose);

      await container.read(printerConfigProvider.future);
      final ok =
          await container.read(printerConfigProvider.notifier).reconnect();
      expect(ok, isFalse);
    });

    test('printTest délègue au connecteur', () async {
      final connector = _FakeConnector(connectResult: true);
      final container = _container(connector);
      addTearDown(container.dispose);

      await container.read(printerConfigProvider.future);
      await container
          .read(printerConfigProvider.notifier)
          .selectPrinter(name: 'X', address: 'A:B');
      await container
          .read(printerConfigProvider.notifier)
          .printTest(nomBoutique: 'Ma Boutique');

      expect(connector.testCount, 1);
    });
  });
}
