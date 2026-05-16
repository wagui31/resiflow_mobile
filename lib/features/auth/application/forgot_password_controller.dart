import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../data/auth_repository.dart';
import '../domain/auth_models.dart';

final forgotPasswordControllerProvider = AutoDisposeNotifierProvider<
  ForgotPasswordController,
  ForgotPasswordState
>(ForgotPasswordController.new);

class ForgotPasswordState {
  const ForgotPasswordState({
    this.isSubmitting = false,
    this.lastRequestedEmail,
    this.lastRequestMessage,
    this.resetSessionToken,
    this.resetSessionExpiresAt,
    this.lastError,
  });

  final bool isSubmitting;
  final String? lastRequestedEmail;
  final String? lastRequestMessage;
  final String? resetSessionToken;
  final DateTime? resetSessionExpiresAt;
  final ApiException? lastError;

  ForgotPasswordState copyWith({
    bool? isSubmitting,
    String? lastRequestedEmail,
    String? lastRequestMessage,
    String? resetSessionToken,
    DateTime? resetSessionExpiresAt,
    ApiException? lastError,
    bool clearError = false,
  }) {
    return ForgotPasswordState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      lastRequestedEmail: lastRequestedEmail ?? this.lastRequestedEmail,
      lastRequestMessage: lastRequestMessage ?? this.lastRequestMessage,
      resetSessionToken: resetSessionToken ?? this.resetSessionToken,
      resetSessionExpiresAt:
          resetSessionExpiresAt ?? this.resetSessionExpiresAt,
      lastError: clearError ? null : (lastError ?? this.lastError),
    );
  }
}

class ForgotPasswordController extends AutoDisposeNotifier<ForgotPasswordState> {
  @override
  ForgotPasswordState build() => const ForgotPasswordState();

  Future<ForgotPasswordRequestCodeResult> requestCode({
    required String email,
  }) async {
    state = state.copyWith(
      isSubmitting: true,
      lastRequestedEmail: email.trim(),
      clearError: true,
      resetSessionToken: null,
      resetSessionExpiresAt: null,
    );

    try {
      final result = await ref
          .read(authRepositoryProvider)
          .requestPasswordResetCode(email: email);
      state = state.copyWith(
        isSubmitting: false,
        lastRequestMessage: result.message,
        clearError: true,
      );
      return result;
    } catch (error) {
      final exception = ApiException.fromError(error);
      state = state.copyWith(
        isSubmitting: false,
        lastError: exception,
      );
      throw exception;
    }
  }

  Future<ForgotPasswordVerifyCodeResult> verifyCode({
    required String email,
    required String code,
  }) async {
    state = state.copyWith(
      isSubmitting: true,
      lastRequestedEmail: email.trim(),
      clearError: true,
    );

    try {
      final result = await ref
          .read(authRepositoryProvider)
          .verifyPasswordResetCode(email: email, code: code);
      state = state.copyWith(
        isSubmitting: false,
        resetSessionToken: result.resetSessionToken,
        resetSessionExpiresAt: result.resetSessionExpiresAt,
        clearError: true,
      );
      return result;
    } catch (error) {
      final exception = ApiException.fromError(error);
      state = state.copyWith(
        isSubmitting: false,
        lastError: exception,
      );
      throw exception;
    }
  }

  Future<void> resetPassword({
    required String resetSessionToken,
    required String newPassword,
    required String confirmPassword,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      await ref.read(authRepositoryProvider).resetForgottenPassword(
        resetSessionToken: resetSessionToken,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      state = state.copyWith(
        isSubmitting: false,
        clearError: true,
      );
    } catch (error) {
      final exception = ApiException.fromError(error);
      state = state.copyWith(
        isSubmitting: false,
        lastError: exception,
      );
      throw exception;
    }
  }
}
