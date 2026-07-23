import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../../boutiques/providers/boutique_provider.dart';
import '../models/receipt_config.dart';
import '../providers/receipt_config_provider.dart';

/// Écran « Personnaliser le reçu » : édite les infos boutique affichées en
/// tête du ticket, un en-tête libre (slogan / RCCM / NCC), le message de pied
/// de page et les options d'affichage — avec un aperçu en direct.
class ReceiptConfigScreen extends ConsumerStatefulWidget {
  const ReceiptConfigScreen({super.key});

  @override
  ConsumerState<ReceiptConfigScreen> createState() =>
      _ReceiptConfigScreenState();
}

class _ReceiptConfigScreenState extends ConsumerState<ReceiptConfigScreen> {
  late final TextEditingController _nom;
  late final TextEditingController _adresse;
  late final TextEditingController _telephone;
  late final TextEditingController _entete;
  late final TextEditingController _pied;

  bool _afficherLogo = true;
  bool _afficherVendeur = true;
  bool _initialized = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Reconstruit l'aperçu à chaque frappe.
    void rebuild() => setState(() {});
    _nom = TextEditingController()..addListener(rebuild);
    _adresse = TextEditingController()..addListener(rebuild);
    _telephone = TextEditingController()..addListener(rebuild);
    _entete = TextEditingController()..addListener(rebuild);
    _pied = TextEditingController()..addListener(rebuild);
  }

  @override
  void dispose() {
    _nom.dispose();
    _adresse.dispose();
    _telephone.dispose();
    _entete.dispose();
    _pied.dispose();
    super.dispose();
  }

  /// Remplit les champs depuis la config sauvegardée, avec repli sur les
  /// infos de la boutique active pour les champs boutique non renseignés.
  void _hydrate(ReceiptConfig config, {String? bNom, String? bAdr, String? bTel}) {
    _nom.text = config.nomBoutique.isNotEmpty ? config.nomBoutique : (bNom ?? '');
    _adresse.text = config.adresse.isNotEmpty ? config.adresse : (bAdr ?? '');
    _telephone.text =
        config.telephone.isNotEmpty ? config.telephone : (bTel ?? '');
    _entete.text = config.entete;
    _pied.text = config.piedMessage;
    _afficherLogo = config.afficherLogo;
    _afficherVendeur = config.afficherVendeur;
  }

  ReceiptConfig _currentConfig() => ReceiptConfig(
        nomBoutique: _nom.text.trim(),
        adresse: _adresse.text.trim(),
        telephone: _telephone.text.trim(),
        entete: _entete.text.trim(),
        piedMessage: _pied.text.trim(),
        afficherLogo: _afficherLogo,
        afficherVendeur: _afficherVendeur,
      );

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(receiptConfigProvider.notifier).save(_currentConfig());
      if (mounted) {
        AppSnackbar.success(context, 'Reçu personnalisé enregistré.');
      }
    } catch (_) {
      if (mounted) AppSnackbar.error(context, 'Échec de l\'enregistrement.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _reset() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Réinitialiser le reçu'),
        content: const Text(
            'Rétablir la personnalisation par défaut ? Les infos de la '
            'boutique seront de nouveau utilisées.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Réinitialiser'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(receiptConfigProvider.notifier).reset();
    final b = ref.read(boutiqueInfoProvider).valueOrNull;
    setState(() {
      _hydrate(const ReceiptConfig(),
          bNom: b?.nom, bAdr: b?.adresse, bTel: b?.telephone);
    });
    if (mounted) AppSnackbar.info(context, 'Personnalisation réinitialisée.');
  }

  @override
  Widget build(BuildContext context) {
    // Backfill : si la boutique arrive après le premier rendu, remplit les
    // champs boutique encore vides (sans écraser une saisie de l'utilisateur).
    ref.listen(boutiqueInfoProvider, (_, next) {
      final b = next.valueOrNull;
      if (b == null) return;
      var changed = false;
      if (_nom.text.trim().isEmpty && b.nom.isNotEmpty) {
        _nom.text = b.nom;
        changed = true;
      }
      if (_adresse.text.trim().isEmpty && (b.adresse ?? '').isNotEmpty) {
        _adresse.text = b.adresse!;
        changed = true;
      }
      if (_telephone.text.trim().isEmpty && (b.telephone ?? '').isNotEmpty) {
        _telephone.text = b.telephone!;
        changed = true;
      }
      if (changed) setState(() {});
    });

    final configAsync = ref.watch(receiptConfigProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Personnaliser le reçu')),
      body: configAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Padding(
            padding: AppSpacing.pagePadding,
            child: Text(
              'Impossible de charger la personnalisation du reçu.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (config) {
          if (!_initialized) {
            final b = ref.read(boutiqueInfoProvider).valueOrNull;
            _hydrate(config,
                bNom: b?.nom, bAdr: b?.adresse, bTel: b?.telephone);
            _initialized = true;
          }
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              // ── Aperçu ──────────────────────────────────────────────────
              const _SectionTitle('APERÇU'),
              _ReceiptPreview(config: _currentConfig()),
              const VGap(AppSpacing.xl),

              // ── Infos boutique ──────────────────────────────────────────
              const _SectionTitle('INFOS BOUTIQUE'),
              _Field(
                controller: _nom,
                label: 'Nom de la boutique',
                icon: Symbols.storefront,
                textCapitalization: TextCapitalization.words,
              ),
              const VGap(AppSpacing.md),
              _Field(
                controller: _adresse,
                label: 'Adresse',
                icon: Symbols.location_on,
                textCapitalization: TextCapitalization.sentences,
              ),
              const VGap(AppSpacing.md),
              _Field(
                controller: _telephone,
                label: 'Téléphone',
                icon: Symbols.phone,
                keyboardType: TextInputType.phone,
              ),
              const VGap(AppSpacing.xl),

              // ── En-tête libre ───────────────────────────────────────────
              const _SectionTitle('EN-TÊTE (SLOGAN / RCCM / NCC)'),
              _Field(
                controller: _entete,
                label: 'Ligne(s) sous le nom',
                icon: Symbols.badge,
                hint: 'Ex. RCCM: CI-ABJ-2024-B-1234',
                maxLines: 3,
                maxLength: 120,
                textCapitalization: TextCapitalization.sentences,
              ),
              const VGap(AppSpacing.xl),

              // ── Pied de page ────────────────────────────────────────────
              const _SectionTitle('MESSAGE DE PIED DE PAGE'),
              _Field(
                controller: _pied,
                label: 'Message en bas du reçu',
                icon: Symbols.chat,
                hint: 'Ex. Merci de votre visite !',
                maxLines: 3,
                maxLength: 160,
                textCapitalization: TextCapitalization.sentences,
              ),
              const VGap(AppSpacing.xl),

              // ── Options ─────────────────────────────────────────────────
              const _SectionTitle('OPTIONS D\'AFFICHAGE'),
              _ToggleTile(
                icon: Symbols.image,
                title: 'Afficher le logo',
                value: _afficherLogo,
                onChanged: (v) => setState(() => _afficherLogo = v),
              ),
              const VGap(AppSpacing.sm),
              _ToggleTile(
                icon: Symbols.badge,
                title: 'Afficher le vendeur',
                value: _afficherVendeur,
                onChanged: (v) => setState(() => _afficherVendeur = v),
              ),
              const VGap(AppSpacing.xl),

              // ── Actions ─────────────────────────────────────────────────
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Symbols.save),
                label: Text(_saving ? 'Enregistrement...' : 'Enregistrer'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  minimumSize: const Size(double.infinity, AppSpacing.minTapTarget),
                  shape: const RoundedRectangleBorder(
                      borderRadius: AppSpacing.borderRadiusSm),
                ),
              ),
              const VGap(AppSpacing.xs),
              TextButton.icon(
                onPressed: _saving ? null : _reset,
                icon: const Icon(Symbols.restart_alt, size: 18),
                label: const Text('Réinitialiser'),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
              ),
              const VGap(AppSpacing.lg),
            ],
          );
        },
      ),
    );
  }
}

// ── Aperçu du reçu ─────────────────────────────────────────────────────────────

class _ReceiptPreview extends StatelessWidget {
  const _ReceiptPreview({required this.config});
  final ReceiptConfig config;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
    final nom = config.nomBoutique.trim().isNotEmpty
        ? config.nomBoutique.trim()
        : 'Ma boutique';
    final enteteLignes = config.entete
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          if (config.afficherLogo) ...[
            Image.asset('assets/images/logo.png', width: 56, height: 56),
            const SizedBox(height: 4),
          ],
          Text(nom,
              textAlign: TextAlign.center,
              style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 15)),
          for (final ligne in enteteLignes)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(ligne,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600)),
            ),
          if (config.adresse.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(config.adresse.trim(),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textSecondary)),
            ),
          if (config.telephone.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text('Tél : ${config.telephone.trim()}',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textSecondary)),
            ),
          if (config.afficherVendeur)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text('Vendeur : Awa',
                  style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600)),
            ),
          const SizedBox(height: 2),
          Text(date,
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textTertiary)),
          const _DashedLine(),
          // Ligne d'exemple
          const _PreviewRow(label: 'Sucre 1kg  x2', value: '1 000 F'),
          const _PreviewRow(label: 'Pain  x3', value: '450 F'),
          const _DashedLine(),
          const _PreviewRow(label: 'TOTAL', value: '1 450 F', bold: true),
          if (config.piedMessage.trim().isNotEmpty) ...[
            const _DashedLine(),
            Text(config.piedMessage.trim(),
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                    fontStyle: FontStyle.italic)),
          ],
        ],
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({required this.label, required this.value, this.bold = false});
  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.bodySmall.copyWith(
      color: bold ? AppColors.textPrimary : AppColors.textSecondary,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}

class _DashedLine extends StatelessWidget {
  const _DashedLine();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const dashWidth = 4.0;
          final count = (constraints.maxWidth / (dashWidth * 2)).floor();
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              count,
              (_) => const SizedBox(
                width: dashWidth,
                height: 1,
                child: DecoratedBox(
                    decoration: BoxDecoration(color: AppColors.border)),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Widgets de formulaire ──────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.maxLength,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? hint;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final int maxLines;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      maxLines: maxLines,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.borderLight)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.borderLight)),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: SwitchListTile(
        secondary: Icon(icon, color: AppColors.primary, size: 22),
        title: Text(title, style: AppTextStyles.bodyMedium),
        value: value,
        activeThumbColor: AppColors.primary,
        shape: const RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusMd),
        onChanged: onChanged,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm, top: AppSpacing.xs),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
