import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/errors/app_exception.dart';
export '../../../core/errors/app_exception.dart' show QuotaException;
import '../../../data/local/database.dart';
import '../../../data/remote/sync_api.dart';
import '../../../data/models/sync_model.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/boutiques/providers/boutique_provider.dart';
import '../../sessions/providers/sessions_provider.dart';
import '../domain/repartition_lot.dart';
import '../models/panier_item.dart';
import 'package:drift/drift.dart' as drift;

// ── État du panier ────────────────────────────────────────────────────────────

class PanierNotifier extends Notifier<List<PanierItem>> {
  @override
  List<PanierItem> build() => [];

  void addProduit(LocalProduit produit) {
    // Ne pas fusionner dans une ligne appartenant à un lot (prix figé).
    final existing =
        state.indexWhere((i) => i.produitId == produit.id && !i.estDansLot);
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
    if (state[index].estDansLot) return; // prix gouverné par le lot
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index) state[i].copyWith(prixUnitaire: nouveauPrix) else state[i],
    ];
  }

  void updateQuantite(int index, int quantite) {
    if (state[index].estDansLot) return; // quantité figée dans un lot
    if (quantite <= 0) {
      remove(index);
      return;
    }
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index) state[i].copyWith(quantite: quantite) else state[i],
    ];
  }

  void updateRemise(int index, double remise) {
    if (state[index].estDansLot) return; // remise gouvernée par le lot
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index) state[i].copyWith(remise: remise.clamp(0, 100)) else state[i],
    ];
  }

  void remove(int index) {
    // Retirer une ligne d'un lot dissout le lot (le prix de groupe n'a plus
    // de sens sur un sous-ensemble) ; les items redeviennent normaux.
    final item = state[index];
    if (item.estDansLot) {
      dissoudreLot(item.lotId!);
      return;
    }
    state = [
      for (int i = 0; i < state.length; i++)
        if (i != index) state[i],
    ];
  }

  /// Groupe les items d'indices [indices] en un lot vendu à [prixTotal].
  void creerLot(List<int> indices, double prixTotal, {String nom = 'Lot'}) {
    if (indices.length < 2) return;
    final cibles = indices.toSet();
    final id = const Uuid().v4();
    state = [
      for (int i = 0; i < state.length; i++)
        if (cibles.contains(i))
          state[i].copyWith(lotId: id, lotNom: nom, lotPrixTotal: prixTotal)
        else
          state[i],
    ];
  }

  /// Dissout le lot [lotId] : ses items redeviennent des lignes normales.
  void dissoudreLot(String lotId) {
    state = [
      for (final item in state)
        if (item.lotId == lotId)
          item.copyWith(lotId: null, lotNom: null, lotPrixTotal: null)
        else
          item,
    ];
  }

  void clear() => state = [];
}

/// Sous-total du panier en tenant compte des lots : un lot compte pour son
/// prix de groupe (une fois), pas pour la somme de ses items.
double sousTotalPanier(List<PanierItem> panier) {
  var total = 0.0;
  final lotsVus = <String>{};
  for (final item in panier) {
    if (item.estDansLot) {
      if (lotsVus.add(item.lotId!)) total += item.lotPrixTotal ?? 0;
    } else {
      total += item.total;
    }
  }
  return total;
}

/// Ligne prête à être enregistrée (issue d'un item normal ou d'un lot résolu).
class LigneAEnregistrer {
  const LigneAEnregistrer({
    required this.produitId,
    required this.quantite,
    required this.prixVenduReel,
    required this.margeTotal,
    this.lotId,
    this.lotNom,
  });
  final String? produitId;
  final int quantite;
  final double prixVenduReel;
  final double margeTotal;
  final String? lotId;
  final String? lotNom;
}

/// Transforme le panier en lignes de vente : items normaux tels quels, lots
/// répartis en lignes réelles (produit + prix ventilé) via [resoudreLignesLot].
List<LigneAEnregistrer> construireLignesVente(List<PanierItem> panier) {
  final lignes = <LigneAEnregistrer>[];
  for (final item in panier.where((i) => !i.estDansLot)) {
    lignes.add(LigneAEnregistrer(
      produitId: item.produitId,
      quantite: item.quantite,
      prixVenduReel: item.prixApresRemise,
      margeTotal: item.margeTotal,
    ));
  }
  final lots = <String, List<PanierItem>>{};
  for (final item in panier.where((i) => i.estDansLot)) {
    lots.putIfAbsent(item.lotId!, () => []).add(item);
  }
  for (final entry in lots.entries) {
    final items = entry.value;
    final total = items.first.lotPrixTotal ?? 0;
    final nom = items.first.lotNom;
    for (final l in resoudreLignesLot(items, total)) {
      lignes.add(LigneAEnregistrer(
        produitId: l.produitId,
        quantite: l.quantite,
        prixVenduReel: l.prixVenduReel,
        margeTotal: l.margeTotale,
        lotId: entry.key,
        lotNom: nom,
      ));
    }
  }
  return lignes;
}

final panierProvider =
    NotifierProvider<PanierNotifier, List<PanierItem>>(PanierNotifier.new);

// ── Remise globale (%) ────────────────────────────────────────────────────────

final remiseGlobaleProvider = StateProvider<double>((_) => 0.0);

// ── Client sélectionné ────────────────────────────────────────────────────────

final clientSelectionneProvider = StateProvider<LocalTier?>((ref) => null);

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
    final boutiqueId = await ref.read(currentBoutiqueIdProvider.future);
    if (user == null || boutiqueId == null) return false;

    // Bloquer si aucune session ouverte
    final session = ref.read(sessionNotifierProvider).valueOrNull;
    if (session == null) {
      throw Exception('SESSION_REQUISE');
    }

    ref.read(caisseLoadingProvider.notifier).state = true;

    try {
      final db = ref.read(appDatabaseProvider);
      final idLocal = const Uuid().v4();
      final remiseGlobale = ref.read(remiseGlobaleProvider);
      final sousTotal = sousTotalPanier(panier);
      final montantTotalCentimes = (sousTotal * 100 * (1 - remiseGlobale / 100)).round();
      final montantTotal = montantTotalCentimes / 100;
      final sessionId = session.id;
      final client = ref.read(clientSelectionneProvider);

      // Lignes réelles (lots répartis en produits + prix ventilé).
      final lignesVente = construireLignesVente(panier);

      // 1. Écriture locale (offline-first)
      await db.insertVente(LocalVentesCompanion(
        idLocal: drift.Value(idLocal),
        boutiqueId: drift.Value(boutiqueId),
        sessionId: drift.Value(sessionId),
        tierId: client != null ? drift.Value(client.id) : const drift.Value.absent(),
        modePaiement: drift.Value(modePaiement),
        montantTotal: drift.Value(montantTotal),
        synced: const drift.Value(false),
      ));

      for (final ligne in lignesVente) {
        await db.insertLigneVente(LocalLignesVenteCompanion(
          venteIdLocal: drift.Value(idLocal),
          produitId: drift.Value(ligne.produitId),
          quantite: drift.Value(ligne.quantite),
          prixVenduReel: drift.Value(ligne.prixVenduReel),
          margeCalculee: drift.Value(ligne.margeTotal),
          lotId: drift.Value(ligne.lotId),
          lotNom: drift.Value(ligne.lotNom),
        ));
      }

      // 2. Tentative sync immédiate
      try {
        final syncApi = ref.read(syncApiProvider);
        final lignes = lignesVente
            .map((ligne) => LigneVenteIn(
                  produitId: ligne.produitId,
                  quantite: ligne.quantite,
                  prixVenduReel: ligne.prixVenduReel,
                  lotId: ligne.lotId,
                  lotNom: ligne.lotNom,
                ))
            .toList();

        final resp = await syncApi.push(SyncPushRequest(
          boutiqueId: boutiqueId,
          ventes: [
            VenteIn(
              idLocal: idLocal,
              modePaiement: modePaiement,
              sessionId: sessionId,
              tierId: client?.id,
              lignes: lignes,
            ),
          ],
        ));

        // Marquer comme sync si succès
        if (resp.ventes.isNotEmpty) {
          await db.marquerVenteSync(idLocal, resp.ventes.first.venteId);
        }
      } on DioException catch (e) {
        final appErr = mapDioError(e);
        if (appErr is QuotaException) {
          // Quota épuisé → supprimer la vente locale et remonter au UI
          await db.deleteVente(idLocal);
          ref.read(panierProvider.notifier).clear();
          ref.read(remiseGlobaleProvider.notifier).state = 0.0;
          ref.read(clientSelectionneProvider.notifier).state = null;
          throw appErr;
        }
        // Autres erreurs réseau → restera synced=false pour le background worker
      } on AppException {
        // Autres erreurs app → restera synced=false pour le background worker
      }

      ref.read(panierProvider.notifier).clear();
      ref.read(remiseGlobaleProvider.notifier).state = 0.0;
      ref.read(clientSelectionneProvider.notifier).state = null;
      return true;
    } finally {
      ref.read(caisseLoadingProvider.notifier).state = false;
    }
  }
}

final caisseProvider =
    NotifierProvider<CaisseNotifier, void>(CaisseNotifier.new);
