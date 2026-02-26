import 'package:equatable/equatable.dart';

/// Type d'absence
enum TypeAbsence { absence, retard }

/// Statut de justification
enum StatutJustification { nonJustifie, enAttente, justifie, refuse }

/// Entité Absence / Retard
class Absence extends Equatable {
  final String id;
  final String eleveId;
  final TypeAbsence type;
  final DateTime dateDebut;
  final DateTime? dateFin;
  final String? motif;
  final StatutJustification statut;
  final String? justificatifUrl;
  final String? traitePar; // ID de la personne vie scolaire
  final DateTime dateCreation;

  const Absence({
    required this.id,
    required this.eleveId,
    this.type = TypeAbsence.absence,
    required this.dateDebut,
    this.dateFin,
    this.motif,
    this.statut = StatutJustification.nonJustifie,
    this.justificatifUrl,
    this.traitePar,
    required this.dateCreation,
  });

  /// Durée en heures
  Duration? get duree {
    if (dateFin != null) {
      return dateFin!.difference(dateDebut);
    }
    return null;
  }

  @override
  List<Object?> get props => [id, eleveId, type, dateDebut, statut];
}
