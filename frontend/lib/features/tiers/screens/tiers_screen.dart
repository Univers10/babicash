import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/local/database.dart';
import '../../../data/models/tier_model.dart';
import '../../../data/remote/tiers_api.dart';
import '../../../features/boutiques/providers/boutique_provider.dart';
import '../../../shared/widgets/amount_text.dart';
import '../../../shared/widgets/menu_button.dart';
import '../providers/tiers_provider.dart';

class TiersScreen extends ConsumerStatefulWidget {
  const TiersScreen({super.key});

  @override
  ConsumerState<TiersScreen> createState() => _TiersScreenState();
}

class _TiersScreenState extends ConsumerState<TiersScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final type = ref.watch(tiersTypeProvider);
    final tiersAsync = ref.watch(tiersProvider(type));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const MenuButton(),
        title: const Text('Clients & Fournisseurs'),
        actions: [
          IconButton(
            icon: const Icon(Symbols.refresh),
            onPressed: () => ref.invalidate(tiersProvider(type)),
            tooltip: 'Actualiser',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTierDialog(context, type: type),
        icon: const Icon(Symbols.person_add),
        label: Text(type == 'CLIENT' ? 'Client' : 'Fournisseur'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // ── Toggle Client / Fournisseur ───────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                _TypeChip(
                  label: 'Clients',
                  icon: Symbols.person,
                  selected: type == 'CLIENT',
                  onTap: () => ref.read(tiersTypeProvider.notifier).state = 'CLIENT',
                ),
                const SizedBox(width: 8),
                _TypeChip(
                  label: 'Fournisseurs',
                  icon: Symbols.store,
                  selected: type == 'FOURNISSEUR',
                  onTap: () => ref.read(tiersTypeProvider.notifier).state = 'FOURNISSEUR',
                ),
              ],
            ),
          ),

          // ── Barre de recherche ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Rechercher par nom ou téléphone...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
                prefixIcon: const Icon(Symbols.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Symbols.close, size: 18),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ── Contenu ───────────────────────────────────────────────
          Expanded(
            child: tiersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Symbols.error, size: 48, color: AppColors.error),
                    SizedBox(height: 12),
                    Text('Erreur de chargement', style: AppTextStyles.bodyMedium),
                  ],
                ),
              ),
              data: (allTiers) {
                // Filtrage recherche
                var tiers = allTiers.toList();
                if (_searchQuery.isNotEmpty) {
                  final q = _searchQuery.toLowerCase();
                  tiers = tiers.where((t) =>
                      t.nom.toLowerCase().contains(q) ||
                      (t.telephone ?? '').contains(q)).toList();
                }

                if (tiers.isEmpty && allTiers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          type == 'CLIENT' ? Symbols.person : Symbols.store,
                          size: 64,
                          color: AppColors.textDisabled,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          type == 'CLIENT'
                              ? 'Aucun client enregistré'
                              : 'Aucun fournisseur enregistré',
                          style: AppTextStyles.headlineMedium
                              .copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ajoutez votre premier ${type == 'CLIENT' ? 'client' : 'fournisseur'}',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.textTertiary),
                        ),
                      ],
                    ),
                  );
                }

                if (tiers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Symbols.search_off, size: 48, color: AppColors.textDisabled),
                        const SizedBox(height: 12),
                        Text('Aucun résultat',
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary)),
                      ],
                    ),
                  );
                }

                // Stats
                final totalDu = allTiers.fold(0.0, (sum, t) => sum + t.soldeDu);
                final debiteurs = allTiers.where((t) => t.soldeDu > 0).length;

                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(tiersProvider(type)),
                  child: Column(
                    children: [
                      // ── Stats résumé ─────────────────────────────────
                      if (totalDu > 0 || debiteurs > 0)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                          child: Row(
                            children: [
                              _StatCard(
                                label: type == 'CLIENT' ? 'Clients' : 'Fournisseurs',
                                value: '${allTiers.length}',
                                color: AppColors.primary,
                                icon: type == 'CLIENT' ? Symbols.people : Symbols.store,
                              ),
                              const SizedBox(width: 8),
                              _StatCard(
                                label: 'Débiteurs',
                                value: '$debiteurs',
                                color: AppColors.warning,
                                icon: Symbols.account_balance,
                              ),
                              const SizedBox(width: 8),
                              _StatCard(
                                label: 'Total dû',
                                value: '${totalDu.toStringAsFixed(0)} F',
                                color: AppColors.error,
                                icon: Symbols.payments,
                              ),
                            ],
                          ),
                        ),
                      // ── Liste ─────────────────────────────────────────
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                          itemCount: tiers.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (_, i) => _TierCard(
                            tier: tiers[i],
                            onTap: () => _showTierDetails(context, tiers[i]),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Dialog Créer / Modifier ─────────────────────────────────────────────────

  void _showTierDialog(BuildContext context, {required String type, LocalTier? tier}) {
    final nomCtrl = TextEditingController(text: tier?.nom ?? '');
    final telCtrl = TextEditingController(text: tier?.telephone ?? '');
    final isEdit = tier != null;

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              isEdit ? Symbols.edit : Symbols.person_add,
              color: AppColors.primary,
            ),
            const SizedBox(width: 12),
            Text(isEdit
                ? 'Modifier ${type == 'CLIENT' ? 'client' : 'fournisseur'}'
                : 'Nouveau ${type == 'CLIENT' ? 'client' : 'fournisseur'}'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomCtrl,
              decoration: InputDecoration(
                labelText: 'Nom',
                prefixIcon: const Icon(Symbols.person),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: telCtrl,
              decoration: InputDecoration(
                labelText: 'Téléphone (optionnel)',
                prefixIcon: const Icon(Symbols.phone),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton.icon(
            icon: Icon(isEdit ? Symbols.check : Symbols.add),
            onPressed: () async {
              final nom = nomCtrl.text.trim();
              if (nom.isEmpty) return;
              final tel = telCtrl.text.trim().isEmpty ? null : telCtrl.text.trim();

              try {
                final api = ref.read(tiersApiProvider);
                if (isEdit) {
                  await api.updateTier(tier.id, TierUpdateRequest(nom: nom, telephone: tel));
                } else {
                  final boutiqueId = await ref.read(currentBoutiqueIdProvider.future);
                  if (boutiqueId == null) throw Exception('Aucune boutique');
                  await api.createTier(TierCreateRequest(
                    boutiqueId: boutiqueId,
                    nom: nom,
                    telephone: tel,
                    typeTiers: type,
                  ));
                }
                if (dialogCtx.mounted) Navigator.of(dialogCtx).pop();
                ref.invalidate(tiersProvider(type));
              } catch (e) {
                if (dialogCtx.mounted) {
                  ScaffoldMessenger.of(dialogCtx).showSnackBar(
                    SnackBar(
                      content: Text(_extractError(e)),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            label: Text(isEdit ? 'Enregistrer' : 'Créer'),
          ),
        ],
      ),
    );
  }

  // ── Bottom Sheet Détails ────────────────────────────────────────────────────

  void _showTierDetails(BuildContext context, LocalTier tier) {
    final isClient = tier.typeTiers == 'CLIENT';
    final color = isClient ? AppColors.primary : AppColors.accent;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Poignée
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            // Avatar + infos
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    isClient ? Symbols.person : Symbols.store,
                    color: color,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tier.nom, style: AppTextStyles.headlineSmall),
                      if (tier.telephone != null)
                        Text(tier.telephone!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                      Text(
                        isClient ? 'Client' : 'Fournisseur',
                        style: AppTextStyles.caption.copyWith(color: color),
                      ),
                    ],
                  ),
                ),
                if (tier.soldeDu > 0)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Doit', style: AppTextStyles.caption.copyWith(color: AppColors.error)),
                      AmountText(
                        amount: tier.soldeDu,
                        style: AppTextStyles.amountMedium.copyWith(color: AppColors.error),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 24),
            // Actions
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Symbols.edit,
                    label: 'Modifier',
                    color: AppColors.primary,
                    onTap: () {
                      Navigator.of(context).pop();
                      _showTierDialog(context, type: tier.typeTiers, tier: tier);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                if (tier.soldeDu > 0)
                  Expanded(
                    child: _ActionButton(
                      icon: Symbols.payments,
                      label: 'Paiement',
                      color: AppColors.success,
                      onTap: () {
                        Navigator.of(context).pop();
                        _showPaiementDialog(context, tier);
                      },
                    ),
                  ),
                if (tier.soldeDu > 0) const SizedBox(width: 10),
                Expanded(
                  child: _ActionButton(
                    icon: Symbols.delete,
                    label: 'Supprimer',
                    color: AppColors.error,
                    onTap: () {
                      Navigator.of(context).pop();
                      _deleteTier(context, tier);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Dialog Paiement ─────────────────────────────────────────────────────────

  void _showPaiementDialog(BuildContext context, LocalTier tier) {
    final montantCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Symbols.payments, color: AppColors.success),
            SizedBox(width: 12),
            Text('Enregistrer paiement'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Symbols.account_balance, size: 18, color: AppColors.error),
                  const SizedBox(width: 8),
                  const Text('Solde dû : ', style: AppTextStyles.bodySmall),
                  AmountText(
                    amount: tier.soldeDu,
                    style: AppTextStyles.labelLarge.copyWith(color: AppColors.error),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: montantCtrl,
              decoration: InputDecoration(
                labelText: 'Montant du paiement',
                prefixIcon: const Icon(Symbols.attach_money),
                suffixText: 'F',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.number,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton.icon(
            icon: const Icon(Symbols.check),
            style: FilledButton.styleFrom(backgroundColor: AppColors.success),
            onPressed: () async {
              final montant = double.tryParse(montantCtrl.text.trim()) ?? 0;
              if (montant <= 0) return;

              try {
                final api = ref.read(tiersApiProvider);
                await api.enregistrerPaiement(
                  tier.id,
                  PaiementTierRequest(montant: montant),
                );
                if (dialogCtx.mounted) Navigator.of(dialogCtx).pop();
                ref.invalidate(tiersProvider(tier.typeTiers));
              } catch (e) {
                if (dialogCtx.mounted) {
                  ScaffoldMessenger.of(dialogCtx).showSnackBar(
                    SnackBar(
                      content: Text(_extractError(e)),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            label: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  // ── Suppression ─────────────────────────────────────────────────────────────

  void _deleteTier(BuildContext context, LocalTier tier) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Symbols.warning, color: AppColors.error),
            SizedBox(width: 12),
            Text('Supprimer ?'),
          ],
        ),
        content: Text(
          'Voulez-vous supprimer "${tier.nom}" ?\nCette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton.icon(
            icon: const Icon(Symbols.delete),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              try {
                final api = ref.read(tiersApiProvider);
                await api.deleteTier(tier.id);
                // Supprimer du cache local
                final db = ref.read(appDatabaseProvider);
                await (db.delete(db.localTiers)..where((t) => t.id.equals(tier.id))).go();
                if (dialogCtx.mounted) Navigator.of(dialogCtx).pop();
                ref.invalidate(tiersProvider(tier.typeTiers));
              } catch (e) {
                if (dialogCtx.mounted) {
                  ScaffoldMessenger.of(dialogCtx).showSnackBar(
                    SnackBar(
                      content: Text(_extractError(e)),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            label: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  String _extractError(Object e) {
    if (e is DioException && e.response?.data is Map) {
      final detail = (e.response!.data as Map)['detail'];
      if (detail is String) return detail;
    }
    return 'Erreur : $e';
  }
}

// ── Widgets privés ───────────────────────────────────────────────────────────

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: selected ? Colors.white : AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: TextStyle(fontSize: 9, color: color.withValues(alpha: 0.7)),
            ),
          ],
        ),
      ),
    );
  }
}

class _TierCard extends StatelessWidget {
  const _TierCard({required this.tier, required this.onTap});
  final LocalTier tier;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasDette = tier.soldeDu > 0;
    final isClient = tier.typeTiers == 'CLIENT';
    final color = isClient ? AppColors.primary : AppColors.accent;

    return Card(
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0.5,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isClient ? Symbols.person : Symbols.store,
                  size: 22,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tier.nom,
                        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    if (tier.telephone != null)
                      Text(tier.telephone!,
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary)),
                  ],
                ),
              ),
              if (hasDette)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: AmountText(
                    amount: tier.soldeDu,
                    style: AppTextStyles.labelMedium
                        .copyWith(color: AppColors.error, fontWeight: FontWeight.w700),
                  ),
                )
              else
                const Icon(Symbols.chevron_right, size: 20, color: AppColors.textDisabled),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
