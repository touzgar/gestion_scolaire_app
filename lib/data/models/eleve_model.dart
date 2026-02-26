import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/eleve.dart';

class EleveModel extends Eleve {
  const EleveModel({
    required super.uid,
    required super.nom,
    required super.prenom,
    required super.classeId,
    super.photoUrl,
    super.parentsIds,
    required super.dateInscription,
    super.statut,
    super.email,
    super.dateNaissance,
    super.adresse,
    super.telephone,
  });

  factory EleveModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EleveModel(
      uid: doc.id,
      nom: data['nom'] ?? '',
      prenom: data['prenom'] ?? '',
      classeId: data['classeId'] ?? '',
      photoUrl: data['photoUrl'],
      parentsIds: List<String>.from(data['parentsIds'] ?? []),
      dateInscription:
          (data['dateInscription'] as Timestamp?)?.toDate() ?? DateTime.now(),
      statut: _parseStatut(data['statut']),
      email: data['email'],
      dateNaissance: (data['dateNaissance'] as Timestamp?)?.toDate(),
      adresse: data['adresse'],
      telephone: data['telephone'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nom': nom,
      'prenom': prenom,
      'classeId': classeId,
      'photoUrl': photoUrl,
      'parentsIds': parentsIds,
      'dateInscription': Timestamp.fromDate(dateInscription),
      'statut': statut.name,
      'email': email,
      'dateNaissance': dateNaissance != null
          ? Timestamp.fromDate(dateNaissance!)
          : null,
      'adresse': adresse,
      'telephone': telephone,
    };
  }

  static StatutScolaire _parseStatut(String? value) {
    switch (value) {
      case 'actif':
        return StatutScolaire.actif;
      case 'suspendu':
        return StatutScolaire.suspendu;
      case 'diplome':
        return StatutScolaire.diplome;
      case 'transfere':
        return StatutScolaire.transfere;
      default:
        return StatutScolaire.actif;
    }
  }

  factory EleveModel.fromEntity(Eleve eleve) {
    return EleveModel(
      uid: eleve.uid,
      nom: eleve.nom,
      prenom: eleve.prenom,
      classeId: eleve.classeId,
      photoUrl: eleve.photoUrl,
      parentsIds: eleve.parentsIds,
      dateInscription: eleve.dateInscription,
      statut: eleve.statut,
      email: eleve.email,
      dateNaissance: eleve.dateNaissance,
      adresse: eleve.adresse,
      telephone: eleve.telephone,
    );
  }
}
