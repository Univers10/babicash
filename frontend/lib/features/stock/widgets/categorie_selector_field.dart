import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/text_normalizer.dart';
import '../../../data/local/database.dart';
import '../../../shared/utils/categorie_utils.dart';

/// Champ de sélection de catégorie avec recherche.
///
/// Affiche la catégorie sélectionnée dans un champ de formulaire ; au tap,
/// ouvre une feuille avec un champ de recherche (insensible à la casse et
/// aux accents) qui filtre la liste — utilisable avec 50+ catégories.
/// La valeur `null` correspond à « Sans catégorie ».
class CategorieSelectorField extends StatelessWidget {
  const CategorieSelectorField({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onChanged,
  });

  /// Catégories sélectionnables (déjà triées par le provider).
  final List<LocalCategory> categories;

  /// Id de la catégorie sélectionnée, `null` = « Sans catégorie ».
  final String? selectedId;

  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    LocalCategory? selectionnee;
    for (final c in categories) {
      if (c.id == selectedId) {
        selectionnee = c;
        break;
      }
    }
    final libelle = selectionnee?.nom ?? sansCategorieLabel;

    return InkWell(
      borderRadius: const BorderRadius.all(Radius.circular(AppSpacing.radiusSm)),
      onTap: () => _ouvrirSelecteur(context),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Catégorie',
          suffixIcon: Icon(Symbols.arrow_drop_down),
        ),
        child: Text(libelle, style: AppTextStyles.bodyMedium),
      ),
    );
  }

  Future<void> _ouvrirSelecteur(BuildContext context) async {
    final resultat = await showModalBottomSheet<_ChoixCategorie>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CategorieSearchSheet(
        categories: categories,
        selectedId: selectedId,
      ),
    );
    if (resultat != null) onChanged(resultat.id);
  }
}

/// Enveloppe le choix pour distinguer « feuille fermée sans choisir »
/// (résultat `null`) de « Sans catégorie » choisi (`_ChoixCategorie(null)`).
class _ChoixCategorie {
  const _ChoixCategorie(this.id);
  final String? id;
}

class _CategorieSearchSheet extends StatefulWidget {
  const _CategorieSearchSheet({
    required this.categories,
    required this.selectedId,
  });

  final List<LocalCategory> categories;
  final String? selectedId;

  @override
  State<_CategorieSearchSheet> createState() => _CategorieSearchSheetState();
}

class _CategorieSearchSheetState extends State<_CategorieSearchSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtre = normaliserTexte(_query);
    final visibles = filtre.isEmpty
        ? widget.categories
        : widget.categories
            .where((c) => normaliserTexte(c.nom).contains(filtre))
            .toList();
    final montrerSansCategorie =
        filtre.isEmpty || normaliserTexte(sansCategorieLabel).contains(filtre);

    final hauteurMax = MediaQuery.sizeOf(context).height * 0.7;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Material(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXl)),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: hauteurMax),
          child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Poignée
            Container(
              margin: const EdgeInsets.only(top: AppSpacing.md),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
              child: Row(
                children: [
                  const Icon(Symbols.category,
                      color: AppColors.primary, size: 22),
                  const HGap(AppSpacing.md),
                  const Text('Choisir une catégorie',
                      style: AppTextStyles.headlineSmall),
                ],
              ),
            ),
            // Champ de recherche
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Rechercher une catégorie...',
                  hintStyle: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textTertiary),
                  prefixIcon: const Icon(Symbols.search, size: 20),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Symbols.close, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                  isDense: true,
                ),
              ),
            ),
            const Divider(height: 1),
            // Liste filtrée
            Flexible(
              child: (visibles.isEmpty && !montrerSansCategorie)
                  ? Padding(
                      padding: const EdgeInsets.all(AppSpacing.xxl),
                      child: Text(
                        'Aucune catégorie trouvée',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textTertiary),
                      ),
                    )
                  : ListView(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sm),
                      children: [
                        if (montrerSansCategorie)
                          _CategorieTile(
                            label: sansCategorieLabel,
                            icon: Symbols.label_off,
                            isSelected: widget.selectedId == null,
                            onTap: () => Navigator.of(context)
                                .pop(const _ChoixCategorie(null)),
                          ),
                        for (final c in visibles)
                          _CategorieTile(
                            label: c.nom,
                            icon: Symbols.label,
                            isSelected: widget.selectedId == c.id,
                            onTap: () => Navigator.of(context)
                                .pop(_ChoixCategorie(c.id)),
                          ),
                      ],
                    ),
            ),
          ],
          ),
        ),
      ),
    );
  }
}

class _CategorieTile extends StatelessWidget {
  const _CategorieTile({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon,
          size: 20,
          color: isSelected ? AppColors.primary : AppColors.textTertiary),
      title: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
      trailing: isSelected
          ? const Icon(Symbols.check, color: AppColors.primary, size: 20)
          : null,
      onTap: onTap,
    );
  }
}
