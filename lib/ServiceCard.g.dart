// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ServiceCard.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ServiceCardAdapter extends TypeAdapter<ServiceCard> {
  @override
  final int typeId = 0;

  @override
  ServiceCard read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ServiceCard(
      serviceName: fields[0] as String,
      userName: fields[1] as String,
      currentPassword: fields[2] as String,
    )..previousPass = (fields[3] as List).cast<String>();
  }

  @override
  void write(BinaryWriter writer, ServiceCard obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.serviceName)
      ..writeByte(1)
      ..write(obj.userName)
      ..writeByte(2)
      ..write(obj.currentPassword)
      ..writeByte(3)
      ..write(obj.previousPass);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceCardAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
