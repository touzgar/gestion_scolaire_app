import 'package:equatable/equatable.dart';
import '../../../domain/entities/app_user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// État initial : on vérifie l'auth
class AuthInitial extends AuthState {}

/// Chargement en cours
class AuthLoading extends AuthState {}

/// Utilisateur authentifié
class AuthAuthenticated extends AuthState {
  final AppUser user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// Utilisateur non authentifié
class AuthUnauthenticated extends AuthState {}

/// Erreur d'authentification
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Inscription réussie (sans auto-login)
class AuthSignUpSuccess extends AuthState {
  final String message;
  const AuthSignUpSuccess({
    this.message = 'Compte créé avec succès ! Connectez-vous.',
  });
  @override
  List<Object?> get props => [message];
}

/// Mot de passe réinitialisé avec succès
class AuthPasswordResetSent extends AuthState {}
