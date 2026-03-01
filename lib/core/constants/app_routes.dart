class AppRoutes {
  AppRoutes._();

  // Auth
  static const String splash = '/';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';

  // Élève
  static const String eleveDashboard = '/eleve/dashboard';
  static const String eleveNotes = '/eleve/notes';
  static const String eleveNotesDetail = '/eleve/notes/detail';
  static const String eleveEmploiDuTemps = '/eleve/emploi-du-temps';
  static const String eleveDevoirs = '/eleve/devoirs';
  static const String eleveProfil = '/eleve/profil';
  static const String eleveCarnet = '/eleve/carnet';

  // Professeur
  static const String professeurDashboard = '/professeur/dashboard';
  static const String professeurClasses = '/professeur/classes';
  static const String professeurSaisieNotes = '/professeur/saisie-notes';
  static const String professeurMessages = '/professeur/messages';
  static const String professeurStatistiques = '/professeur/statistiques';
  static const String professeurDevoirs = '/professeur/devoirs';
  static const String professeurProfil = '/professeur/profil';

  // Admin
  static const String adminDashboard = '/admin/dashboard';
  static const String adminUtilisateurs = '/admin/utilisateurs';
  static const String adminClasses = '/admin/classes';
  static const String adminBulletins = '/admin/bulletins';
  static const String adminStatistiques = '/admin/statistiques';
  static const String adminPeriodes = '/admin/periodes';
  static const String adminParametres = '/admin/parametres';
}
