import '../../domain/entities/app_user.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// Implémentation du repository d'authentification
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<AppUser> signInWithEmailAndPassword(String email, String password) {
    return _remoteDataSource.signInWithEmailAndPassword(email, password);
  }

  @override
  Future<void> signOut() {
    return _remoteDataSource.signOut();
  }

  @override
  Future<AppUser?> getCurrentUser() {
    return _remoteDataSource.getCurrentUser();
  }

  @override
  Stream<AppUser?> get authStateChanges => _remoteDataSource.authStateChanges;

  @override
  Future<void> resetPassword(String email) {
    return _remoteDataSource.resetPassword(email);
  }

  @override
  Future<AppUser> createUser({
    required String email,
    required String password,
    required String nom,
    required String prenom,
    required UserRole role,
  }) {
    return _remoteDataSource.createUser(
      email: email,
      password: password,
      nom: nom,
      prenom: prenom,
      role: role,
    );
  }

  @override
  Future<UserRole> getUserRole(String uid) {
    return _remoteDataSource.getUserRole(uid);
  }
}
