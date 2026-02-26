import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/note.dart';

class NoteModel extends Note {
  const NoteModel({
    required super.id,
    required super.eleveId,
    required super.matiereId,
    required super.professeurId,
    required super.valeur,
    super.coefficient,
    super.typeEvaluation,
    super.commentaire,
    required super.date,
    super.competenceId,
    required super.trimestre,
    required super.anneeScolaire,
  });

  factory NoteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NoteModel(
      id: doc.id,
      eleveId: data['eleveId'] ?? '',
      matiereId: data['matiereId'] ?? '',
      professeurId: data['professeurId'] ?? '',
      valeur: (data['valeur'] as num?)?.toDouble() ?? 0.0,
      coefficient: (data['coefficient'] as num?)?.toDouble() ?? 1.0,
      typeEvaluation: TypeEvaluationExtension.fromString(
        data['typeEvaluation'] ?? 'controle',
      ),
      commentaire: data['commentaire'],
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      competenceId: data['competenceId'],
      trimestre: data['trimestre'] ?? 1,
      anneeScolaire: data['anneeScolaire'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'eleveId': eleveId,
      'matiereId': matiereId,
      'professeurId': professeurId,
      'valeur': valeur,
      'coefficient': coefficient,
      'typeEvaluation': typeEvaluation.name,
      'commentaire': commentaire,
      'date': Timestamp.fromDate(date),
      'competenceId': competenceId,
      'trimestre': trimestre,
      'anneeScolaire': anneeScolaire,
    };
  }

  factory NoteModel.fromEntity(Note note) {
    return NoteModel(
      id: note.id,
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
  }
}
