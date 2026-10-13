import 'package:flutter_test/flutter_test.dart';

import 'package:tp_supabase/models/adresse.dart';
import 'package:tp_supabase/models/client.dart';

void main() {
  test('Client.fromJson convertit correctement les données Supabase', () {
    final client = Client.fromJson({
      'id': 1,
      'nom': 'Dupont',
      'prenom': 'Jean',
      'email': 'jean.dupont@example.com',
      'tel': '0601020304',
      'adresse': {'rue': '1 rue de Paris', 'codepostal': 75001, 'ville': 'Paris'},
    });

    expect(client.id, 1);
    expect(client.nom, 'Dupont');
    expect(client.prenom, 'Jean');
    expect(client.telephone, '0601020304');
    expect(client.adresse.codePostal, '75001');
    expect(client.adresse.ville, 'Paris');
  });

  test('Client.fromJson gère une adresse absente', () {
    final client = Client.fromJson({'id': 2, 'nom': 'Martin', 'prenom': 'Marie'});

    expect(client.email, isNull);
    expect(client.telephone, '');
    expect(client.adresse.rue, '');
  });

  test('Adresse.toString', () {
    final adresse = Adresse(rue: '1 rue de Paris', codePostal: '75001', ville: 'Paris');
    expect(adresse.toString(), '1 rue de Paris 75001 Paris');
  });
}
