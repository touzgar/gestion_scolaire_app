import 'package:equatable/equatable.dart';

/// Entité Professeur
class Professeur extends Equatable {
  final String uid;
  final String nom;
  final String prenom;
  final String email;
  final String? photoUrl;
  final String? telephone;
  final List<String> matiereIds;
  final List<String> classeIds;
  final String? classePrincipaleId; // Classe dont il est PP
  final DateTime dateInscription;
  final bool isActive;

  const Professeur({
    required this.uid,
    required this.nom,
    required this.prenom,
    required this.email,
    this.photoUrl,
    this.telephone,
    this.matiereIds = const [],
    this.classeIds = const [],
    this.classePrincipaleId,
    required this.dateInscription,
    this.isActive = true,
  });

  String get nomComplet => '$prenom $nom';

  @override
  List<Object?> get props => [uid, nom, prenom, email];
}
