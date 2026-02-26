import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/errors/exceptions.dart';
import '../models/note_model.dart';

/// Source de données des notes Firebase
class NoteRemoteDataSource {
  final FirebaseFirestore _firestore;

  NoteRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _notesCollection => _firestore.collection('notes');

  /// Récupérer les notes d'un élève
  Future<List<NoteModel>> getNotesByEleve(
    String eleveId, {
    int? trimestre,
    String? anneeScolaire,
  }) async {
    try {
      Query query = _notesCollection.where('eleveId', isEqualTo: eleveId);
      if (trimestre != null) {
        query = query.where('trimestre', isEqualTo: trimestre);
      }
      if (anneeScolaire != null) {
        query = query.where('anneeScolaire', isEqualTo: anneeScolaire);
      }
      final snapshot = await query.orderBy('date', descending: true).get();
      return snapshot.docs.map((doc) => NoteModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException('Erreur lors du chargement des notes: $e');
    }
  }

  /// Récupérer les notes d'une classe/matière
  Future<List<NoteModel>> getNotesByClasseMatiere(
    String classeId,
    String matiereId, {
    int? trimestre,
  }) async {
    try {
      // D'abord récupérer les IDs des élèves de la classe
      final classeDoc = await _firestore
          .collection('classes')
          .doc(classeId)
          .get();
      final eleveIds = List<String>.from(classeDoc.data()?['eleveIds'] ?? []);

      if (eleveIds.isEmpty) return [];

      // Firestore limite "whereIn" à 30 éléments
      final List<NoteModel> allNotes = [];
      for (var i = 0; i < eleveIds.length; i += 30) {
        final chunk = eleveIds.sublist(
          i,
          i + 30 > eleveIds.length ? eleveIds.length : i + 30,
        );
        Query query = _notesCollection
            .where('eleveId', whereIn: chunk)
            .where('matiereId', isEqualTo: matiereId);
        if (trimestre != null) {
          query = query.where('trimestre', isEqualTo: trimestre);
        }
        final snapshot = await query.get();
        allNotes.addAll(
          snapshot.docs.map((doc) => NoteModel.fromFirestore(doc)),
        );
      }
      return allNotes;
    } catch (e) {
      throw ServerException(
        'Erreur lors du chargement des notes de classe: $e',
      );
    }
  }

  /// Ajouter une note
  Future<NoteModel> addNote(NoteModel note) async {
    try {
      final docRef = await _notesCollection.add(note.toFirestore());
      return NoteModel(
        id: docRef.id,
        eleveId: note.eleveId,
        matiereId: note.matiereId,
        professeurId: note.professeurId,
        valeur: note.valeur,
        coefficient: note.coefficient,
        typeEvaluation: note.typeEvaluation,
        commentaire: note.commentaire,
        date: note.date,
        competenceId: note.competenceId,
        trimestre: note.trimestre,
        anneeScolaire: note.anneeScolaire,
      );
    } catch (e) {
      throw ServerException('Erreur lors de l\'ajout de la note: $e');
    }
  }

  /// Ajouter des notes en lot
  Future<List<NoteModel>> addNotesBatch(List<NoteModel> notes) async {
    try {
      final batch = _firestore.batch();
      final List<DocumentReference> refs = [];
      for (final note in notes) {
        final ref = _notesCollection.doc();
        refs.add(ref);
        batch.set(ref, note.toFirestore());
      }
      await batch.commit();
      return List.generate(
        notes.length,
        (i) => NoteModel(
          id: refs[i].id,
          eleveId: notes[i].eleveId,
          matiereId: notes[i].matiereId,
          professeurId: notes[i].professeurId,
          valeur: notes[i].valeur,
          coefficient: notes[i].coefficient,
          typeEvaluation: notes[i].typeEvaluation,
          commentaire: notes[i].commentaire,
          date: notes[i].date,
          competenceId: notes[i].competenceId,
          trimestre: notes[i].trimestre,
          anneeScolaire: notes[i].anneeScolaire,
        ),
      );
    } catch (e) {
      throw ServerException('Erreur lors de l\'ajout des notes en lot: $e');
    }
  }

  /// Modifier une note
  Future<void> updateNote(NoteModel note) async {
    try {
      await _notesCollection.doc(note.id).update(note.toFirestore());
    } catch (e) {
      throw ServerException('Erreur lors de la mise à jour de la note: $e');
    }
  }

  /// Supprimer une note
  Future<void> deleteNote(String noteId) async {
    try {
      await _notesCollection.doc(noteId).delete();
    } catch (e) {
      throw ServerException('Erreur lors de la suppression de la note: $e');
    }
  }

  /// Stream des notes d'un élève
  Stream<List<NoteModel>> watchNotesByEleve(String eleveId) {
    return _notesCollection
        .where('eleveId', isEqualTo: eleveId)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => NoteModel.fromFirestore(doc)).toList(),
        );
  }
}
