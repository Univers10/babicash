import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/local/database.dart';
import '../providers/produits_crud_provider.dart';
import '../providers/stock_provider.dart';

class ProduitFormDialog extends ConsumerStatefulWidget {
  const ProduitFormDialog({super.key, this.produit});
  final LocalProduit? produit;

  @override
  ConsumerState<ProduitFormDialog> createState() => _ProduitFormDialogState();
}

class _ProduitFormDialogState extends ConsumerState<ProduitFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _nomController = TextEditingController(text: widget.produit?.nom);
  late final _achatController = TextEditingController(
      text: widget.produit?.prixAchatMoyen.toString() ?? '0');
  late final _venteController = TextEditingController(
      text: widget.produit?.prixVenteSuggere.toString() ?? '0');
  late final _stockController = TextEditingController(
      text: widget.produit?.stockActuel.toString() ?? '0');
  late final _alerteController = TextEditingController(
      text: widget.produit?.stockAlerte.toString() ?? '5');
  String? _categorieId;
  bool _isLoading = false;

  @override
  void dispose() {
    _nomController.dispose();
    _achatController.dispose();
    _venteController.dispose();
    _stockController.dispose();
    _alerteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final nom = _nomController.text.trim();
    final prixAchat = double.tryParse(_achatController.text) ?? 0;
    final prixVente = double.tryParse(_venteController.text) ?? 0;
    final stock = int.tryParse(_stockController.text) ?? 0;
    final stockAlerte = int.tryParse(_alerteController.text) ?? 5;

    try {
      final notifier = ref.read(produitsCrudProvider.notifier);
      if (widget.produit == null) {
        await notifier.createProduit(
          nom: nom,
          categorieId: _categorieId,
          prixAchat: prixAchat,
          prixVente: prixVente,
          stock: stock,
          stockAlerte: stockAlerte,
        );
      } else {
        // La quantité en stock n'est plus éditable ici (S2) :
        // elle est recalculée via les mouvements d'entrée / sortie.
        await notifier.updateProduit(
          id: widget.produit!.id,
          nom: nom,
          categorieId: _categorieId,
          prixAchat: prixAchat,
          prixVente: prixVente,
          stockAlerte: stockAlerte,
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la sauvegarde')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    return AlertDialog(
      title: Text(widget.produit == null ? 'Nouveau produit' : 'Modifier produit',
          style: AppTextStyles.headlineSmall),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Requis' : null,
              ),
              const VGap(AppSpacing.md),
              categoriesAsync.when(
                data: (cats) => DropdownButtonFormField<String?>(
                  initialValue: _categorieId,
                  decoration: const InputDecoration(labelText: 'Catégorie'),
                  items: [
                    const DropdownMenuItem(
                        value: null, child: Text('Sans catégorie')),
                    ...cats.map((c) => DropdownMenuItem(
                        value: c.id, child: Text(c.nom))),
                  ],
                  onChanged: (v) => setState(() => _categorieId = v),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('Erreur catégories'),
              ),
              const VGap(AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _achatController,
                      decoration: const InputDecoration(labelText: 'Prix achat'),
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          (double.tryParse(v ?? '') ?? -1) < 0 ? 'Invalide' : null,
                    ),
                  ),
                  const HGap(AppSpacing.md),
                  Expanded(
                    child: TextFormField(
                      controller: _venteController,
                      decoration: const InputDecoration(labelText: 'Prix vente'),
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          (double.tryParse(v ?? '') ?? -1) < 0 ? 'Invalide' : null,
                    ),
                  ),
                ],
              ),
              const VGap(AppSpacing.md),
              Row(
                children: [
                  // Le stock initial n'est saisi qu'à la création (S2) ;
                  // ensuite il évolue uniquement via les mouvements.
                  if (widget.produit == null) ...[
                    Expanded(
                      child: TextFormField(
                        controller: _stockController,
                        decoration:
                            const InputDecoration(labelText: 'Stock initial'),
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            (int.tryParse(v ?? '') ?? -1) < 0 ? 'Invalide' : null,
                      ),
                    ),
                    const HGap(AppSpacing.md),
                  ],
                  Expanded(
                    child: TextFormField(
                      controller: _alerteController,
                      decoration: const InputDecoration(labelText: 'Alerte'),
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          (int.tryParse(v ?? '') ?? -1) < 0 ? 'Invalide' : null,
                    ),
                  ),
                ],
              ),
              if (widget.produit != null) ...[
                const VGap(AppSpacing.md),
                Text(
                  'Stock actuel : ${widget.produit!.stockActuel} — modifiable '
                  'uniquement via « Entrée / Sortie de stock »',
                  style: AppTextStyles.bodyMedium,
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
          icon: _isLoading
              ? const SizedBox(
                  width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Symbols.save, size: 18),
          label: Text(widget.produit == null ? 'Créer' : 'Enregistrer'),
        ),
      ],
    );
  }
}
