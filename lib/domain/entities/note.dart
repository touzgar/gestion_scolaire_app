import 'package:equatable/equatable.dart';

/// Type d'évaluation
enum TypeEvaluation { controle, devoir, examen, oral, tp, projet }

extension TypeEvaluationExtension on TypeEvaluation {
  String get displayName {
    switch (this) {
      case TypeEvaluation.controle:
        return 'Contrôle';
      case TypeEvaluation.devoir:
        return 'Devoir';
      case TypeEvaluation.examen:
        return 'Examen';
      case TypeEvaluation.oral:
        return 'Oral';
      case TypeEvaluation.tp:
        return 'TP';
      case TypeEvaluation.projet:
        return 'Projet';
    }
  }

  static TypeEvaluation fromString(String value) {
    switch (value.toLowerCase()) {
      case 'controle':
        return TypeEvaluation.controle;
      case 'devoir':
        return TypeEvaluation.devoir;
      case 'examen':
        return TypeEvaluation.examen;
      case 'oral':
        return TypeEvaluation.oral;
      case 'tp':
        return TypeEvaluation.tp;
      case 'projet':
        return TypeEvaluation.projet;
      default:
        return TypeEvaluation.controle;
    }
  }
}

/// Entité Note
class Note extends Equatable {
  final String id;
  final String eleveId;
  final String matiereId;
  final String professeurId;
  final double valeur;
  final double coefficient;
  final TypeEvaluation typeEvaluation;
  final String? commentaire;
  final DateTime date;
  final String? competenceId;
  final int trimestre;
  final String anneeScolaire;

  const Note({
    required this.id,
    required this.eleveId,
    required this.matiereId,
    required this.professeurId,
    required this.valeur,
    this.coefficient = 1.0,
    this.typeEvaluation = TypeEvaluation.controle,
    this.commentaire,
    required this.date,
    this.competenceId,
    required this.trimestre,
    required this.anneeScolaire,
  });

  @override
  List<Object?> get props => [id, eleveId, matiereId, valeur, date];
}
