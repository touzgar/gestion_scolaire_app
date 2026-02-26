import 'package:equatable/equatable.dart';

/// Entité Devoir
class Devoir extends Equatable {
  final String id;
  final String matiereId;
  final String professeurId;
  final String classeId;
  final String titre;
  final String description;
  final DateTime dateCreation;
  final DateTime dateLimite;
  final List<String> piecesJointes;
  final bool estNote;
  final double? bareme;

  const Devoir({
    required this.id,
    required this.matiereId,
    required this.professeurId,
    required this.classeId,
    required this.titre,
    required this.description,
    required this.dateCreation,
    required this.dateLimite,
    this.piecesJointes = const [],
    this.estNote = false,
    this.bareme,
  });

  bool get estEnRetard => DateTime.now().isAfter(dateLimite);

  @override
  List<Object?> get props => [id, matiereId, classeId, dateLimite];
}

/// Rendu d'un devoir par un élève
class RenduDevoir extends Equatable {
  final String id;
  final String devoirId;
  final String eleveId;
  final DateTime dateRendu;
  final String? commentaire;
  final List<String> fichiersUrls;
  final double? note;
  final String? appreciation;

  const RenduDevoir({
    required this.id,
    required this.devoirId,
    required this.eleveId,
    required this.dateRendu,
    this.commentaire,
    this.fichiersUrls = const [],
    this.note,
    this.appreciation,
  });

  @override
  List<Object?> get props => [id, devoirId, eleveId, dateRendu];
}
