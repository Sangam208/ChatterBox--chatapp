import 'dart:convert';
import 'package:chatterbox/models/error_model.dart';
import 'package:chatterbox/models/user_model.dart';
import 'package:chatterbox/repository/local_storage_repository.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';

String host = dotenv.env['HOST'] ?? '';

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(
    googleSignIn: GoogleSignIn(),
    client: Client(),
    localStorageRepository: LocalStorageRepository(),
  ),
);

final userProvider = StateProvider<UserModel?>((ref) => null);

final usersListProvider = StateProvider<List<UserModel>>((ref) => []);

class AuthRepository {
  final GoogleSignIn _googleSignIn;
  final Client _client;
  final LocalStorageRepository _localStorageRepository;

  AuthRepository({
    required GoogleSignIn googleSignIn,
    required Client client,
    required LocalStorageRepository localStorageRepository,
  }) : _googleSignIn = googleSignIn,
       _client = client,
       _localStorageRepository = localStorageRepository;

  // Google Sign in method
  Future<ErrorModel> signInWithGoogle() async {
    ErrorModel error = ErrorModel(
      error: 'Failed to sign in. Please try again.',
      data: null,
    );
    try {
      final user = await _googleSignIn.signIn();
      if (user != null) {
        final userAcc = UserModel(
          uid: '',
          name: user.displayName ?? 'Unknown',
          email: user.email,
          profilePic: user.photoUrl ?? '',
          token: '',
        );
        var response = await _client.post(
          Uri.parse('$host/signup'),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: userAcc.toJson(),
        );
        switch (response.statusCode) {
          case 200:
            final newUser = userAcc.copyWith(
              uid: jsonDecode(response.body)['user']['_id'],
              token: jsonDecode(response.body)['token'],
            );
            error = ErrorModel(error: null, data: newUser);
            _localStorageRepository.setToken(newUser.token);
            break;
          default:
            error = ErrorModel(error: 'Sign in failed', data: null);
            break;
        }
      } else {
        error = ErrorModel(error: 'User does not exist', data: null);
      }
    } catch (e) {
      debugPrint(e.toString());
      error = ErrorModel(error: e.toString(), data: null);
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
            _localStorageRepository.setToken(newUser.token);
            break;
          default:
            error = ErrorModel(
              error:
                  'Status code: ${response.statusCode}\n Failed to fetch user data',
              data: null,
            );
            break;
        }
      } else {
        error = ErrorModel(error: 'Token is null', data: null);
      }
    } catch (e) {
      debugPrint(e.toString());
      error = ErrorModel(error: e.toString(), data: null);
    }
    return error;
  }

  // GET all existing users
  Future<ErrorModel> getAllUsers(String? token) async {
    ErrorModel error = ErrorModel(error: 'Failed to fetch users', data: null);
    try {
      if (token != null) {
        var response = await _client.get(
          Uri.parse('$host/users'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'x-auth-token': token,
          },
        );
        switch (response.statusCode) {
          case 200:
            // Decode the response body into a Map<String, dynamic>
            Map<String, dynamic> responseBody = jsonDecode(response.body);

            // Get the 'users' list from the response
            List<dynamic> usersJson = responseBody['users'];

            // Convert each userJson map directly to a UserModel object
            List<UserModel> users =
                usersJson
                    .map(
                      (userJson) => UserModel.fromJson(jsonEncode(userJson)),
                    ) // Convert each map into a JSON string, then pass it to fromJson
                    .toList();

            error = ErrorModel(error: null, data: users);
            break;
          default:
            error = ErrorModel(
              error:
                  'Status code: ${response.statusCode}\n Failed to fetch users',
              data: null,
            );
            break;
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      error = ErrorModel(error: e.toString(), data: null);
    }
    return error;
  }

  void logOut() async {
    await _googleSignIn.signOut();
    _localStorageRepository.setToken('');
  }
}
