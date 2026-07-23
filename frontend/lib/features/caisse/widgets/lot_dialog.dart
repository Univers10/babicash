import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/caisse_provider.dart';

/// Dialogue de création d'un lot (prix de groupe) : on coche ≥ 2 articles du
/// panier et on fixe un prix total. Les articles déjà dans un lot ne sont pas
/// sélectionnables (dissoudre le lot d'abord).
class LotDialog extends ConsumerStatefulWidget {
  const LotDialog({super.key, this.indexInitial});

  /// Indice d'article pré-coché (déclencheur de l'appui long).
  final int? indexInitial;

  @override
  ConsumerState<LotDialog> createState() => _LotDialogState();
}

class _LotDialogState extends ConsumerState<LotDialog> {
  final _selection = <int>{};
  final _prixCtrl = TextEditingController();
  final _nomCtrl = TextEditingController(text: 'Lot');

  @override
  void initState() {
    super.initState();
    final panier = ref.read(panierProvider);
    final idx = widget.indexInitial;
    if (idx != null && idx < panier.length && !panier[idx].estDansLot) {
      _selection.add(idx);
    }
  }

  @override
  void dispose() {
    _prixCtrl.dispose();
    _nomCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final panier = ref.watch(panierProvider);
    // Indices des articles éligibles (hors lot existant).
    final eligibles = <int>[
      for (int i = 0; i < panier.length; i++)
        if (!panier[i].estDansLot) i,
    ];

    final prixNormal = _selection.fold<double>(
        0, (s, i) => s + panier[i].total);
    final prixLot = double.tryParse(_prixCtrl.text.replaceAll(',', '.')) ?? 0;
    final economie = prixNormal - prixLot;
    final valide = _selection.length >= 2 && prixLot > 0;

    return AlertDialog(
      title: const Text('Prix de groupe'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Choisir les articles du lot',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.xs),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final i in eligibles)
                    CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      value: _selection.contains(i),
                      onChanged: (v) => setState(() {
                        if (v == true) {
                          _selection.add(i);
                        } else {
                          _selection.remove(i);
                        }
                      }),
                      title: Text(panier[i].nom,
                          style: AppTextStyles.bodyMedium),
                      subtitle: Text(
                        '${panier[i].quantite} × ${panier[i].prixUnitaire.toStringAsFixed(0)} F',
                        style: AppTextStyles.caption,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _nomCtrl,
              decoration: const InputDecoration(
                labelText: 'Nom du lot',
                isDense: true,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _prixCtrl,
              autofocus: widget.indexInitial != null,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Prix total du lot (F)',
                isDense: true,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (_selection.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Prix normal : ${prixNormal.toStringAsFixed(0)} F',
                      style: AppTextStyles.caption),
                  if (prixLot > 0)
                    Text(
                      economie >= 0
                          ? 'Économie : ${economie.toStringAsFixed(0)} F'
                          : 'Majoration : ${(-economie).toStringAsFixed(0)} F',
                      style: AppTextStyles.caption.copyWith(
                        color: economie >= 0
                            ? AppColors.primary
                            : AppColors.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: valide
              ? () {
                  final nom = _nomCtrl.text.trim();
                  ref.read(panierProvider.notifier).creerLot(
                        _selection.toList(),
                        prixLot,
                        nom: nom.isEmpty ? 'Lot' : nom,
                      );
                  Navigator.of(context).pop();
                }
              : null,
          child: const Text('Créer le lot'),
        ),
      ],
    );
  }
}
