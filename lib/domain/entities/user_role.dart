/// Enum des rôles utilisateurs de l'application
enum UserRole { eleve, professeur, parent, admin, vieScolaire }

/// Extension pour afficher le nom du rôle en français
extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.eleve:
        return 'Élève';
      case UserRole.professeur:
        return 'Professeur';
      case UserRole.parent:
        return 'Parent';
      case UserRole.admin:
        return 'Administration';
      case UserRole.vieScolaire:
        return 'Vie Scolaire';
    }
  }

  String get firestoreValue {
    switch (this) {
      case UserRole.eleve:
        return 'eleve';
      case UserRole.professeur:
        return 'professeur';
      case UserRole.parent:
        return 'parent';
      case UserRole.admin:
        return 'admin';
      case UserRole.vieScolaire:
        return 'vie_scolaire';
    }
  }

  static UserRole fromString(String value) {
    switch (value) {
      case 'eleve':
        return UserRole.eleve;
      case 'professeur':
        return UserRole.professeur;
      case 'parent':
        return UserRole.parent;
      case 'admin':
        return UserRole.admin;
      case 'vie_scolaire':
        return UserRole.vieScolaire;
      default:
        return UserRole.eleve;
    }
  }
}
