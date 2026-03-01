/// Enum des rôles utilisateurs de l'application
enum UserRole { eleve, professeur, admin }

/// Extension pour afficher le nom du rôle en français
extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.eleve:
        return 'Élève';
      case UserRole.professeur:
        return 'Professeur';
      case UserRole.admin:
        return 'Administration';
    }
  }

  String get firestoreValue {
    switch (this) {
      case UserRole.eleve:
        return 'eleve';
      case UserRole.professeur:
        return 'professeur';
      case UserRole.admin:
        return 'admin';
    }
  }

  static UserRole fromString(String value) {
    switch (value) {
      case 'eleve':
        return UserRole.eleve;
      case 'professeur':
        return UserRole.professeur;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.eleve;
    }
  }
}
