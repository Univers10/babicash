# BabiCash — Frontend (Flutter)

Emplacement réservé. L'application mobile Flutter sera développée dans une phase ultérieure.

## Prévu
- **Flutter** (Android prioritaire), **SQLite** via Drift/Sqflite (Offline-First).
- Gestion d'état : Riverpod ou Bloc.
- Écrans : Dashboard, Vente Rapide (pavé numérique / négociation), Validation (WhatsApp + Impression), Stocks (alertes couleurs).
- **Impression reçu** : imprimante thermique Bluetooth via protocole **ESC/POS**
  (`print_bluetooth_thermal` ou `esc_pos_utils` + `flutter_blue_plus`), rouleaux 58/80 mm,
  impression hors-ligne depuis le SQLite local.
- Synchronisation Offline-First avec le backend (`/api/v1/sync/push` et `/api/v1/sync/pull`).
