import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/errors/exceptions.dart';
import '../../core/services/email_service.dart';
import '../models/app_user_model.dart';
import '../../domain/entities/user_role.dart';

/// Source de données d'authentification Firebase
class AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSource({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  /// Connexion
  Future<AppUserModel> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user == null) {
        throw const AuthException('Connexion échouée');
      }
      try {
        return await _getUserData(credential.user!.uid);
      } catch (e) {
        // If getting user data fails (e.g., NotFoundException from a broken signup)
        await _firebaseAuth.signOut();
        if (e is AuthException) rethrow;
        throw const AuthException(
          'Erreur: Compte incomplet ou données introuvables. Veuillez vous réinscrire.',
        );
      }
    } on AuthException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e.code));
    } catch (e) {
      throw AuthException('Erreur de connexion: $e');
    }
  }

  /// Déconnexion
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  /// Utilisateur courant
  Future<AppUserModel?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    try {
      return await _getUserData(user.uid);
    } catch (e) {
      // If Firestore read fails, return null instead of crashing
      // This prevents infinite loops on auth state check
      return null;
    }
  }

  /// Stream état auth
  Stream<AppUserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      try {
        return await _getUserData(user.uid);
      } catch (e) {
        // If Firestore read fails, return null instead of throwing
        // This prevents the infinite reload loop
        return null;
      }
    });
  }

  /// Réinitialiser mot de passe
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e.code));
    }
  }

  /// Créer un compte utilisateur
  Future<AppUserModel> createUser({
    required String email,
    required String password,
    required String nom,
    required String prenom,
    required UserRole role,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;

      final userModel = AppUserModel(
        uid: uid,
        nom: nom,
        prenom: prenom,
        email: email,
        role: role,
        dateCreation: DateTime.now(),
      );

      try {
        await _firestore
            .collection('utilisateurs')
            .doc(uid)
            .set(userModel.toFirestore());
      } catch (e) {
        // En cas d'échec Firestore, supprimer l'utilisateur d'authentification pour éviter les comptes orphelins.
        try {
          await credential.user?.delete();
        } catch (_) {
          // If deletion fails too, sign out at least
          await _firebaseAuth.signOut();
        }
        throw AuthException(
          'Erreur Firestore: impossible de sauvegarder les données. '
          'Vérifiez les règles de sécurité Firestore. ($e)',
        );
      }

      // Envoyer l'e-mail de bienvenue via SMTP, non bloquant
      try {
        await EmailService.sendWelcomeEmail(
          toEmail: email,
          userName: '$prenom $nom',
          role: role.displayName,
        );
      } catch (e) {
        // Optionnel : on peut ignorer l'erreur d'email
      }

      return userModel;
    } on AuthException {
      // Don't re-wrap AuthException (e.g. from Firestore failure above)
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e.code));
    } catch (e) {
      throw AuthException('Erreur lors de l\'inscription: $e');
    }
  }

  /// Récupérer le rôle
  Future<UserRole> getUserRole(String uid) async {
    final doc = await _firestore.collection('utilisateurs').doc(uid).get();
    if (!doc.exists) throw const NotFoundException('Utilisateur introuvable');
    final data = doc.data()!;
    return UserRoleExtension.fromString(data['role'] ?? 'eleve');
  }

  /// Récupérer les données utilisateur depuis Firestore
  Future<AppUserModel> _getUserData(String uid) async {
    final doc = await _firestore.collection('utilisateurs').doc(uid).get();
    if (!doc.exists) {
      throw const NotFoundException('Données utilisateur introuvables');
    }
    return AppUserModel.fromFirestore(doc);
  }

  String _mapFirebaseAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Aucun compte trouvé avec cet e-mail';
      case 'wrong-password':
        return 'Mot de passe incorrect';
      case 'email-already-in-use':
        return 'Cet e-mail est déjà utilisé';
      case 'weak-password':
        return 'Le mot de passe est trop faible';
      case 'invalid-email':
        return 'Adresse e-mail invalide';
      case 'user-disabled':
        return 'Ce compte a été désactivé';
      case 'too-many-requests':
        return 'Trop de tentatives. Réessayez plus tard';
      case 'invalid-credential':
        return 'E-mail ou mot de passe incorrect';
      default:
        return 'Erreur d\'authentification ($code)';
    }
  }
}
