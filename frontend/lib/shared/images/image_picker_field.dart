import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'image_pipeline.dart';
import 'media_url.dart';

/// Champ réutilisable de sélection d'image (produit, logo…).
///
/// Affiche l'image courante (octets fraîchement choisis, sinon URL distante,
/// sinon un emplacement vide) et propose galerie / appareil photo / retirer.
/// Le parent conserve l'état ([pickedBytes] / [imageUrl]) : le champ notifie
/// via [onPicked] (nouvelle image prête) et [onRemoved] (image retirée).
class ImagePickerField extends ConsumerWidget {
  const ImagePickerField({
    super.key,
    this.imageUrl,
    this.pickedBytes,
    required this.onPicked,
    this.onRemoved,
    this.size = 104,
    this.placeholderIcon = Symbols.add_a_photo,
  });

  /// URL distante existante (éventuellement relative `/static/...`).
  final String? imageUrl;

  /// Octets d'une image choisie mais pas encore uploadée.
  final Uint8List? pickedBytes;

  final void Function(Uint8List bytes) onPicked;
  final VoidCallback? onRemoved;
  final double size;
  final IconData placeholderIcon;

  bool get _hasImage =>
      pickedBytes != null || (imageUrl != null && imageUrl!.trim().isNotEmpty);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final origin = ref.watch(apiOriginProvider);
    final absUrl = absoluteMediaUrl(origin, imageUrl);

    Widget content;
    if (pickedBytes != null) {
      content =
          Image.memory(pickedBytes!, width: size, height: size, fit: BoxFit.cover);
    } else if (absUrl.isNotEmpty) {
      content = CachedNetworkImage(
        imageUrl: absUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (_, __) => _Skeleton(size: size),
        errorWidget: (_, __, ___) => _Placeholder(icon: placeholderIcon, size: size),
      );
    } else {
      content = _Placeholder(icon: placeholderIcon, size: size);
    }

    return Stack(
      children: [
        GestureDetector(
          onTap: () => _openSheet(context),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
              ),
              clipBehavior: Clip.hardEdge,
              child: content,
            ),
          ),
        ),
        Positioned(
          right: 4,
          bottom: 4,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Icon(_hasImage ? Symbols.edit : Symbols.add,
                size: 14, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Future<void> _openSheet(BuildContext context) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Symbols.photo_library, color: AppColors.primary),
              title: const Text('Galerie'),
              onTap: () => Navigator.pop(ctx, 'gallery'),
            ),
            ListTile(
              leading: const Icon(Symbols.photo_camera, color: AppColors.primary),
              title: const Text('Appareil photo'),
              onTap: () => Navigator.pop(ctx, 'camera'),
            ),
            if (_hasImage)
              ListTile(
                leading: const Icon(Symbols.delete, color: AppColors.error),
                title: Text('Retirer l\'image',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.error)),
                onTap: () => Navigator.pop(ctx, 'remove'),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (action == null) return;
    if (action == 'remove') {
      onRemoved?.call();
      return;
    }
    final source = action == 'camera' ? ImageSource.camera : ImageSource.gallery;
    if (!context.mounted) return;
    final bytes = await ImagePipeline.pickCropCompress(context, source: source);
    if (bytes != null) onPicked(bytes);
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.icon, required this.size});
  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Icon(icon, size: size * 0.32, color: AppColors.textTertiary),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}
