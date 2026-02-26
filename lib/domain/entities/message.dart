import 'package:equatable/equatable.dart';

/// Entité Message (messagerie sécurisée)
class Message extends Equatable {
  final String id;
  final String expediteurId;
  final String destinataireId;
  final String? conversationId;
  final String sujet;
  final String contenu;
  final DateTime dateEnvoi;
  final bool estLu;
  final List<String> piecesJointes;

  const Message({
    required this.id,
    required this.expediteurId,
    required this.destinataireId,
    this.conversationId,
    required this.sujet,
    required this.contenu,
    required this.dateEnvoi,
    this.estLu = false,
    this.piecesJointes = const [],
  });

  @override
  List<Object?> get props => [id, expediteurId, destinataireId, dateEnvoi];
}

/// Entité Annonce (annonces de l'établissement)
class Annonce extends Equatable {
  final String id;
  final String auteurId;
  final String titre;
  final String contenu;
  final DateTime datePublication;
  final List<String> destinataireRoles; // ex: ['eleve', 'parent']
  final List<String>? classeIds; // null = toutes les classes
  final bool estImportante;

  const Annonce({
    required this.id,
    required this.auteurId,
    required this.titre,
    required this.contenu,
    required this.datePublication,
    this.destinataireRoles = const [],
    this.classeIds,
    this.estImportante = false,
  });

  @override
  List<Object?> get props => [id, titre, datePublication];
}
