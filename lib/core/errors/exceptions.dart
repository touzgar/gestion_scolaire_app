class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'Erreur serveur']);

  @override
  String toString() => message;
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Erreur de cache']);

  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'Pas de connexion internet']);

  @override
  String toString() => message;
}

class AuthException implements Exception {
  final String message;
  const AuthException([this.message = 'Erreur d\'authentification']);

  @override
  String toString() => message;
}

class NotFoundException implements Exception {
  final String message;
  const NotFoundException([this.message = 'Ressource introuvable']);

  @override
  String toString() => message;
}
