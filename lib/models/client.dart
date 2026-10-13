import 'package:hive/hive.dart';

import './adresse.dart';

part 'client.g.dart';

@HiveType(typeId: 1)
class Client {
  @HiveField(0)
  int id;

  @HiveField(1)
  String prenom;

  @HiveField(2)
  String nom;

  @HiveField(3)
  String? email;

  @HiveField(4)
  String telephone;

  @HiveField(5)
  Adresse adresse;

  Client({
    required this.id,
    required this.prenom,
    required this.nom,
    required this.telephone,
    required this.adresse,
    this.email,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    final adresseJson = json['adresse'];
    return Client(
      id: (json['id'] as num).toInt(),
      nom: (json['nom'] ?? '').toString(),
      prenom: (json['prenom'] ?? '').toString(),
      email: json['email'] as String?,
      telephone: (json['tel'] ?? '').toString(),
      adresse: adresseJson is Map
          ? Adresse.fromJson(Map<String, dynamic>.from(adresseJson))
          : Adresse(rue: '', codePostal: '', ville: ''),
    );
  }

  @override
  String toString() {
    return 'Client{id: $id, prenom: $prenom, nom: $nom, email: $email, '
        'telephone: $telephone, adresse: $adresse}';
  }
}
