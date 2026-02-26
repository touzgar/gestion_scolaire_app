import 'package:equatable/equatable.dart';

/// Jour de la semaine
enum JourSemaine { lundi, mardi, mercredi, jeudi, vendredi, samedi }

extension JourSemaineExtension on JourSemaine {
  String get displayName {
    switch (this) {
      case JourSemaine.lundi:
        return 'Lundi';
      case JourSemaine.mardi:
        return 'Mardi';
      case JourSemaine.mercredi:
        return 'Mercredi';
      case JourSemaine.jeudi:
        return 'Jeudi';
      case JourSemaine.vendredi:
        return 'Vendredi';
      case JourSemaine.samedi:
        return 'Samedi';
    }
  }
}

/// Entité Créneau Emploi du Temps
class CreneauEmploiDuTemps extends Equatable {
  final String id;
  final String classeId;
  final String matiereId;
  final String professeurId;
  final String? salle;
  final JourSemaine jour;
  final String heureDebut; // Format "08:00"
  final String heureFin; // Format "09:00"
  final String anneeScolaire;
  final bool estAnnule;
  final String? remplacement; // ID du prof remplaçant si applicable

  const CreneauEmploiDuTemps({
    required this.id,
    required this.classeId,
    required this.matiereId,
    required this.professeurId,
    this.salle,
    required this.jour,
    required this.heureDebut,
    required this.heureFin,
    required this.anneeScolaire,
    this.estAnnule = false,
    this.remplacement,
  });

  @override
  List<Object?> get props => [id, classeId, matiereId, jour, heureDebut];
}
