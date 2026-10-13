import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../models/client.dart';
import '../services/client_service.dart';

class ClientPage extends StatefulWidget {
  static const route = '/clients';
  const ClientPage({super.key});

  @override
  State<ClientPage> createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  final Logger logger = Logger();
  final ClientService _service = ClientService();
  late Future<List<Client>> _future;

  @override
  void initState() {
    super.initState();
    // Requête lancée une seule fois (et pas à chaque build)
    _future = _service.getClients();
  }

  Future<void> _rafraichir() async {
    final future = _service.getClients();
    setState(() => _future = future);
    await future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Liste des clients')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
      ),
      body: FutureBuilder<List<Client>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }
          final clients = snapshot.data ?? [];
          logger.i('nb clients affichés : ${clients.length}');

          return RefreshIndicator(
            onRefresh: _rafraichir,
            child: clients.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 200),
                      Center(child: Text('Aucun client. Tirez pour actualiser.')),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: clients.length,
                    itemBuilder: (context, index) {
                      final client = clients[index];
                      return ListTile(
                        title: Text('${client.prenom} ${client.nom}'),
                        subtitle: Text(
                          '${client.adresse}\n'
                          '${client.email ?? ''}  tel: ${client.telephone}',
                        ),
                        isThreeLine: true,
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}
