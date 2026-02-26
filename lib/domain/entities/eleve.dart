import 'package:equatable/equatable.dart';

/// Statut scolaire de l'élève
enum StatutScolaire { actif, suspendu, diplome, transfere }

/// Entité Élève
class Eleve extends Equatable {
  final String uid;
  final String nom;
  final String prenom;
  final String classeId;
  final String? photoUrl;
  final List<String> parentsIds;
  final DateTime dateInscription;
  final StatutScolaire statut;
  final String? email;
  final DateTime? dateNaissance;
  final String? adresse;
  final String? telephone;

  const Eleve({
    required this.uid,
    required this.nom,
    required this.prenom,
    required this.classeId,
    this.photoUrl,
    this.parentsIds = const [],
    required this.dateInscription,
    this.statut = StatutScolaire.actif,
    this.email,
    this.dateNaissance,
    this.adresse,
    this.telephone,
  });

  String get nomComplet => '$prenom $nom';

  @override
  List<Object?> get props => [uid, nom, prenom, classeId, statut];
}
