import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/boutique_model.dart';
import '../../../data/remote/boutiques_api.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/images/image_picker_field.dart';
import '../../../shared/images/image_upload_api.dart';
import '../../../shared/images/media_url.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../providers/boutique_provider.dart';

class BoutiquesScreen extends ConsumerWidget {
  const BoutiquesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boutiquesAsync = ref.watch(mesBoutiquesProvider);
    final currentUser = ref.watch(authStateProvider).value;
    final isOwner = currentUser?.isOwner == true;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Boutiques'),
        actions: [
          IconButton(
            icon: const Icon(Symbols.refresh),
            tooltip: 'Actualiser',
            onPressed: () => ref.invalidate(mesBoutiquesProvider),
          ),
        ],
      ),
      floatingActionButton: isOwner
          ? FloatingActionButton.extended(
              onPressed: () => _showBoutiqueDialog(context, ref),
              icon: const Icon(Symbols.add_business),
              label: const Text('Ajouter'),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            )
          : null,
      body: boutiquesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Symbols.error, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              const Text('Impossible de charger les boutiques', style: AppTextStyles.bodyMedium),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: () => ref.invalidate(mesBoutiquesProvider),
                icon: const Icon(Symbols.refresh),
                label: const Text('Réessayer'),
              ),
            ],
          ),
        ),
        data: (boutiques) {
          if (boutiques.isEmpty) {
            return const Center(
              child: Text('Aucune boutique trouvée', style: AppTextStyles.bodyMedium),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: boutiques.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) => _BoutiqueCard(
              boutique: boutiques[i],
              onEdit: () => _showBoutiqueDialog(context, ref, boutique: boutiques[i]),
            ),
          );
        },
      ),
    );
  }

  void _showBoutiqueDialog(BuildContext context, WidgetRef ref, {BoutiqueModel? boutique}) {
    showDialog(
      context: context,
      builder: (_) => _BoutiqueFormDialog(boutique: boutique, ref: ref),
    );
  }
}

// ── Formulaire ajout / édition ─────────────────────────────────────────────

class _BoutiqueFormDialog extends ConsumerStatefulWidget {
  const _BoutiqueFormDialog({required this.ref, this.boutique});
  final BoutiqueModel? boutique;
  final WidgetRef ref;

  @override
  ConsumerState<_BoutiqueFormDialog> createState() => _BoutiqueFormDialogState();
}

class _BoutiqueFormDialogState extends ConsumerState<_BoutiqueFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nom;
  late final TextEditingController _adresse;
  late final TextEditingController _telephone;
  late final TextEditingController _typeCommerce;
  bool _loading = false;

  // Logo : octets fraîchement choisis (à uploader) + indicateur de retrait.
  Uint8List? _pickedLogo;
  bool _logoRemoved = false;

  bool get _isEdit => widget.boutique != null;

  @override
  void initState() {
    super.initState();
    _nom = TextEditingController(text: widget.boutique?.nom ?? '');
    _adresse = TextEditingController(text: widget.boutique?.adresse ?? '');
    _telephone = TextEditingController(text: widget.boutique?.telephone ?? '');
    _typeCommerce = TextEditingController(text: widget.boutique?.typeCommerce ?? '');
  }

  @override
  void dispose() {
    _nom.dispose();
    _adresse.dispose();
    _telephone.dispose();
    _typeCommerce.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final api = ref.read(boutiquesApiProvider);
      final nom = _nom.text.trim();
      final adresse = _adresse.text.trim();
      final telephone = _telephone.text.trim();
      final typeCommerce = _typeCommerce.text.trim();

      // Upload du logo si une nouvelle image a été choisie.
      String? uploadedLogo;
      if (_pickedLogo != null) {
        uploadedLogo = await ref
            .read(imageUploadApiProvider)
            .uploadImage(_pickedLogo!, kind: 'logos');
      }

      if (_isEdit) {
        // logoUrl : nouvelle URL · '' pour retirer · null = inchangé.
        final logoUrl = uploadedLogo ?? (_logoRemoved ? '' : null);
        await api.updateBoutique(
          widget.boutique!.id,
          nom: nom,
          adresse: adresse,
          telephone: telephone,
          typeCommerce: typeCommerce,
          logoUrl: logoUrl,
        );
      } else {
        final created = await api.createBoutique(
          nom: nom,
          adresse: adresse.isNotEmpty ? adresse : null,
          telephone: telephone.isNotEmpty ? telephone : null,
          typeCommerce: typeCommerce.isNotEmpty ? typeCommerce : null,
        );
        // Le logo se pose après coup (l'endpoint de création ne le gère pas).
        if (uploadedLogo != null) {
          await api.updateBoutique(created.id, logoUrl: uploadedLogo);
        }
      }

      ref.invalidate(mesBoutiquesProvider);
      ref.invalidate(boutiqueInfoProvider);
      if (mounted) {
        Navigator.pop(context);
        AppSnackbar.success(
          context,
          _isEdit ? 'Boutique mise à jour.' : 'Boutique créée.',
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.error(context, _extractError(e));
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(
            _isEdit ? Symbols.edit : Symbols.add_business,
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          Text(_isEdit ? 'Modifier la boutique' : 'Nouvelle boutique'),
        ],
      ),
      content: SizedBox(
        width: 360,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo de la boutique (recadrage carré + compression)
                Center(
                  child: ImagePickerField(
                    imageUrl: _logoRemoved ? null : widget.boutique?.logoUrl,
                    pickedBytes: _pickedLogo,
                    placeholderIcon: Symbols.storefront,
                    onPicked: (bytes) => setState(() {
                      _pickedLogo = bytes;
                      _logoRemoved = false;
                    }),
                    onRemoved: () => setState(() {
                      _pickedLogo = null;
                      _logoRemoved = true;
                    }),
                  ),
                ),
                const SizedBox(height: 8),
                Text('Logo de la boutique',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textTertiary)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nom,
                  decoration: InputDecoration(
                    labelText: 'Nom de la boutique *',
                    prefixIcon: const Icon(Symbols.store),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _typeCommerce,
                  decoration: InputDecoration(
                    labelText: 'Type de commerce',
                    hintText: 'Ex: cosmétique, quincaillerie...',
                    prefixIcon: const Icon(Symbols.category),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _adresse,
                  decoration: InputDecoration(
                    labelText: 'Adresse',
                    prefixIcon: const Icon(Symbols.location_on),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _telephone,
                  decoration: InputDecoration(
                    labelText: 'Téléphone',
                    prefixIcon: const Icon(Symbols.phone),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        FilledButton.icon(
          icon: _loading
              ? const SizedBox(
                  width: 16, height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Icon(_isEdit ? Symbols.check : Symbols.add),
          onPressed: _loading ? null : _submit,
          label: Text(_isEdit ? 'Enregistrer' : 'Créer'),
        ),
      ],
    );
  }
}

// ── Carte boutique ──────────────────────────────────────────────────────────

class _BoutiqueCard extends ConsumerWidget {
  const _BoutiqueCard({required this.boutique, required this.onEdit});

  final BoutiqueModel boutique;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logoUrl = absoluteMediaUrl(ref.watch(apiOriginProvider), boutique.logoUrl);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 44,
              height: 44,
              color: AppColors.primaryContainer,
              child: logoUrl.isEmpty
                  ? const Icon(Symbols.store, color: AppColors.primary, size: 22)
                  : CachedNetworkImage(
                      imageUrl: logoUrl,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const Icon(Symbols.store,
                          color: AppColors.primary, size: 22),
                      errorWidget: (_, __, ___) => const Icon(Symbols.store,
                          color: AppColors.primary, size: 22),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(boutique.nom, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                if (boutique.typeCommerce != null && boutique.typeCommerce!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      boutique.typeCommerce!,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                if (boutique.adresse != null && boutique.adresse!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      boutique.adresse!,
                      style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                    ),
                  ),
                if (boutique.telephone != null && boutique.telephone!.isNotEmpty)
                  Text(
                    boutique.telephone!,
                    style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Symbols.edit, size: 20),
            color: AppColors.primary,
            tooltip: 'Modifier',
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────

String _extractError(Object e) {
  if (e is DioException && e.response?.data is Map) {
    final detail = (e.response!.data as Map)['detail'];
    if (detail is String) return detail;
    if (detail is Map && detail['message'] is String) return detail['message'] as String;
  }
  return 'Une erreur est survenue.';
}
