import 'package:equatable/equatable.dart';
import 'user_role.dart';

/// Entité utilisateur de base pour tous les profils
class AppUser extends Equatable {
  final String uid;
  final String nom;
  final String prenom;
  final String email;
  final String? photoUrl;
  final String? telephone;
  final UserRole role;
  final bool isActive;
  final DateTime dateCreation;

  const AppUser({
    required this.uid,
    required this.nom,
    required this.prenom,
    required this.email,
    this.photoUrl,
    this.telephone,
    required this.role,
    this.isActive = true,
    required this.dateCreation,
  });

  String get nomComplet => '$prenom $nom';

  @override
  List<Object?> get props => [uid, nom, prenom, email, role];
}
