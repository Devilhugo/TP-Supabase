// GENERATED CODE - DO NOT MODIFY BY HAND
// (identique à ce que produit `dart run build_runner build`)

part of 'client.dart';

class ClientAdapter extends TypeAdapter<Client> {
  @override
  final int typeId = 1;

  @override
  Client read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Client(
      id: fields[0] as int,
      prenom: fields[1] as String,
      nom: fields[2] as String,
      telephone: fields[4] as String,
      adresse: fields[5] as Adresse,
      email: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Client obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.prenom)
      ..writeByte(2)
      ..write(obj.nom)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.telephone)
      ..writeByte(5)
      ..write(obj.adresse);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClientAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
