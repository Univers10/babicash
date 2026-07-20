import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/local/database.dart';
import '../../../shared/widgets/amount_text.dart';
import '../providers/sessions_provider.dart';

/// Historique des sessions de caisse fermées de la boutique courante.
class SessionHistoryScreen extends ConsumerWidget {
  const SessionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(sessionsFermeesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Historique des sessions'),
      ),
      body: sessionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('Erreur de chargement')),
        data: (sessions) {
          if (sessions.isEmpty) {
            return const _EmptyHistory();
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(sessionsFermeesProvider),
            child: ListView.separated(
              padding: AppSpacing.pagePadding,
              itemCount: sessions.length,
              separatorBuilder: (_, __) => const VGap(AppSpacing.sm),
              itemBuilder: (_, i) => _SessionCard(session: sessions[i]),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Symbols.history,
                size: 48, color: AppColors.textDisabled),
            const VGap(AppSpacing.md),
            Text(
              'Aucune session fermée',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
            const VGap(AppSpacing.xs),
            Text(
              'Les sessions apparaîtront ici après leur clôture.',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textTertiary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionCard extends ConsumerWidget {
  const _SessionCard({required this.session});
  final LocalSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totaux = ref.watch(ventesTotauxParSessionProvider).value ?? {};
    final totalVentes = totaux[session.id] ?? 0;
    final fmtDate = DateFormat('dd/MM/yyyy');
    final fmtHeure = DateFormat('HH:mm');
    final ouverture = session.dateOuverture.toLocal();
    final fermeture = session.dateFermeture?.toLocal();

    return Material(
      color: AppColors.surface,
      borderRadius: AppSpacing.borderRadiusLg,
      child: InkWell(
        borderRadius: AppSpacing.borderRadiusLg,
        onTap: () =>
            context.push('${AppRoutes.sessions}/details/${session.id}'),
        child: Container(
          padding: AppSpacing.cardPadding,
          decoration: BoxDecoration(
            borderRadius: AppSpacing.borderRadiusLg,
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: AppSpacing.borderRadiusMd,
                ),
                child: const Icon(Symbols.point_of_sale,
                    size: 22, color: AppColors.primary),
              ),
              const HGap(AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fmtDate.format(ouverture),
                      style: AppTextStyles.labelLarge,
                    ),
                    const VGap(AppSpacing.xs),
                    Text(
                      '${fmtHeure.format(ouverture)}'
                      '${fermeture != null ? ' → ${fmtHeure.format(fermeture)}' : ''}'
                      ' · ${session.utilisateurNom}',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const HGap(AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AmountText.format(totalVentes),
                    style: AppTextStyles.labelMedium
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                  const VGap(AppSpacing.xs),
                  Text(
                    'Ventes',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textTertiary),
                  ),
                ],
              ),
              const HGap(AppSpacing.xs),
              const Icon(Symbols.chevron_right,
                  size: 20, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
