import 'package:equatable/equatable.dart';
import 'note.dart';

/// Entité Évaluation (un examen/devoir pour une classe entière)
class Evaluation extends Equatable {
  final String id;
  final String matiereId;
  final String professeurId;
  final String classeId;
  final String titre;
  final String? description;
  final TypeEvaluation type;
  final double coefficient;
  final double bareme; // Barème (par défaut 20)
  final DateTime date;
  final DateTime? dateLimiteRendu;
  final int trimestre;
  final String anneeScolaire;
  final bool estPubliee;

  const Evaluation({
    required this.id,
    required this.matiereId,
    required this.professeurId,
    required this.classeId,
    required this.titre,
    this.description,
    this.type = TypeEvaluation.controle,
    this.coefficient = 1.0,
    this.bareme = 20.0,
    required this.date,
    this.dateLimiteRendu,
    required this.trimestre,
    required this.anneeScolaire,
    this.estPubliee = false,
  });

  @override
  List<Object?> get props => [id, matiereId, classeId, date];
}
