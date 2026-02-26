import '../entities/absence.dart';

/// Interface du repository de la vie scolaire (absences/retards)
abstract class AbsenceRepository {
  /// Récupérer les absences d'un élève
  Future<List<Absence>> getAbsencesByEleve(String eleveId);

  /// Récupérer les absences d'une classe
  Future<List<Absence>> getAbsencesByClasse(String classeId, {DateTime? date});

  /// Ajouter une absence
  Future<Absence> addAbsence(Absence absence);

  /// Modifier une absence (justification, statut)
  Future<Absence> updateAbsence(Absence absence);

  /// Supprimer une absence
  Future<void> deleteAbsence(String absenceId);

  /// Compter les absences non justifiées d'un élève
  Future<int> countAbsencesNonJustifiees(String eleveId);

  /// Stream des absences d'un élève
  Stream<List<Absence>> watchAbsencesByEleve(String eleveId);
}
