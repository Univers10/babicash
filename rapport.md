# Rapport de mise à jour – BabiCash

Date : 6 août 2026

## 1. Migration des domaines

Les nouveaux noms de domaine sont maintenant disponibles et les configurations ont été mises à jour.

| Application | Ancienne URL | Nouvelle URL |
|-------------|--------------|--------------|
| Application POS (Flutter) | `https://babicash.ecomotionafricaci.com` | `https://pos.babicash.ci` |
| Application ambassadeur (PWA) | `https://babicash.ecomotionafricaci.com/api/v1` | `https://business.babicash.ci/api/v1` |

### Fichiers modifiés

- `frontend/lib/core/network/api_client.dart`
  - `_baseUrl` passe à `https://pos.babicash.ci`.
- `ambassadeur-pwa/src/api/client.ts`
  - Fallback de `BASE` passe à `https://business.babicash.ci/api/v1`.
- `ambassadeur-pwa/.env.example`
  - Commentaire de production mis à jour.
- `backend/.env.production`
  - `ALLOWED_ORIGINS` mis à jour :
    ```env
    ALLOWED_ORIGINS=https://pos.babicash.ci,https://business.babicash.ci
    ```

### Tests mis à jour

- `frontend/test/media_url_test.dart`
  - Origine de test et URLs absolues attendues basculées vers `https://pos.babicash.ci`.
  - Résultat : `flutter test test/media_url_test.dart` → 8 tests passed.

## 2. Simplification de l'écran de connexion

- Retrait de l'option de connexion par **ID propriétaire**.
- Retrait de la connexion **Apple** (bouton, provider, API, modèle, dépendance `sign_in_with_apple`).
- L'écran par défaut pour les utilisateurs non connectés est maintenant **PIN** (`/login-pin`).

### Fichiers impactés

- `frontend/lib/features/auth/screens/login_screen.dart`
- `frontend/lib/features/auth/providers/auth_provider.dart`
- `frontend/lib/data/remote/auth_api.dart`
- `frontend/lib/data/models/auth_model.dart`
- `frontend/lib/core/router/app_router.dart`
- `frontend/lib/core/config/oauth_config.dart`
- `frontend/pubspec.yaml`

## 3. Refonte de l'historique des ventes

L'écran d'historique a été repensé pour être plus clair et intuitif.

### Changements principaux

- **Résumé visuel en haut** : cartes indiquant le nombre de ventes, le total, et la répartition par mode de paiement (Espèces, Mobile, Crédit).
- **Liste groupée par date** : ventes regroupées sous « Aujourd'hui », « Hier », les jours de la semaine, puis les dates plus anciennes.
- **Tuiles épurées** : client, heure, vendeur, montant, mode de paiement et statut (retourné / signalé).
- **Fiche détail en bottom sheet** : au tap sur une vente, affichage des articles, du total, du vendeur, et des actions **Réimprimer** / **Retour**.
- **Barre de filtres allégée** : modes de paiement en accès rapide + bouton **Filtres** ouvrant un bottom sheet pour la période, le vendeur, les ventes signalées et les retours.

### Fichier impacté

- `frontend/lib/features/ventes/screens/historique_screen.dart`

## 4. Vérifications

- `flutter analyze lib/features/ventes/screens/historique_screen.dart` → **No issues found**.
- `flutter test test/media_url_test.dart` → **8 tests passed**.
- `flutter analyze` global : seules des infos mineures `prefer_const_constructors` restent présentes dans d'autres écrans ; elles ne bloquent pas la compilation et n'ont pas été introduites par ces modifications.

## 5. Points de vigilance

- S'assurer que le DNS et les certificats SSL sont bien actifs pour `pos.babicash.ci` et `business.babicash.ci`.
- Vérifier que le backend est redéployé avec le `ALLOWED_ORIGINS` mis à jour pour éviter les erreurs CORS.
- Pour l'application ambassadeur, s'assurer que le fichier `.env` de production (non versionné) contient bien :
  ```env
  VITE_API_BASE=https://business.babicash.ci/api/v1
  ```
