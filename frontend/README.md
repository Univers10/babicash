# BabiCash — Frontend Flutter

Application mobile de gestion commerciale multi-boutique pour le commerce de proximité en Côte d'Ivoire.

---

## Prérequis

1. **Flutter SDK** ≥ 3.3.0 — [flutter.dev](https://flutter.dev/docs/get-started/install)
2. **Android Studio** (SDK 33+) ou Xcode 15+ pour iOS
3. **Police Inter** : télécharger depuis [Google Fonts](https://fonts.google.com/specimen/Inter) et placer dans `assets/fonts/` : `Inter-Regular.ttf`, `Inter-Medium.ttf`, `Inter-SemiBold.ttf`, `Inter-Bold.ttf`
4. **Backend BabiCash** actif (`cd ../backend && uvicorn app.main:app --reload`)

---

## Démarrage

```bash
# 1. Dépendances
flutter pub get

# 2. Génération de code (Drift + Freezed + Retrofit) — OBLIGATOIRE
dart run build_runner build --delete-conflicting-outputs

# 3. Lancer sur Android
flutter run
```

---

## URL Backend

Dans `lib/core/network/api_client.dart` :

```dart
const String _baseUrl = 'http://10.0.2.2:8000'; // émulateur Android → localhost
// Appareil physique sur réseau local : 'http://192.168.x.x:8000'
// Production : 'https://api.babicash.ci'
```

---

## Architecture

```
lib/
├── core/
│   ├── theme/       # Design System (couleurs, typo, spacing, AppTheme Material 3)
│   ├── router/      # go_router — redirection auth automatique selon rôle
│   ├── network/     # Dio + intercepteur JWT automatique
│   ├── storage/     # flutter_secure_storage — token chiffré
│   └── errors/      # AppException + mapping DioException
├── data/
│   ├── local/       # Base Drift SQLite (offline-first, synced flag)
│   ├── remote/      # Services Retrofit (AuthApi, SyncApi)
│   └── models/      # Freezed data classes (auth, boutique, produit, sync)
├── features/
│   ├── auth/        # Écran login email/mdp + login PIN 4 chiffres
│   ├── caisse/      # Vente rapide : calculatrice + catalogue + panier + validation
│   ├── stock/       # Liste produits + badges rupture/alerte colorés
│   ├── tiers/       # Clients & Fournisseurs + suivi dettes "Doit"
│   ├── sessions/    # Ouverture/fermeture session de caisse
│   ├── dashboard/   # Vue consolidée OWNER multi-boutique (CA + marge par boutique)
│   └── sync/        # SyncService background : push pending + pull catalogue
└── shared/
    └── widgets/     # AppButton, AppTextField, AppSnackbar, AmountText
```

---

## Design System

| Élément | Valeur |
|---------|--------|
| Couleur primaire | `#1B6B2F` (vert BabiCash) |
| Couleur accent | `#F5A623` (or/orange Cash) |
| Font | Inter (400/500/600/700) |
| Rayon cartes | 16px |
| Hauteur boutons | 52px |
| Zone tactile min | 48px |

---

## Rôles

| Rôle | Navigation |
|------|-----------|
| **MANAGER** | Caisse → Stock → Clients/Fournis → Sessions |
| **OWNER** | Dashboard → Caisse → Stock → Tiers |

---

## Offline-First

1. Toutes les écritures → SQLite local **immédiatement**
2. Champ `synced = false` sur chaque ligne
3. `SyncService.pushPending()` envoie dès que réseau disponible
4. `SyncService.pullCatalogue()` met à jour le catalogue produits
