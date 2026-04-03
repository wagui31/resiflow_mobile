import '../../../core/api/api_exception.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/auth_models.dart';

class AuthErrorMessageResolver {
  const AuthErrorMessageResolver._();

  static String resolve(AppLocalizations l10n, Object error) {
    final exception = ApiException.fromError(error);

    switch (exception.kind) {
      case ApiExceptionKind.timeout:
        return l10n.authErrorTimeout;
      case ApiExceptionKind.network:
        return l10n.authErrorNetwork;
      case ApiExceptionKind.badRequest:
      case ApiExceptionKind.unauthorized:
      case ApiExceptionKind.forbidden:
      case ApiExceptionKind.notFound:
      case ApiExceptionKind.unknown:
        break;
    }

    switch (exception.code) {
      case ApiErrorCode.invalidCredentials:
        return l10n.authErrorInvalidCredentials;
      case ApiErrorCode.accountPending:
        return l10n.authErrorAccountPending;
      case ApiErrorCode.accountRejected:
        return l10n.authErrorAccountRejected;
      case ApiErrorCode.emailAlreadyUsed:
        return l10n.authErrorEmailAlreadyUsed;
      case ApiErrorCode.invalidResidenceCode:
        return l10n.authErrorInvalidResidenceCode;
      case ApiErrorCode.invalidCaptcha:
        return l10n.authErrorInvalidCaptcha;
      case ApiErrorCode.validationError:
        return l10n.authErrorInvalidRequest;
      case ApiErrorCode.unauthorized:
        return l10n.authErrorUnauthorized;
      case ApiErrorCode.forbidden:
      case ApiErrorCode.notFound:
      case ApiErrorCode.unknown:
        return _fallbackMessage(l10n, exception);
    }
  }

  static String resolveAccountStatus(AppLocalizations l10n, UserStatus status) {
    return switch (status) {
      UserStatus.pending => l10n.authErrorAccountPending,
      UserStatus.rejected => l10n.authErrorAccountRejected,
      _ => l10n.authErrorTechnical,
    };
  }

  static String _fallbackMessage(
    AppLocalizations l10n,
    ApiException exception,
  ) {
    final message = exception.message.trim();
    if (message.isNotEmpty) {
      return message;
    }
    return l10n.authErrorTechnical;
  }
}
