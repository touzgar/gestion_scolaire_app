import 'package:equatable/equatable.dart';

/// Entité Matière
class Matiere extends Equatable {
  final String id;
  final String nom;
  final String? code; // ex: MATH, FR, HG, SVT...
  final double coefficient;
  final String? couleur; // pour les UI
  final String? icone;

  const Matiere({
    required this.id,
    required this.nom,
    this.code,
    this.coefficient = 1.0,
    this.couleur,
    this.icone,
  });

  @override
  List<Object?> get props => [id, nom, code];
}
