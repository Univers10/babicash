# BabiCash — Frontend Flutter (POS)

Application mobile de gestion commerciale multi-boutique pour le commerce de proximité en Côte d'Ivoire.

> Contexte IA et règles globales : voir `AGENTS.md` à la racine du repo.

## Prérequis

1. **Flutter SDK** ≥ 3.3 — [flutter.dev](https://flutter.dev/docs/get-started/install)
2. **Android Studio** (SDK 33+) ou Xcode 15+ pour iOS
3. **Police Inter** dans `assets/fonts/` : `Inter-Regular.ttf`, `Inter-Medium.ttf`, `Inter-SemiBold.ttf`, `Inter-Bold.ttf`
4. **Backend BabiCash** actif (`cd ../backend && uvicorn app.main:app --reload`)

## Démarrage

```bash
# 1. Dépendances
flutter pub get

# 2. Génération de code (Drift + Freezed + Riverpod) — OBLIGATOIRE après toute modif de modèles
dart run build_runner build --delete-conflicting-outputs

# 3. Lancer sur Android
flutter run

# Qualité
flutter analyze --no-fatal-infos
flutter test --coverage

# Build
flutter build apk --release
```

> ⚠️ Ne jamais éditer les fichiers générés `*.g.dart`, `*.freezed.dart`, `*.drift.dart`.

## URL Backend

Dans `lib/core/network/api_client.dart` :

```dart
const String _baseUrl = 'https://pos.babicash.ci'; // PROD
// Dev : 'http://10.0.2.2:8000' (émulateur → localhost) ou 'http://192.168.x.x:8000' (LAN)
```

## Architecture

```
lib/
├── core/          # Theme (Material 3), router (go_router), network (Dio + JWT), storage, errors
├── data/
│   ├── local/     # Base Drift SQLite (offline-first, flag synced)
│   ├── remote/    # Clients API Dio (auth, produits, tiers, sessions, sync, shop, users…)
│   └── models/    # Modèles Freezed + json_serializable
├── features/      # auth, caisse, stock, tiers, sessions, ventes, dashboard,
│                  # users (gérants), abonnements, settings, shop, boutiques, sync
├── shared/        # Shell bottom-nav + widgets réutilisables
└── main.dart      # ProviderScope + splash animée
```

## Features

| Feature | Rôle |
|---|---|
| `auth` | Login email/Google + PIN, inscription, verrouillage hors-ligne (hash local du PIN) |
| `caisse` | POS : catalogue, numpad, panier, prix négocié, lots, ticket, impression thermique |
| `stock` | Produits, catégories colorées, mouvements de stock, alertes rupture/bas |
| `tiers` | Clients & fournisseurs, soldes "Doit", paiements |
| `sessions` | Ouverture/fermeture, historique, réconciliation, rapport |
| `ventes` | Historique groupé par date, filtres, retour de vente, réimpression |
| `dashboard` | Vue consolidée multi-boutique (OWNER) + performance par boutique |
| `users` | Gestion des gérants (écran dédié, OWNER) |
| `abonnements` | Plan FREE/PRO, catalogue des offres, page tarifs |
| `settings` | Profil, boutique, reçu (en-tête/pied), imprimante |
| `shop` | Boutique en ligne du commerce (catalogue, panier) |
| `sync` | `SyncService` : `pushPending()` / `pullCatalogue()` |

## Rôles & navigation

| Rôle | Navigation |
|------|-----------|
| **MANAGER** | Caisse → Stock → Tiers → Sessions |
| **OWNER** | Dashboard → Caisse → Stock → Tiers … |

## Offline-First

1. Toutes les écritures → SQLite local **immédiatement** (`synced = false`)
2. `connectivity_plus` détecte le retour du réseau → `SyncService.pushPending()`
3. Backend confirme → `synced = true` (+ `serverVenteId`)
4. `SyncService.pullCatalogue()` met à jour produits/catégories

## Design System

| Élément | Valeur |
|---|---|
| Primaire / Accent | `#1B6B2F` vert · `#F5A623` orange · fond `#F7F7F5` · texte `#3D1F00` |
| Font | Inter (400/500/600/700) |
| Rayon cartes / inputs | 16 px / 8 px · boutons 52 px |
| Spacing | Constantes dans `lib/core/theme/app_spacing.dart` |