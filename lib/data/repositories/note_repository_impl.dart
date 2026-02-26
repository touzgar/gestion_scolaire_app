import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../datasources/note_remote_datasource.dart';
import '../models/note_model.dart';

/// Implémentation du repository des notes
class NoteRepositoryImpl implements NoteRepository {
  final NoteRemoteDataSource _remoteDataSource;

  NoteRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Note>> getNotesByEleve(
    String eleveId, {
    int? trimestre,
    String? anneeScolaire,
  }) {
    return _remoteDataSource.getNotesByEleve(
      eleveId,
      trimestre: trimestre,
      anneeScolaire: anneeScolaire,
    );
  }

  @override
  Future<List<Note>> getNotesByClasseMatiere(
    String classeId,
    String matiereId, {
    int? trimestre,
  }) {
    return _remoteDataSource.getNotesByClasseMatiere(
      classeId,
      matiereId,
      trimestre: trimestre,
    );
  }

  @override
  Future<Note> addNote(Note note) {
    return _remoteDataSource.addNote(NoteModel.fromEntity(note));
  }

  @override
  Future<List<Note>> addNotesBatch(List<Note> notes) {
    return _remoteDataSource.addNotesBatch(
      notes.map((n) => NoteModel.fromEntity(n)).toList(),
    );
  }

  @override
  Future<Note> updateNote(Note note) async {
    await _remoteDataSource.updateNote(NoteModel.fromEntity(note));
    return note;
  }

  @override
  Future<void> deleteNote(String noteId) {
    return _remoteDataSource.deleteNote(noteId);
  }

  @override
  Future<double> getMoyenneEleveMatiere(
    String eleveId,
    String matiereId, {
    int? trimestre,
  }) async {
    final notes = await _remoteDataSource.getNotesByEleve(
      eleveId,
      trimestre: trimestre,
    );
    final matiereNotes = notes.where((n) => n.matiereId == matiereId).toList();
    if (matiereNotes.isEmpty) return 0.0;

    double totalPoints = 0;
    double totalCoeff = 0;
    for (final note in matiereNotes) {
      totalPoints += note.valeur * note.coefficient;
      totalCoeff += note.coefficient;
    }
    return totalCoeff > 0 ? totalPoints / totalCoeff : 0.0;
  }

  @override
  Future<double> getMoyenneGenerale(
    String eleveId, {
    int? trimestre,
    String? anneeScolaire,
  }) async {
    final notes = await _remoteDataSource.getNotesByEleve(
      eleveId,
      trimestre: trimestre,
      anneeScolaire: anneeScolaire,
    );
    if (notes.isEmpty) return 0.0;

    double totalPoints = 0;
    double totalCoeff = 0;
    for (final note in notes) {
      totalPoints += note.valeur * note.coefficient;
      totalCoeff += note.coefficient;
    }
    return totalCoeff > 0 ? totalPoints / totalCoeff : 0.0;
  }

  @override
  Future<double> getMoyenneClasseMatiere(
    String classeId,
    String matiereId, {
    int? trimestre,
  }) async {
    final notes = await _remoteDataSource.getNotesByClasseMatiere(
      classeId,
      matiereId,
      trimestre: trimestre,
    );
    if (notes.isEmpty) return 0.0;

    double totalPoints = 0;
    double totalCoeff = 0;
    for (final note in notes) {
      totalPoints += note.valeur * note.coefficient;
      totalCoeff += note.coefficient;
    }
    return totalCoeff > 0 ? totalPoints / totalCoeff : 0.0;
  }

  @override
  Stream<List<Note>> watchNotesByEleve(String eleveId) {
    return _remoteDataSource.watchNotesByEleve(eleveId);
  }
}
