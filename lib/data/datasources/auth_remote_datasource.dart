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
      return await _getUserData(credential.user!.uid);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e.code));
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
    return await _getUserData(user.uid);
  }

  /// Stream état auth
  Stream<AppUserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      return await _getUserData(user.uid);
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

      await _firestore
          .collection('utilisateurs')
          .doc(uid)
          .set(userModel.toFirestore());

      // Envoyer l'e-mail de bienvenue via SMTP
      EmailService.sendWelcomeEmail(
        toEmail: email,
        userName: '$prenom $nom',
        role: role.displayName,
      );

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e.code));
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
      default:
        return 'Erreur d\'authentification';
    }
  }
}
