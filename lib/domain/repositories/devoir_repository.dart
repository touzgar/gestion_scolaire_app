import '../entities/devoir.dart';

/// Interface du repository des devoirs
abstract class DevoirRepository {
  /// Récupérer les devoirs d'une classe
  Future<List<Devoir>> getDevoirsByClasse(String classeId);

  /// Récupérer les devoirs d'un élève (via sa classe)
  Future<List<Devoir>> getDevoirsByEleve(String eleveId);

  /// Créer un devoir
  Future<Devoir> createDevoir(Devoir devoir);

  /// Modifier un devoir
  Future<Devoir> updateDevoir(Devoir devoir);

  /// Supprimer un devoir
  Future<void> deleteDevoir(String devoirId);

  /// Soumettre un rendu de devoir
  Future<RenduDevoir> soumettreRendu(RenduDevoir rendu);

  /// Récupérer les rendus d'un devoir
  Future<List<RenduDevoir>> getRendusByDevoir(String devoirId);

  /// Récupérer le rendu d'un élève pour un devoir
  Future<RenduDevoir?> getRenduByEleveDevoir(String eleveId, String devoirId);

  /// Stream des devoirs d'une classe
  Stream<List<Devoir>> watchDevoirsByClasse(String classeId);
}
