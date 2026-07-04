import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/errors/app_exception.dart';
import '../../../data/local/database.dart';
import '../../../data/remote/sync_api.dart';
import '../../../data/models/sync_model.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../models/panier_item.dart';
import 'package:drift/drift.dart' as drift;

// ── État du panier ────────────────────────────────────────────────────────────

class PanierNotifier extends Notifier<List<PanierItem>> {
  @override
  List<PanierItem> build() => [];

  void addProduit(LocalProduit produit) {
    final existing = state.indexWhere((i) => i.produitId == produit.id);
    if (existing >= 0) {
      state = [
        for (final item in state)
          if (item.produitId == produit.id)
            item.copyWith(quantite: item.quantite + 1)
          else
            item,
      ];
    } else {
      state = [
        ...state,
        PanierItem(
          produitId: produit.id,
          nom: produit.nom,
          prixUnitaire: produit.prixVenteSuggere,
          prixAchat: produit.prixAchatMoyen,
        ),
      ];
    }
  }

  void addLibre(double montant) {
    state = [
      ...state,
      PanierItem(
        nom: 'Article libre',
        prixUnitaire: montant,
        prixAchat: 0,
      ),
    ];
  }

  void updatePrix(int index, double nouveauPrix) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index) state[i].copyWith(prixUnitaire: nouveauPrix) else state[i],
    ];
  }

  void updateQuantite(int index, int quantite) {
    if (quantite <= 0) {
      remove(index);
      return;
    }
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index) state[i].copyWith(quantite: quantite) else state[i],
    ];
  }

  void remove(int index) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i != index) state[i],
    ];
  }

  void clear() => state = [];
}

final panierProvider =
    NotifierProvider<PanierNotifier, List<PanierItem>>(PanierNotifier.new);

// ── Loading state ─────────────────────────────────────────────────────────────

final caisseLoadingProvider = StateProvider<bool>((_) => false);

// ── Notifier vente ────────────────────────────────────────────────────────────

class CaisseNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<bool> enregistrerVente({required String modePaiement}) async {
    final panier = ref.read(panierProvider);
    if (panier.isEmpty) return false;

    final user = ref.read(authStateProvider).value;
    if (user?.boutiqueId == null) return false;

    ref.read(caisseLoadingProvider.notifier).state = true;

    try {
      final db = ref.read(appDatabaseProvider);
      final idLocal = const Uuid().v4();
      final montantTotal =
          panier.fold(0.0, (sum, item) => sum + item.total);

      // 1. Écriture locale (offline-first)
      await db.insertVente(LocalVentesCompanion(
        idLocal: drift.Value(idLocal),
        boutiqueId: drift.Value(user!.boutiqueId!),
        modePaiement: drift.Value(modePaiement),
        montantTotal: drift.Value(montantTotal),
        synced: const drift.Value(false),
      ));

      for (final item in panier) {
        await db.insertLigneVente(LocalLignesVenteCompanion(
          venteIdLocal: drift.Value(idLocal),
          produitId: drift.Value(item.produitId),
          quantite: drift.Value(item.quantite),
          prixVenduReel: drift.Value(item.prixUnitaire),
          margeCalculee: drift.Value(item.margeTotal),
        ));
      }

      // 2. Tentative sync immédiate
      try {
        final syncApi = ref.read(syncApiProvider);
        final lignes = panier.map((item) => LigneVenteIn(
              produitId: item.produitId,
              quantite: item.quantite,
              prixVenduReel: item.prixUnitaire,
            )).toList();

        final resp = await syncApi.push(SyncPushRequest(
          boutiqueId: user.boutiqueId!,
          ventes: [
            VenteIn(
              idLocal: idLocal,
              modePaiement: modePaiement,
              lignes: lignes,
            ),
          ],
        ));

        // Marquer comme sync si succès
        if (resp.ventes.isNotEmpty) {
          await db.marquerVenteSync(idLocal, resp.ventes.first.venteId);
        }
      } on AppException {
        // Sync échouée → restera synced=false pour le background worker
      }

      ref.read(panierProvider.notifier).clear();
      return true;
    } finally {
      ref.read(caisseLoadingProvider.notifier).state = false;
    }
  }
}

final caisseProvider =
    NotifierProvider<CaisseNotifier, void>(CaisseNotifier.new);
