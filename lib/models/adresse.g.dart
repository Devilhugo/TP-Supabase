// GENERATED CODE - DO NOT MODIFY BY HAND
// (identique à ce que produit `dart run build_runner build`)

part of 'adresse.dart';

class AdresseAdapter extends TypeAdapter<Adresse> {
  @override
  final int typeId = 2;

  @override
  Adresse read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Adresse(
      rue: fields[0] as String,
      codePostal: fields[1] as String,
      ville: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Adresse obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.rue)
      ..writeByte(1)
      ..write(obj.codePostal)
      ..writeByte(2)
      ..write(obj.ville);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdresseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
