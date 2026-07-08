import 'package:dio/dio.dart';

/// Hiérarchie d'exceptions métier BabiCash.
sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Vérifiez votre connexion internet.']);
}

class TimeoutException extends AppException {
  const TimeoutException([super.message = 'La requête a pris trop de temps.']);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Session expirée. Reconnectez-vous.']);
}

class ForbiddenException extends AppException {
  const ForbiddenException([super.message = 'Accès non autorisé.']);
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Ressource introuvable.']);
}

class QuotaException extends AppException {
  const QuotaException({
    required this.ventesUtilisees,
    required this.quota,
    required this.plan,
  }) : super('Quota mensuel atteint ($ventesUtilisees/$quota ventes). Passez au plan PRO.');

  final int ventesUtilisees;
  final int quota;
  final String plan;
}

class ConflictException extends AppException {
  const ConflictException([super.message = 'Ce numéro ou email est déjà utilisé.']);
}

class ServerException extends AppException {
  const ServerException([super.message = 'Erreur serveur. Réessayez plus tard.']);
}

class UnknownException extends AppException {
  const UnknownException([super.message = 'Une erreur inattendue est survenue.']);
}

/// Convertit une DioException en AppException.
AppException mapDioError(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return const TimeoutException();
    case DioExceptionType.connectionError:
      return const NetworkException();
    case DioExceptionType.badResponse:
      final status = e.response?.statusCode;
      final data = e.response?.data;
      switch (status) {
        case 401:
          return const UnauthorizedException();
        case 402:
          // Quota freemium dépassé — FastAPI wrape dans {"detail": {...}}
          final detail402 = data is Map ? (data['detail'] ?? data) : null;
          if (detail402 is Map && detail402['code'] == 'QUOTA_DEPASSE') {
            return QuotaException(
              ventesUtilisees: detail402['ventes_utilisees'] as int? ?? 0,
              quota: detail402['quota'] as int? ?? 20,
              plan: detail402['plan'] as String? ?? 'FREE',
            );
          }
          return const ForbiddenException('Abonnement requis.');
        case 403:
          return const ForbiddenException();
        case 404:
          return const NotFoundException();
        case 409:
          final msg = data is Map ? data['detail']?.toString() : null;
          return ConflictException(msg ?? 'Conflit de données.');
        case 422:
          return const UnknownException('Données invalides.');
        default:
          if (status != null && status >= 500) return const ServerException();
          final msg = data is Map ? data['detail']?.toString() : null;
          return UnknownException(msg ?? 'Erreur ${status ?? 'inconnue'}.');
      }
    default:
      return const UnknownException();
  }
}
