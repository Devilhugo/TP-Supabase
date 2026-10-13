import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';

import '../models/client.dart';

/// DatabaseHelper - tampon entre les modèles et la base de données Hive.
/// Hive.initFlutter() et l'enregistrement des adapters sont faits une seule
/// fois dans main.dart.
class DatabaseHelper {
  // Création d'une instance unique de DatabaseHelper (singleton).
  static final DatabaseHelper instance = DatabaseHelper._init();
  DatabaseHelper._init();

  static const String _boxName = 'clients';
  final Logger logger = Logger();

  /// Récupère (ou ouvre) la boîte Hive des clients.
  Future<Box<Client>> get _clientBox async {
    if (Hive.isBoxOpen(_boxName)) return Hive.box<Client>(_boxName);
    return Hive.openBox<Client>(_boxName);
  }

  /// Insère un nouveau client dans la base de données.
  Future<void> insertClient(Client client) async {
    final box = await _clientBox;
    await box.put(client.id, client);
  }

  /// Met à jour un client.
  Future<void> updateClient(Client client) async {
    final box = await _clientBox;
    await box.put(client.id, client);
  }

  /// Insère le client s'il n'existe pas, le met à jour sinon.
  Future<void> upsertClient(Client client) async {
    if (await getClient(client.id) == null) {
      await insertClient(client);
    } else {
      await updateClient(client);
    }
  }

  /// Récupère un client par son id (null s'il n'est pas en cache).
  Future<Client?> getClient(int id) async {
    final box = await _clientBox;
    return box.get(id);
  }

  /// Récupère tous les clients stockés dans la base de données locale.
  Future<List<Client>> getClients() async {
    final box = await _clientBox;
    final clients = box.values.toList();
    clients.sort((a, b) => a.nom.toLowerCase().compareTo(b.nom.toLowerCase()));
    return clients;
  }

  /// Nombre de clients en cache.
  Future<int> getNbClients() async {
    final box = await _clientBox;
    return box.length;
  }

  /// Supprime un client du cache.
  Future<void> deleteClient(int id) async {
    final box = await _clientBox;
    await box.delete(id);
  }

  /// Supprime tous les clients de la base de données.
  Future<void> clearClients() async {
    final box = await _clientBox;
    await box.clear();
  }

  /// Ferme la bdd pour libérer les ressources.
  Future<void> close() async {
    final box = await _clientBox;
    await box.close();
  }

  /// Supprime tous les fichiers .hive de l'application.
  Future<void> deleteAllHive() async {
    await Hive.deleteFromDisk();
  }
}
