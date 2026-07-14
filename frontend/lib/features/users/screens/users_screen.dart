import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/user_model.dart';
import '../../../data/remote/users_api.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/boutiques/providers/boutique_provider.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../providers/users_provider.dart';

class UsersScreen extends ConsumerWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final utilisateursAsync = ref.watch(utilisateursProvider);
    final currentUser = ref.watch(authStateProvider).value;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Équipe'),
        actions: [
          IconButton(
            icon: const Icon(Symbols.refresh),
            tooltip: 'Actualiser',
            onPressed: () => ref.invalidate(utilisateursProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUserDialog(context, ref),
        icon: const Icon(Symbols.person_add),
        label: const Text('Ajouter'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: utilisateursAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Symbols.error, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              const Text('Impossible de charger l\'équipe', style: AppTextStyles.bodyMedium),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: () => ref.invalidate(utilisateursProvider),
                icon: const Icon(Symbols.refresh),
                label: const Text('Réessayer'),
              ),
            ],
          ),
        ),
        data: (users) {
          if (users.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Symbols.group, size: 64, color: AppColors.textDisabled),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun utilisateur',
                    style: AppTextStyles.headlineMedium.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ajoutez des gérants pour votre boutique',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: users.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final user = users[i];
              // Le manager ne peut pas supprimer le propriétaire
              final canDelete = currentUser?.isOwner == true ||
                  (currentUser?.isManager == true && !user.isOwner);

              return _UserCard(
                user: user,
                canDelete: canDelete,
                onEdit: () => _showUserDialog(context, ref, user: user),
                onDelete: () => _showDeleteDialog(context, ref, user),
              );
            },
          );
        },
      ),
    );
  }

  // ── Dialogs ────────────────────────────────────────────────────────────────

  void _showUserDialog(BuildContext context, WidgetRef ref, {UserProfile? user}) {
    showDialog(
      context: context,
      builder: (_) => _UserFormDialog(user: user, ref: ref),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, UserProfile user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Symbols.warning, color: AppColors.error),
            SizedBox(width: 12),
            Text('Supprimer ?'),
          ],
        ),
        content: Text(
          'Voulez-vous supprimer "${user.nom}" ?\nCette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          FilledButton.icon(
            icon: const Icon(Symbols.delete),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              await _deleteUser(context, ref, user);
            },
            label: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUser(BuildContext context, WidgetRef ref, UserProfile user) async {
    try {
      await ref.read(usersApiProvider).deleteUtilisateur(user.id);
      ref.invalidate(utilisateursProvider);
      if (context.mounted) {
        AppSnackbar.success(context, '${user.nom} a été supprimé.');
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackbar.error(context, _extractError(e));
      }
    }
  }
}

// ── Formulaire ajout / édition ─────────────────────────────────────────────

class _UserFormDialog extends ConsumerStatefulWidget {
  const _UserFormDialog({required this.ref, this.user});
  final UserProfile? user;
  final WidgetRef ref;

  @override
  ConsumerState<_UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends ConsumerState<_UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nom;
  late final TextEditingController _email;
  late final TextEditingController _telephone;
  late final TextEditingController _codePin;
  bool _loading = false;
  bool _obscurePin = true; // mutable: toggle visibility du PIN

  bool get _isEdit => widget.user != null;

  @override
  void initState() {
    super.initState();
    _nom = TextEditingController(text: widget.user?.nom ?? '');
    _email = TextEditingController(text: widget.user?.email ?? '');
    _telephone = TextEditingController(text: widget.user?.telephone ?? '');
    _codePin = TextEditingController();
  }

  @override
  void dispose() {
    _nom.dispose();
    _email.dispose();
    _telephone.dispose();
    _codePin.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final api = ref.read(usersApiProvider);
      final boutiqueId = await ref.read(currentBoutiqueIdProvider.future);

      if (_isEdit) {
        await api.updateUtilisateur(
          widget.user!.id,
          nom: _nom.text.trim(),
          telephone: _telephone.text.trim().isNotEmpty ? _telephone.text.trim() : null,
          codePin: _codePin.text.isNotEmpty ? _codePin.text : null,
        );
      } else {
        await api.createUtilisateur(
          nom: _nom.text.trim(),
          telephone: _telephone.text.trim(),
          codePin: _codePin.text,
          email: _email.text.trim().isNotEmpty ? _email.text.trim() : null,
          boutiqueId: boutiqueId,
        );
      }

      ref.invalidate(utilisateursProvider);
      if (mounted) {
        Navigator.pop(context);
        AppSnackbar.success(
          context,
          _isEdit ? 'Utilisateur mis à jour.' : 'Utilisateur créé.',
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
            _isEdit ? Symbols.edit : Symbols.person_add,
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          Text(_isEdit ? 'Modifier l\'utilisateur' : 'Nouvel utilisateur'),
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
                // Nom
                TextFormField(
                  controller: _nom,
                  decoration: InputDecoration(
                    labelText: 'Nom complet *',
                    prefixIcon: const Icon(Symbols.person),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
                ),
                const SizedBox(height: 12),
                // Email
                TextFormField(
                  controller: _email,
                  decoration: InputDecoration(
                    labelText: _isEdit ? 'Email' : 'Email *',
                    prefixIcon: const Icon(Symbols.email),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: _isEdit
                      ? null
                      : (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
                ),
                const SizedBox(height: 12),
                // Téléphone
                TextFormField(
                  controller: _telephone,
                  decoration: InputDecoration(
                    labelText: _isEdit ? 'Téléphone' : 'Téléphone *',
                    prefixIcon: const Icon(Symbols.phone),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: _isEdit
                      ? null
                      : (v) => (v == null || v.trim().length < 4) ? 'Minimum 4 chiffres' : null,
                ),
                const SizedBox(height: 12),
                // Code PIN
                TextFormField(
                  controller: _codePin,
                  obscureText: _obscurePin,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  decoration: InputDecoration(
                    labelText: _isEdit ? 'Nouveau code PIN (optionnel)' : 'Code PIN * (4 chiffres)',
                    prefixIcon: const Icon(Symbols.pin),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePin ? Symbols.visibility : Symbols.visibility_off),
                      onPressed: () => setState(() => _obscurePin = !_obscurePin),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    counterText: '',
                  ),
                  validator: (v) {
                    if (_isEdit && (v == null || v.isEmpty)) return null;
                    if (v == null || v.length != 4 || int.tryParse(v) == null) {
                      return '4 chiffres requis';
                    }
                    return null;
                  },
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

// ── Carte utilisateur ──────────────────────────────────────────────────────

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.user,
    required this.canDelete,
    required this.onEdit,
    required this.onDelete,
  });

  final UserProfile user;
  final bool canDelete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final initiale = user.nom.isNotEmpty ? user.nom[0].toUpperCase() : '?';
    final roleColor = user.isOwner ? AppColors.accentDark : AppColors.primary;
    final roleBgColor = user.isOwner
        ? AppColors.accentContainer
        : AppColors.primary.withValues(alpha: 0.1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: roleColor.withValues(alpha: 0.12),
            child: Text(
              initiale,
              style: TextStyle(
                color: roleColor,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Infos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.nom, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: roleBgColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        user.roleLabel,
                        style: AppTextStyles.caption.copyWith(
                          color: roleColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (user.email != null) ...[
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          user.email!,
                          style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
                if (user.telephone != null)
                  Text(
                    user.telephone!,
                    style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                  ),
              ],
            ),
          ),
          // Actions
          IconButton(
            icon: const Icon(Symbols.edit, size: 20),
            color: AppColors.primary,
            tooltip: 'Modifier',
            onPressed: onEdit,
          ),
          if (canDelete)
            IconButton(
              icon: const Icon(Symbols.delete, size: 20),
              color: AppColors.error,
              tooltip: 'Supprimer',
              onPressed: onDelete,
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
  }
  return 'Une erreur est survenue.';
}
