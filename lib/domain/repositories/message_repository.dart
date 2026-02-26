import '../entities/message.dart';

/// Interface du repository de messagerie
abstract class MessageRepository {
  /// Envoyer un message
  Future<Message> sendMessage(Message message);

  /// Récupérer les messages reçus
  Future<List<Message>> getMessagesRecus(String userId);

  /// Récupérer les messages envoyés
  Future<List<Message>> getMessagesEnvoyes(String userId);

  /// Marquer un message comme lu
  Future<void> markAsRead(String messageId);

  /// Supprimer un message
  Future<void> deleteMessage(String messageId);

  /// Récupérer une conversation
  Future<List<Message>> getConversation(String conversationId);

  /// Stream des messages en temps réel
  Stream<List<Message>> watchMessagesRecus(String userId);

  /// Publier une annonce
  Future<Annonce> publierAnnonce(Annonce annonce);

  /// Récupérer les annonces
  Future<List<Annonce>> getAnnonces({List<String>? roles, String? classeId});

  /// Stream des annonces
  Stream<List<Annonce>> watchAnnonces();
}
