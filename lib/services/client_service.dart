import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/client.dart';
import '../storage/databaseHelper.dart';
import 'connectivity_service.dart';

/// Opérations sur les clients : Supabase (distant) <-> Hive (cache local).
class ClientService {
  final Logger logger = Logger();
  final DatabaseHelper _db = DatabaseHelper.instance;

  // Requête avec jointure sur la table adresse (clé étrangère id_adresse)
  static const String _select =
      'id,nom,prenom,tel,email,adresse(rue,codepostal,ville)';

  /// Récupère les clients depuis Supabase.
  Future<List<Client>> fetchFromSupabase() async {
    final List<Map<String, dynamic>> data = await Supabase.instance.client
        .from('client')
        .select(_select)
        .order('nom');
    return data.map((json) => Client.fromJson(json)).toList();
  }

  /// Copie les clients Supabase dans le cache Hive.
  /// Renvoie le nombre de clients synchronisés.
  Future<int> syncClients() async {
    final clients = await fetchFromSupabase();
    logger.i('nb clients local avant synchro : ${await _db.getNbClients()}');

    for (final client in clients) {
      try {
        logger.i(client.toString());
        // insertion si absent, mise à jour sinon
        await _db.upsertClient(client);
      } catch (e) {
        logger.e(e);
      }
    }

    // On retire du cache les clients supprimés côté Supabase
    final idsDistants = clients.map((c) => c.id).toSet();
    for (final local in await _db.getClients()) {
      if (!idsDistants.contains(local.id)) await _db.deleteClient(local.id);
    }
    return clients.length;
  }

  /// Clients à afficher : synchro si Internet, sinon cache local.
  Future<List<Client>> getClients() async {
    try {
      if (await ConnectivityService.checkInternet()) {
        await syncClients();
      }
    } catch (e) {
      logger.e('Synchro impossible, utilisation du cache : $e');
    }
    return _db.getClients();
  }

  /// Uniquement le cache local.
  Future<List<Client>> getCachedClients() => _db.getClients();
}
