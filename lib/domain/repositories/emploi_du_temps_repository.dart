import '../entities/emploi_du_temps.dart';

/// Interface du repository de l'emploi du temps
abstract class EmploiDuTempsRepository {
  /// Récupérer l'emploi du temps d'une classe
  Future<List<CreneauEmploiDuTemps>> getEmploiDuTempsByClasse(String classeId);

  /// Récupérer l'emploi du temps d'un professeur
  Future<List<CreneauEmploiDuTemps>> getEmploiDuTempsByProfesseur(
    String professeurId,
  );

  /// Ajouter un créneau
  Future<CreneauEmploiDuTemps> addCreneau(CreneauEmploiDuTemps creneau);

  /// Modifier un créneau
  Future<CreneauEmploiDuTemps> updateCreneau(CreneauEmploiDuTemps creneau);

  /// Supprimer un créneau
  Future<void> deleteCreneau(String creneauId);

  /// Annuler un cours
  Future<void> annulerCours(String creneauId);

  /// Stream de l'emploi du temps en temps réel
  Stream<List<CreneauEmploiDuTemps>> watchEmploiDuTempsByClasse(
    String classeId,
  );
}
