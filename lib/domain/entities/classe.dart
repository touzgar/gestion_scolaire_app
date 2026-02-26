import 'package:equatable/equatable.dart';

/// Entité Classe (ex: Terminale S1, 2nde A, etc.)
class Classe extends Equatable {
  final String id;
  final String nom;
  final String niveau; // 2nde, 1ère, Terminale
  final String? filiere; // S, ES, L, STI2D...
  final String anneeScolaire;
  final String? professeurPrincipalId;
  final List<String> eleveIds;
  final List<String> matiereIds;
  final int capaciteMax;

  const Classe({
    required this.id,
    required this.nom,
    required this.niveau,
    this.filiere,
    required this.anneeScolaire,
    this.professeurPrincipalId,
    this.eleveIds = const [],
    this.matiereIds = const [],
    this.capaciteMax = 35,
  });

  int get effectif => eleveIds.length;
  bool get estPleine => effectif >= capaciteMax;

  @override
  List<Object?> get props => [id, nom, niveau, anneeScolaire];
}
