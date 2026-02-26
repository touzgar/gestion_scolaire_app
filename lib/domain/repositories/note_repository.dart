import '../entities/note.dart';

/// Interface du repository des notes
abstract class NoteRepository {
  /// Récupérer les notes d'un élève
  Future<List<Note>> getNotesByEleve(
    String eleveId, {
    int? trimestre,
    String? anneeScolaire,
  });

  /// Récupérer les notes d'une classe pour une matière
  Future<List<Note>> getNotesByClasseMatiere(
    String classeId,
    String matiereId, {
    int? trimestre,
  });

  /// Ajouter une note
  Future<Note> addNote(Note note);

  /// Ajouter des notes en lot (saisie rapide par classe)
  Future<List<Note>> addNotesBatch(List<Note> notes);

  /// Modifier une note
  Future<Note> updateNote(Note note);

  /// Supprimer une note
  Future<void> deleteNote(String noteId);

  /// Calculer la moyenne d'un élève pour une matière
  Future<double> getMoyenneEleveMatiere(
    String eleveId,
    String matiereId, {
    int? trimestre,
  });

  /// Calculer la moyenne générale d'un élève
  Future<double> getMoyenneGenerale(
    String eleveId, {
    int? trimestre,
    String? anneeScolaire,
  });

  /// Calculer la moyenne d'une classe pour une matière
  Future<double> getMoyenneClasseMatiere(
    String classeId,
    String matiereId, {
    int? trimestre,
  });

  /// Stream des notes en temps réel pour un élève
  Stream<List<Note>> watchNotesByEleve(String eleveId);
}
