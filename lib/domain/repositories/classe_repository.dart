import '../entities/classe.dart';

/// Interface du repository des classes
abstract class ClasseRepository {
  /// Récupérer une classe par son ID
  Future<Classe> getClasseById(String id);

  /// Récupérer toutes les classes
  Future<List<Classe>> getAllClasses({String? anneeScolaire});

  /// Récupérer les classes d'un professeur
  Future<List<Classe>> getClassesByProfesseur(String professeurId);

  /// Créer une classe
  Future<Classe> createClasse(Classe classe);

  /// Modifier une classe
  Future<Classe> updateClasse(Classe classe);

  /// Supprimer une classe
  Future<void> deleteClasse(String id);

  /// Ajouter un élève à une classe
  Future<void> addEleveToClasse(String classeId, String eleveId);

  /// Retirer un élève d'une classe
  Future<void> removeEleveFromClasse(String classeId, String eleveId);

  /// Stream des classes en temps réel
  Stream<List<Classe>> watchAllClasses();
}
