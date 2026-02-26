import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/classe.dart';

class ClasseModel extends Classe {
  const ClasseModel({
    required super.id,
    required super.nom,
    required super.niveau,
    super.filiere,
    required super.anneeScolaire,
    super.professeurPrincipalId,
    super.eleveIds,
    super.matiereIds,
    super.capaciteMax,
  });

  factory ClasseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ClasseModel(
      id: doc.id,
      nom: data['nom'] ?? '',
      niveau: data['niveau'] ?? '',
      filiere: data['filiere'],
      anneeScolaire: data['anneeScolaire'] ?? '',
      professeurPrincipalId: data['professeurPrincipalId'],
      eleveIds: List<String>.from(data['eleveIds'] ?? []),
      matiereIds: List<String>.from(data['matiereIds'] ?? []),
      capaciteMax: data['capaciteMax'] ?? 35,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nom': nom,
      'niveau': niveau,
      'filiere': filiere,
      'anneeScolaire': anneeScolaire,
      'professeurPrincipalId': professeurPrincipalId,
      'eleveIds': eleveIds,
      'matiereIds': matiereIds,
      'capaciteMax': capaciteMax,
    };
  }

  factory ClasseModel.fromEntity(Classe classe) {
    return ClasseModel(
      id: classe.id,
      nom: classe.nom,
      niveau: classe.niveau,
      filiere: classe.filiere,
      anneeScolaire: classe.anneeScolaire,
      professeurPrincipalId: classe.professeurPrincipalId,
      eleveIds: classe.eleveIds,
      matiereIds: classe.matiereIds,
      capaciteMax: classe.capaciteMax,
    );
  }
}
