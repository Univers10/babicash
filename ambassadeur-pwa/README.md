# BabiCash — PWA Ambassadeur

Espace ambassadeur (parrainage) « genre Wave », installable. App React + Vite +
TypeScript, autonome, qui consomme l'API FastAPI BabiCash. Voir la spec :
`../docs/design-parrainage-ambassadeurs.md`.

## Démarrage

```bash
npm install
cp .env.example .env   # ajuster VITE_API_BASE si besoin
npm run dev            # http://localhost:5173
```

Par défaut (sans `.env`), l'app tape l'API de prod
`https://babicash.ecomotionafricaci.com/api/v1`. Pour développer contre le backend
local : `VITE_API_BASE=http://localhost:8000/api/v1` (lancer aussi
`uvicorn app.main:app --reload` côté `backend/`, CORS déjà ouvert).

## Build & aperçu

```bash
npm run build     # génère dist/ (site statique + service worker PWA)
npm run preview   # sert dist/ localement
```

Déploiement : héberger `dist/` en statique (Netlify, Vercel, Nginx, `/static`…).
Pas d'auto-deploy pour l'instant (comme le frontend Flutter).

## Écrans

- **Connexion / Inscription** ambassadeur (choix du code avec vérif de disponibilité)
- **Accueil** : commission à recevoir, code de parrainage (copier/partager), stats, activité
- **Filleuls** : liste + abonnement + commission cumulée
- **Gains** : commissions et lots de versement hebdomadaires
- **Profil** : coordonnées Mobile Money, déconnexion

## Endpoints consommés

`POST /ambassadeurs/register` · `POST /ambassadeurs/login` ·
`GET /ambassadeurs/code-disponible` · `GET|PATCH /ambassadeurs/moi` ·
`GET /ambassadeurs/filleuls` · `GET /ambassadeurs/commissions` ·
`GET /ambassadeurs/versements`
