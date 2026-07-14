import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/amount_text.dart';
import '../models/panier_item.dart';
import '../providers/caisse_provider.dart';

class PanierWidget extends ConsumerWidget {
  const PanierWidget({super.key, required this.items});
  final List<PanierItem> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.borderLight)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        itemCount: items.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, indent: AppSpacing.lg),
        itemBuilder: (_, i) => _PanierLine(item: items[i], index: i),
      ),
    );
  }
}

class _PanierLine extends ConsumerWidget {
  const _PanierLine({required this.item, required this.index});
  final PanierItem item;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey('$index-${item.nom}'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: AppColors.errorContainer,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        child: const Icon(Symbols.delete, color: AppColors.error),
      ),
      onDismissed: (_) =>
          ref.read(panierProvider.notifier).remove(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        child: Row(
          children: [
            // Avertissement vente à perte
            if (item.aVendreAPerte)
              const Padding(
                padding: EdgeInsets.only(right: AppSpacing.sm),
                child: Icon(Symbols.warning,
                    size: 16, color: AppColors.error),
              ),

            // Nom
            Expanded(
              child: Text(
                item.nom,
                style: AppTextStyles.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Quantité
            _QteButton(
              onDecrement: () => ref
                  .read(panierProvider.notifier)
                  .updateQuantite(index, item.quantite - 1),
              onIncrement: () => ref
                  .read(panierProvider.notifier)
                  .updateQuantite(index, item.quantite + 1),
              quantite: item.quantite,
            ),
            const HGap(AppSpacing.md),

            // Total ligne
            AmountText(
              amount: item.total,
              style: AppTextStyles.labelLarge,
              showCurrency: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _QteButton extends StatelessWidget {
  const _QteButton({
    required this.quantite,
    required this.onDecrement,
    required this.onIncrement,
  });
  final int quantite;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SmallBtn(icon: Symbols.remove, onTap: onDecrement),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Text('$quantite', style: AppTextStyles.labelLarge),
        ),
        _SmallBtn(icon: Symbols.add, onTap: onIncrement),
      ],
    );
  }
}

class _SmallBtn extends StatelessWidget {
  const _SmallBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppSpacing.borderRadiusFull,
      child: Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: AppSpacing.borderRadiusFull,
        ),
        child: Icon(icon, size: 16, color: AppColors.textSecondary),
      ),
    );
  }
}
