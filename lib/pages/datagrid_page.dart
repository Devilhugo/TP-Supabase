import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../models/client.dart';
import '../services/client_service.dart';

class DatagridPage extends StatefulWidget {
  static const route = '/datagrid';
  const DatagridPage({super.key});

  @override
  State<DatagridPage> createState() => _DatagridPageState();
}

class _DatagridPageState extends State<DatagridPage> {
  ClientDataSource? _source;
  String? _erreur;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    try {
      final clients = await ClientService().getClients();
      if (!mounted) return;
      setState(() => _source = ClientDataSource(clients));
    } catch (e) {
      if (!mounted) return;
      setState(() => _erreur = e.toString());
    }
  }

  GridColumn _colonne(String nom, String libelle) {
    return GridColumn(
      columnName: nom,
      label: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        alignment: Alignment.centerLeft,
        child: Text(libelle,
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_erreur != null) {
      body = Center(child: Text('Erreur : $_erreur'));
    } else if (_source == null) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      body = SfDataGrid(
        source: _source!,
        allowSorting: true,
        gridLinesVisibility: GridLinesVisibility.both,
        headerGridLinesVisibility: GridLinesVisibility.both,
        columnWidthMode: ColumnWidthMode.auto,
        columns: [
          _colonne('id', 'ID'),
          _colonne('nom', 'Nom'),
          _colonne('prenom', 'Prénom'),
          _colonne('email', 'Email'),
          _colonne('tel', 'Téléphone'),
          _colonne('rue', 'Rue'),
          _colonne('codepostal', 'CP'),
          _colonne('ville', 'Ville'),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Datagrid clients')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
      ),
      body: body,
    );
  }
}

/// Source de données du datagrid Syncfusion.
class ClientDataSource extends DataGridSource {
  ClientDataSource(List<Client> clients) {
    _rows = clients
        .map<DataGridRow>((c) => DataGridRow(cells: [
              DataGridCell<int>(columnName: 'id', value: c.id),
              DataGridCell<String>(columnName: 'nom', value: c.nom),
              DataGridCell<String>(columnName: 'prenom', value: c.prenom),
              DataGridCell<String>(columnName: 'email', value: c.email ?? ''),
              DataGridCell<String>(columnName: 'tel', value: c.telephone),
              DataGridCell<String>(columnName: 'rue', value: c.adresse.rue),
              DataGridCell<String>(
                  columnName: 'codepostal', value: c.adresse.codePostal),
              DataGridCell<String>(columnName: 'ville', value: c.adresse.ville),
            ]))
        .toList();
  }

  List<DataGridRow> _rows = [];

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((cell) {
        return Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(cell.value.toString(), overflow: TextOverflow.ellipsis),
        );
      }).toList(),
    );
  }
}
