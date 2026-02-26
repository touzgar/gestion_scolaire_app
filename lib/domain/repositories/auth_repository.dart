import '../entities/app_user.dart';
import '../entities/user_role.dart';

/// Interface du repository d'authentification
abstract class AuthRepository {
  /// Connexion avec email et mot de passe
  Future<AppUser> signInWithEmailAndPassword(String email, String password);

  /// Connexion avec Google
  Future<AppUser> signInWithGoogle();

  /// Déconnexion
  Future<void> signOut();

  /// Récupérer l'utilisateur courant
  Future<AppUser?> getCurrentUser();

  /// Stream de l'état d'authentification
  Stream<AppUser?> get authStateChanges;

  /// Réinitialiser le mot de passe
  Future<void> resetPassword(String email);

  /// Créer un nouveau compte utilisateur (inscription)
  Future<AppUser> createUser({
    required String email,
    required String password,
    required String nom,
    required String prenom,
    required UserRole role,
  });

  /// Récupérer le rôle de l'utilisateur
  Future<UserRole> getUserRole(String uid);
}
