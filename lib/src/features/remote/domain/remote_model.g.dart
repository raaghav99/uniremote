// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remote_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RemoteModelAdapter extends TypeAdapter<RemoteModel> {
  @override
  final int typeId = 0;

  @override
  RemoteModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RemoteModel(
      id: fields[0] as String,
      name: fields[1] as String,
      deviceType: fields[2] as String,
      brandName: fields[3] as String,
      iconEmoji: fields[4] as String,
      buttons: (fields[5] as List).cast<IrButton>(),
    );
  }

  @override
  void write(BinaryWriter writer, RemoteModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.deviceType)
      ..writeByte(3)
      ..write(obj.brandName)
      ..writeByte(4)
      ..write(obj.iconEmoji)
      ..writeByte(5)
      ..write(obj.buttons);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RemoteModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class IrButtonAdapter extends TypeAdapter<IrButton> {
  @override
  final int typeId = 1;

  @override
  IrButton read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IrButton(
      label: fields[0] as String,
      icon: fields[1] as String,
      freqHz: fields[2] as int,
      pattern: (fields[3] as List).cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, IrButton obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.label)
      ..writeByte(1)
      ..write(obj.icon)
      ..writeByte(2)
      ..write(obj.freqHz)
      ..writeByte(3)
      ..write(obj.pattern);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IrButtonAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
