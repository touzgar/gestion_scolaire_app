abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Erreur serveur']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Erreur de cache']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Pas de connexion internet']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Erreur d\'authentification']);
}

class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Permission refusée']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Données invalides']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Ressource introuvable']);
}
