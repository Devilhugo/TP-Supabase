import 'package:hive/hive.dart';

part 'adresse.g.dart';

@HiveType(typeId: 2)
class Adresse {
  @HiveField(0)
  String rue;

  @HiveField(1)
  String codePostal;

  @HiveField(2)
  String ville;

  Adresse({
    required this.rue,
    required this.codePostal,
    required this.ville,
  });

  /// codepostal est un int8 dans Supabase : on le convertit en String
  /// (un simple `as String` ferait planter l'appli).
  factory Adresse.fromJson(Map<String, dynamic> json) {
    return Adresse(
      rue: (json['rue'] ?? '').toString(),
      codePostal: (json['codepostal'] ?? '').toString(),
      ville: (json['ville'] ?? '').toString(),
    );
  }

  @override
  String toString() => '$rue $codePostal $ville';
}
