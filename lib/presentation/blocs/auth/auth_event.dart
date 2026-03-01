import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_role.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Vérifier si l'utilisateur est connecté au démarrage
class AuthCheckRequested extends AuthEvent {}

/// Connexion avec email et mot de passe
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Inscription avec email et mot de passe
class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String nom;
  final String prenom;
  final UserRole role;

  const AuthSignUpRequested({
    required this.email,
    required this.password,
    required this.nom,
    required this.prenom,
    required this.role,
  });

  @override
  List<Object?> get props => [email, password, nom, prenom, role];
}

/// Déconnexion
class AuthLogoutRequested extends AuthEvent {}

/// Réinitialiser le mot de passe
class AuthResetPasswordRequested extends AuthEvent {
  final String email;

  const AuthResetPasswordRequested({required this.email});

  @override
  List<Object?> get props => [email];
}
