import '../entities/eleve.dart';

/// Interface du repository des élèves
abstract class EleveRepository {
  /// Récupérer un élève par son UID
  Future<Eleve> getEleveById(String uid);

  /// Récupérer tous les élèves d'une classe
  Future<List<Eleve>> getElevesByClasse(String classeId);

  /// Récupérer les élèves d'un parent
  Future<List<Eleve>> getElevesByParent(String parentId);

  /// Créer un élève
  Future<Eleve> createEleve(Eleve eleve);

  /// Modifier un élève
  Future<Eleve> updateEleve(Eleve eleve);

  /// Supprimer un élève
  Future<void> deleteEleve(String uid);

  /// Rechercher des élèves
  Future<List<Eleve>> searchEleves(String query);

  /// Stream des élèves d'une classe en temps réel
  Stream<List<Eleve>> watchElevesByClasse(String classeId);
}
