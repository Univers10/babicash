import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class NumpadWidget extends StatefulWidget {
  const NumpadWidget({super.key, required this.onMontantValide});
  final void Function(double) onMontantValide;

  @override
  State<NumpadWidget> createState() => _NumpadWidgetState();
}

class _NumpadWidgetState extends State<NumpadWidget> {
  String _valeur = '';

  double get _montant =>
      double.tryParse(_valeur.replaceAll(' ', '')) ?? 0;

  void _append(String v) {
    if (_valeur.length >= 10) return;
    setState(() => _valeur += v);
  }

  void _backspace() {
    if (_valeur.isEmpty) return;
    setState(() => _valeur = _valeur.substring(0, _valeur.length - 1));
  }

  void _clear() => setState(() => _valeur = '');

  void _add() {
    if (_montant <= 0) return;
    widget.onMontantValide(_montant);
    _clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Affichage montant
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(AppSpacing.lg),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xxl, vertical: AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppSpacing.borderRadiusLg,
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _valeur.isEmpty ? '0' : _valeur,
                style: AppTextStyles.amountHero,
              ),
              const Text('FCFA', style: AppTextStyles.caption),
            ],
          ),
        ),

        // Pavé numérique
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              children: [
                _buildRow(['7', '8', '9']),
                const VGap(AppSpacing.sm),
                _buildRow(['4', '5', '6']),
                const VGap(AppSpacing.sm),
                _buildRow(['1', '2', '3']),
                const VGap(AppSpacing.sm),
                Row(
                  children: [
                    _NumKey(
                      label: '⌫',
                      icon: Symbols.backspace,
                      onTap: _backspace,
                      onLongPress: _clear,
                      color: AppColors.surfaceVariant,
                      textColor: AppColors.error,
                    ),
                    const HGap(AppSpacing.sm),
                    _NumKey(label: '0', onTap: () => _append('0')),
                    const HGap(AppSpacing.sm),
                    _NumKey(
                      label: '+',
                      icon: Symbols.add_shopping_cart,
                      onTap: _add,
                      color: AppColors.accent,
                      textColor: Colors.white,
                    ),
                  ],
                ),
                const VGap(AppSpacing.lg),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Row _buildRow(List<String> keys) {
    return Row(
      children: keys
          .map((k) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: _NumKey(
                    label: k,
                    onTap: () => _append(k),
                  ),
                ),
              ))
          .toList()
        ..last = Expanded(
          child: _NumKey(
            label: keys.last,
            onTap: () => _append(keys.last),
          ),
        ),
    );
  }
}

class _NumKey extends StatelessWidget {
  const _NumKey({
    required this.label,
    this.icon,
    required this.onTap,
    this.onLongPress,
    this.color,
    this.textColor,
  });

  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Color? color;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? AppColors.surface,
      borderRadius: AppSpacing.borderRadiusMd,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: AppSpacing.borderRadiusMd,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: AppSpacing.borderRadiusMd,
            border: Border.all(color: AppColors.borderLight),
          ),
          alignment: Alignment.center,
          child: icon != null
              ? Icon(icon, size: 20, color: textColor ?? AppColors.textPrimary)
              : Text(
                  label,
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: textColor ?? AppColors.textPrimary,
                  ),
                ),
        ),
      ),
    );
  }
}
