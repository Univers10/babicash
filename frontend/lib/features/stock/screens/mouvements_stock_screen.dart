import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/local/database.dart';
import '../domain/stock_calculator.dart';
import '../providers/mouvements_provider.dart';

/// Historique des mouvements de stock (S3) : journal local, nom de l'auteur,
/// motif, type et statut de synchronisation.
class MouvementsStockScreen extends ConsumerWidget {
  const MouvementsStockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mouvementsAsync = ref.watch(mouvementsStockProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Historique du stock'),
      ),
      body: mouvementsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Symbols.error, size: 48, color: AppColors.error),
              const VGap(AppSpacing.md),
              Text('Erreur de chargement', style: AppTextStyles.bodyMedium),
            ],
          ),
        ),
        data: (mouvements) {
          if (mouvements.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Symbols.history,
                      size: 64, color: AppColors.textDisabled),
                  const VGap(AppSpacing.lg),
                  Text('Aucun mouvement',
                      style: AppTextStyles.headlineMedium
                          .copyWith(color: AppColors.textSecondary)),
                  const VGap(AppSpacing.sm),
                  Text(
                    'Les entrées et sorties de stock\napparaîtront ici',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textTertiary),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: AppSpacing.pagePadding,
            itemCount: mouvements.length,
            separatorBuilder: (_, __) => const VGap(AppSpacing.sm),
            itemBuilder: (_, i) => _MouvementCard(mouvement: mouvements[i]),
          );
        },
      ),
    );
  }
}

class _MouvementCard extends StatelessWidget {
  const _MouvementCard({required this.mouvement});
  final LocalMouvementsStockData mouvement;

  @override
  Widget build(BuildContext context) {
    final isEntree = mouvement.typeMouvement == TypeMouvementStock.entree;
    final couleur = isEntree ? AppColors.success : AppColors.error;
    final dateFormatee =
        DateFormat('dd/MM/yyyy HH:mm').format(mouvement.dateMouvement);

    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icône type de mouvement
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: couleur.withValues(alpha: 0.12),
                borderRadius: AppSpacing.borderRadiusMd,
              ),
              child: Icon(
                isEntree ? Symbols.trending_up : Symbols.trending_down,
                color: couleur,
                size: 22,
              ),
            ),
            const HGap(AppSpacing.md),

            // Infos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          mouvement.produitNom,
                          style: AppTextStyles.headlineSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${isEntree ? '+' : '−'}${mouvement.quantite}',
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: couleur,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const VGap(2),
                  Text(
                    mouvement.motif,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const VGap(AppSpacing.xs),
                  Row(
                    children: [
                      const Icon(Symbols.person,
                          size: 14, color: AppColors.textTertiary),
                      const HGap(AppSpacing.xs),
                      Expanded(
                        child: Text(
                          '${mouvement.auteurNom} • $dateFormatee',
                          style: AppTextStyles.labelMedium
                              .copyWith(color: AppColors.textTertiary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        mouvement.synced
                            ? Symbols.cloud_done
                            : Symbols.cloud_upload,
                        size: 16,
                        color: mouvement.synced
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
