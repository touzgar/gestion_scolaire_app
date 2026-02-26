class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'Erreur serveur']);
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Erreur de cache']);
}

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'Pas de connexion internet']);
}

class AuthException implements Exception {
  final String message;
  const AuthException([this.message = 'Erreur d\'authentification']);
}

class NotFoundException implements Exception {
  final String message;
  const NotFoundException([this.message = 'Ressource introuvable']);
}
