import 'dart:convert';
import 'dart:async';

import 'package:chatterbox/models/error_model.dart';
import 'package:chatterbox/models/user_model.dart';
import 'package:chatterbox/repository/local_storage_repository.dart';
import 'package:chatterbox/utils/user_facing_error.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';

String host = dotenv.env['HOST'] ?? '';

// Replace these placeholders with the OAuth client IDs from Google Cloud.
// clientId is the app/client ID; serverClientId is the web OAuth client ID
// used by Android to identify the backend audience.
final googleSignInClientId = dotenv.env['GOOGLE_CLIENT_ID'] ?? '';
final googleSignInServerClientId = dotenv.env['GOOGLE_SERVER_CLIENT_ID'] ?? '';

final authRepositoryProvider = Provider((ref) {
  final client = Client();
  ref.onDispose(client.close);
  return AuthRepository(
    googleSignIn: GoogleSignIn.instance,
    client: client,
    localStorageRepository: LocalStorageRepository(),
  );
});

final userProvider = StateProvider<UserModel?>((ref) => null);

final usersListProvider = StateProvider<List<UserModel>>((ref) => []);

class AuthRepository {
  final GoogleSignIn _googleSignIn;
  final Client _client;
  final LocalStorageRepository _localStorageRepository;

  AuthRepository({
    required this._googleSignIn,
    required this._client,
    required this._localStorageRepository,
  });

  late final Future<void> _googleSignInInitialization = _googleSignIn
      .initialize(
        clientId: googleSignInClientId,
        serverClientId: googleSignInServerClientId,
      );

  // Google Sign in method
  Future<ErrorModel> signInWithGoogle() async {
    ErrorModel error = ErrorModel(
      error: 'Failed to sign in. Please try again.',
      data: null,
    );
    try {
      await _googleSignInInitialization;
      if (!_googleSignIn.supportsAuthenticate()) {
        return ErrorModel(
          error: 'Google sign-in is not supported on this platform.',
          data: null,
        );
      }

      final account = await _googleSignIn.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        return ErrorModel(
          error: 'Google did not return an ID token. Please try again.',
          data: null,
        );
      }
      final userAcc = UserModel(
        uid: '',
        name: account.displayName ?? 'Unknown',
        email: account.email,
        profilePic: account.photoUrl ?? '',
        token: '',
      );
      final response = await _client.post(
        Uri.parse('$host/signup'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $idToken',
        },
        body: userAcc.toJson(),
      );
      switch (response.statusCode) {
        case 200:
          final responseBody = jsonDecode(response.body);
          final newUser = userAcc.copyWith(
            uid: responseBody['user']['_id'],
            token: responseBody['token'],
          );
          error = ErrorModel(error: null, data: newUser);
          await _localStorageRepository.setToken(newUser.token);
          break;
        default:
          error = ErrorModel(
            error: userFacingHttpError(
              response.statusCode,
              fallback: 'Sign-in failed. Please try again.',
              unauthorizedMessage:
                  'Google could not verify your account. Please try again.',
            ),
            data: null,
          );
          break;
      }
    } catch (e) {
      debugPrint('Google sign-in failed: $e');
      error = ErrorModel(
        error: userFacingException(
          e,
          fallback: 'Sign-in failed. Please try again.',
        ),
        data: null,
      );
    }
    return error;
  }

  // GET user data from DB
  Future<ErrorModel> getUserData() async {
    ErrorModel error = ErrorModel(
      error: 'Failed to fetch user data',
      data: null,
    );
    String? token = await _localStorageRepository.getToken();
    try {
      if (token != null) {
        var response = await _client.get(
          Uri.parse('$host/'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'x-auth-token': token,
          },
        );
        switch (response.statusCode) {
          case 200:
            final newUser = UserModel.fromJson(
              jsonEncode(jsonDecode(response.body)['user']),
            ).copyWith(token: token);
            error = ErrorModel(error: null, data: newUser);
            await _localStorageRepository.setToken(newUser.token);
            break;
          default:
            if (response.statusCode == 401 || response.statusCode == 404) {
              await _localStorageRepository.setToken('');
            }
            error = ErrorModel(
              error: userFacingHttpError(
                response.statusCode,
                fallback: 'Could not load your account. Please try again.',
                notFoundMessage:
                    'Your account could not be found. Please sign in again.',
              ),
              data: null,
            );
            break;
        }
      } else {
        error = ErrorModel(error: 'Token is null', data: null);
      }
    } catch (e) {
      debugPrint('Unable to restore account: $e');
      error = ErrorModel(
        error: userFacingException(
          e,
          fallback: 'Could not load your account. Please try again.',
        ),
        data: null,
      );
    }
    return error;
  }

  // GET all existing users
  Future<ErrorModel> getAllUsers(String? token) async {
    if (token == null || token.isEmpty) {
      return ErrorModel(
        error: 'Your session expired. Please sign in again.',
        data: null,
      );
    }

    const maxAttempts = 3;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final response = await _client
            .get(
              Uri.parse('$host/users'),
              headers: {
                'Content-Type': 'application/json; charset=UTF-8',
                'x-auth-token': token,
              },
            )
            .timeout(const Duration(seconds: 8));

        if (response.statusCode == 200) {
          final responseBody = jsonDecode(response.body);
          final users = (responseBody['users'] as List)
              .map((user) => UserModel.fromJson(jsonEncode(user)))
              .toList();
          return ErrorModel(error: null, data: users);
        }

        if (response.statusCode >= 500 && attempt < maxAttempts) {
          await Future<void>.delayed(Duration(milliseconds: 400 * attempt));
          continue;
        }

        return ErrorModel(
          error: userFacingHttpError(
            response.statusCode,
            fallback: 'Could not load people. Please try again.',
          ),
          data: null,
        );
      } catch (error) {
        debugPrint('Unable to fetch people (attempt $attempt): $error');
        final isTemporaryNetworkError =
            error is ClientException || error is TimeoutException;
        if (isTemporaryNetworkError && attempt < maxAttempts) {
          await Future<void>.delayed(Duration(milliseconds: 400 * attempt));
          continue;
        }
        return ErrorModel(
          error: userFacingException(
            error,
            fallback: 'Could not load people. Please try again.',
          ),
          data: null,
        );
      }
    }

    return ErrorModel(
      error: 'Could not load people. Please try again.',
      data: null,
    );
  }

  Future<void> logOut() async {
    try {
      await _googleSignInInitialization;
      await _googleSignIn.signOut();
    } finally {
      await _localStorageRepository.setToken('');
    }
  }
}
