import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../storage/databaseHelper.dart';

class AuthentificationService {
  final Logger logger = Logger();
  final SupabaseClient _client = Supabase.instance.client;

  /// Connexion avec Supabase en utilisant l'email et le mot de passe fournis.
  /// Renvoie true si la connexion a réussi.
  /// Les AuthException sont relancées pour que la page puisse afficher
  /// le message d'erreur (ex : "Invalid login credentials").
  Future<bool> login({required String login, required String pwd}) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: login,
        password: pwd,
      );

      if (response.user != null && response.session != null) {
        // enregistrement du token et de l'email dans shared_preferences
        final preferences = await SharedPreferences.getInstance();
        await preferences.setString('token', response.session!.accessToken);
        await preferences.setString('email', login);

        logger.i(preferences.getString('email'));
        // On ne logge qu'un extrait du token : un JWT complet dans les logs
        // permettrait à quiconque y a accès d'usurper la session.
        final token = preferences.getString('token') ?? '';
        logger.i('token : ${token.substring(0, token.length < 20 ? token.length : 20)}...');
        return true;
      }
      return false;
    } on AuthException catch (e) {
      // Gestion des exceptions liées à l'authentification.
      logger.e('erreur exception authentification : ${e.message}');
      rethrow;
    } catch (e) {
      logger.e('erreur login ou pwd authentification : $e');
      return false;
    }
  }

  /// Déconnexion : session Supabase, shared_preferences et cache local.
  Future<void> logout() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      logger.e('erreur déconnexion : $e');
    }
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove('token');
    await preferences.remove('email');
    await DatabaseHelper.instance.clearClients();
  }

  Future<String?> getEmail() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString('email');
  }

  Future<String?> getToken() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString('token');
  }

  /// Envoie l'email de réinitialisation du mot de passe.
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }
}
