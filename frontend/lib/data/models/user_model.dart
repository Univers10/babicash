/// Profil complet d'un utilisateur (GET /users/me ou GET /users/).
class UserProfile {
  const UserProfile({
    required this.id,
    required this.nom,
    this.email,
    this.telephone,
    required this.role,
    this.actif = true,
  });

  final String id;
  final String nom;
  final String? email;
  final String? telephone;
  final String role;
  final bool actif;

  bool get isOwner => role == 'OWNER';
  bool get isManager => role == 'MANAGER';

  String get roleLabel => isOwner ? 'Propriétaire' : 'Gérant';

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        nom: json['nom'] as String,
        email: json['email'] as String?,
        telephone: json['telephone'] as String?,
        role: json['role'] as String,
        actif: json['actif'] as bool? ?? true,
      );
}
