import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/local/database.dart';
import '../domain/stock_calculator.dart';
import '../providers/mouvements_provider.dart';

/// Dialog « Entrée de stock / Sortie de stock » (S2).
/// Remplace l'édition directe de la quantité : le stock du produit est
/// recalculé à partir du mouvement (quantité + motif), tracé dans le journal.
class MouvementStockDialog extends ConsumerStatefulWidget {
  const MouvementStockDialog({
    super.key,
    required this.produit,
    this.typeInitial = TypeMouvementStock.entree,
  });

  final LocalProduit produit;
  final String typeInitial;

  @override
  ConsumerState<MouvementStockDialog> createState() =>
      _MouvementStockDialogState();
}

class _MouvementStockDialogState extends ConsumerState<MouvementStockDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantiteController = TextEditingController();
  final _motifController = TextEditingController();
  late String _type = widget.typeInitial;
  bool _isLoading = false;

  @override
  void dispose() {
    _quantiteController.dispose();
    _motifController.dispose();
    super.dispose();
  }

  bool get _isEntree => _type == TypeMouvementStock.entree;

  int? get _quantite => int.tryParse(_quantiteController.text.trim());

  int? get _nouveauStock {
    final q = _quantite;
    if (q == null || q <= 0) return null;
    return recalculerStock(
      stockActuel: widget.produit.stockActuel,
      typeMouvement: _type,
      quantite: q,
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(mouvementsCrudProvider.notifier).enregistrerMouvement(
            produit: widget.produit,
            typeMouvement: _type,
            quantite: _quantite!,
            motif: _motifController.text.trim(),
          );
      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEntree
                ? 'Entrée de stock enregistrée'
                : 'Sortie de stock enregistrée'),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Erreur lors de l\'enregistrement du mouvement')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final couleurType = _isEntree ? AppColors.success : AppColors.error;
    final nouveauStock = _nouveauStock;

    return AlertDialog(
      title: Text('Mouvement de stock', style: AppTextStyles.headlineSmall),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.produit.nom,
                style: AppTextStyles.bodyMedium
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              const VGap(AppSpacing.xs),
              Text(
                'Stock actuel : ${widget.produit.stockActuel}',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
              ),
              const VGap(AppSpacing.lg),

              // ── Type de mouvement ─────────────────────────────────────
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: TypeMouvementStock.entree,
                    label: Text('Entrée'),
                    icon: Icon(Symbols.add_box, size: 18),
                  ),
                  ButtonSegment(
                    value: TypeMouvementStock.sortie,
                    label: Text('Sortie'),
                    icon: Icon(Symbols.indeterminate_check_box, size: 18),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (s) => setState(() => _type = s.first),
              ),
              const VGap(AppSpacing.lg),

              // ── Quantité ──────────────────────────────────────────────
              TextFormField(
                controller: _quantiteController,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Quantité'),
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                validator: (v) {
                  final q = int.tryParse((v ?? '').trim());
                  if (q == null || q <= 0) return 'Quantité invalide';
                  if (_type == TypeMouvementStock.sortie &&
                      sortieDepasseStock(
                          stockActuel: widget.produit.stockActuel,
                          quantite: q)) {
                    return 'Stock insuffisant (${widget.produit.stockActuel} disponible)';
                  }
                  return null;
                },
              ),
              const VGap(AppSpacing.md),

              // ── Motif ─────────────────────────────────────────────────
              TextFormField(
                controller: _motifController,
                decoration: InputDecoration(
                  labelText: 'Motif',
                  hintText: _isEntree
                      ? 'Ex : livraison fournisseur'
                      : 'Ex : casse, périmé, don…',
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Motif requis' : null,
              ),

              // ── Aperçu du nouveau stock ───────────────────────────────
              if (nouveauStock != null) ...[
                const VGap(AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: couleurType.withValues(alpha: 0.10),
                    borderRadius: AppSpacing.borderRadiusSm,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isEntree
                            ? Symbols.trending_up
                            : Symbols.trending_down,
                        size: 18,
                        color: couleurType,
                      ),
                      const HGap(AppSpacing.sm),
                      Text(
                        'Nouveau stock : $nouveauStock',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: couleurType,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton.icon(
          onPressed: _isLoading ? null : _submit,
          style: FilledButton.styleFrom(backgroundColor: couleurType),
          icon: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Symbols.save, size: 18),
          label: Text(_isEntree ? 'Enregistrer l\'entrée' : 'Enregistrer la sortie'),
        ),
      ],
    );
  }
}
