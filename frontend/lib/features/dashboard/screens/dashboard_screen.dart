import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/widgets/amount_text.dart';

// ── Providers données dashboard ───────────────────────────────────────────────

final _consolideProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null || !user.isOwner) return null;
  final dio = ref.watch(dioProvider);
  try {
    final resp = await dio.get('/dashboard/consolide');
    return resp.data as Map<String, dynamic>;
  } on DioException catch (e) {
    throw mapDioError(e);
  }
});

final _granulariteProvider = StateProvider<String>((_) => 'mois');

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consolideAsync = ref.watch(_consolideProvider);
    final granularite = ref.watch(_granulariteProvider);
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dashboard'),
            if (user != null)
              Text(user.nom, style: AppTextStyles.caption),
          ],
        ),
        actions: [
          // Sélecteur période
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.lg),
            child: _PeriodeSelector(
              selected: granularite,
              onChanged: (v) =>
                  ref.read(_granulariteProvider.notifier).state = v,
            ),
          ),
        ],
      ),
      body: consolideAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) {
          final msg = e is AppException ? e.message : 'Erreur de chargement';
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Symbols.cloud_off,
                    size: 48, color: AppColors.textTertiary),
                const VGap(AppSpacing.lg),
                Text(msg,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center),
                const VGap(AppSpacing.lg),
                TextButton.icon(
                  onPressed: () => ref.invalidate(_consolideProvider),
                  icon: const Icon(Symbols.refresh),
                  label: const Text('Réessayer'),
                ),
              ],
            ),
          );
        },
        data: (data) {
          if (data == null) {
            return const Center(
                child: Text('Accès réservé au propriétaire.'));
          }
          return _DashboardBody(data: data);
        },
      ),
    );
  }
}

// ── Corps dashboard ───────────────────────────────────────────────────────────

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final boutiques = data['boutiques'] as List? ?? [];
    final caTotal =
        (data['ca_total'] as num?)?.toDouble() ?? 0;
    final margeTotal =
        (data['marge_nette_totale'] as num?)?.toDouble() ?? 0;
    final nbVentes = (data['nb_ventes_total'] as num?)?.toInt() ?? 0;

    return RefreshIndicator(
      onRefresh: () async {},
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // Bannière CA global
          _HeroBanner(
            ca: caTotal,
            marge: margeTotal,
            nbVentes: nbVentes,
          ),
          const VGap(AppSpacing.xl),

          // Titre boutiques
          Text(
            '${boutiques.length} boutique${boutiques.length > 1 ? 's' : ''}',
            style: AppTextStyles.headlineSmall
                .copyWith(color: AppColors.textSecondary),
          ),
          const VGap(AppSpacing.md),

          // Cards par boutique
          ...boutiques.map((b) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _BoutiqueCard(boutique: b as Map<String, dynamic>),
              )),
        ],
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({
    required this.ca,
    required this.marge,
    required this.nbVentes,
  });
  final double ca;
  final double marge;
  final int nbVentes;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppSpacing.borderRadiusXl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Chiffre d\'affaires',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: Colors.white70)),
          const VGap(AppSpacing.xs),
          AmountText(
            amount: ca,
            style: AppTextStyles.amountHero
                .copyWith(color: Colors.white),
          ),
          const VGap(AppSpacing.lg),
          Row(
            children: [
              _MiniKpi(
                label: 'Marge nette',
                value: AmountText.format(marge),
                icon: Symbols.trending_up,
              ),
              const HGap(AppSpacing.xl),
              _MiniKpi(
                label: 'Ventes',
                value: '$nbVentes',
                icon: Symbols.receipt,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniKpi extends StatelessWidget {
  const _MiniKpi({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white70),
        const HGap(AppSpacing.xs),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: Colors.white70)),
            Text(value,
                style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ],
        ),
      ],
    );
  }
}

class _BoutiqueCard extends StatelessWidget {
  const _BoutiqueCard({required this.boutique});
  final Map<String, dynamic> boutique;

  @override
  Widget build(BuildContext context) {
    final nom = boutique['boutique_nom'] as String? ?? '—';
    final ca = (boutique['ca'] as num?)?.toDouble() ?? 0;
    final marge = (boutique['marge_nette'] as num?)?.toDouble() ?? 0;
    final nbVentes = (boutique['nb_ventes'] as num?)?.toInt() ?? 0;

    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: AppSpacing.borderRadiusMd,
                  ),
                  child: const Icon(Symbols.store,
                      size: 18, color: AppColors.primary),
                ),
                const HGap(AppSpacing.md),
                Expanded(
                  child: Text(nom,
                      style: AppTextStyles.headlineSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
                Text(
                  '$nbVentes vente${nbVentes > 1 ? 's' : ''}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
            const VGap(AppSpacing.md),
            const Divider(height: 1),
            const VGap(AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _KpiCell(
                    label: 'CA',
                    value: AmountText.format(ca),
                    color: AppColors.primary,
                  ),
                ),
                Expanded(
                  child: _KpiCell(
                    label: 'Marge nette',
                    value: AmountText.format(marge),
                    color: marge >= 0
                        ? AppColors.success
                        : AppColors.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _KpiCell extends StatelessWidget {
  const _KpiCell({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.caption
                .copyWith(color: AppColors.textSecondary)),
        const VGap(2),
        Text(value,
            style: AppTextStyles.amountMedium.copyWith(color: color)),
      ],
    );
  }
}

// ── Sélecteur de période ──────────────────────────────────────────────────────

class _PeriodeSelector extends StatelessWidget {
  const _PeriodeSelector({
    required this.selected,
    required this.onChanged,
  });
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    const options = ['jour', 'semaine', 'mois'];
    final labels = {'jour': 'Jour', 'semaine': 'Sem.', 'mois': 'Mois'};

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: AppSpacing.borderRadiusFull,
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: options.map((opt) {
          final isSelected = opt == selected;
          return GestureDetector(
            onTap: () => onChanged(opt),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: AppSpacing.borderRadiusFull,
              ),
              child: Text(
                labels[opt]!,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color:
                      isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
