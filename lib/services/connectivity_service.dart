import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:logger/logger.dart';

/// Vérification de la connexion Internet.
class ConnectivityService {
  static final Logger _logger = Logger();

  /// Renvoie true si une connexion Internet est disponible.
  /// Attention : c'est asynchrone, il faut toujours faire
  /// `if (!await ConnectivityService.checkInternet())`.
  static Future<bool> checkInternet() async {
    try {
      // Versions >= 3.0 du package. Sur une version plus ancienne,
      // remplacer par : InternetConnectionChecker().hasConnection
      return await InternetConnectionChecker.instance.hasConnection;
    } catch (e) {
      _logger.e('Erreur vérification connexion : $e');
      return false;
    }
  }
}
