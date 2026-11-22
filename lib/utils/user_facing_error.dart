import 'dart:async';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' show ClientException;

String userFacingException(Object error, {required String fallback}) {
  if (error is GoogleSignInException) {
    return switch (error.code) {
      GoogleSignInExceptionCode.canceled => 'Sign-in was canceled.',
      GoogleSignInExceptionCode.interrupted =>
        'Sign-in was interrupted. Please try again.',
      GoogleSignInExceptionCode.clientConfigurationError =>
        'Google sign-in is not configured correctly.',
      GoogleSignInExceptionCode.providerConfigurationError =>
        'Google sign-in is unavailable right now. Please try again later.',
      GoogleSignInExceptionCode.uiUnavailable =>
        'Google sign-in could not open. Please try again.',
      GoogleSignInExceptionCode.userMismatch =>
        'Please choose the Google account you want to use.',
      _ => fallback,
    };
  }

  final details = error.toString().toLowerCase();
  if (error is TimeoutException ||
      error is ClientException ||
      details.contains('socketexception') ||
      details.contains('handshakeexception') ||
      details.contains('connection timed out') ||
      details.contains('failed host lookup') ||
      details.contains('network is unreachable')) {
    return 'Could not reach ChatterBox. Make sure the server is running '
        'and your phone is on the same Wi-Fi.';
  }

  if (error is FormatException) {
    return 'We received an unexpected response. Please try again.';
  }

  return fallback;
}

String userFacingHttpError(
  int statusCode, {
  required String fallback,
  String unauthorizedMessage = 'Your session expired. Please sign in again.',
  String notFoundMessage = 'We could not find what you were looking for.',
}) {
  if (statusCode == 401) return unauthorizedMessage;
  if (statusCode == 403) return 'You do not have permission to do that.';
  if (statusCode == 404) return notFoundMessage;
  if (statusCode >= 500) {
    return 'ChatterBox is temporarily unavailable. Please try again shortly.';
  }
  return fallback;
}
