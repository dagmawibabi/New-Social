// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingsAdapter extends TypeAdapter<Settings> {
  @override
  final int typeId = 0;

  @override
  Settings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Settings()
      ..darkMode = fields[0] as bool
      ..metricSystem = fields[1] as bool
      ..appBarImages = fields[2] as bool
      ..reduceAnimations = fields[3] as bool
      ..marqueMusicTitle = fields[4] as bool
      ..hideNavBarOnScroll = fields[5] as bool
      ..fullscreenModeOnScroll = fields[6] as bool
      ..floatingNavBar = fields[7] as bool;
  }

  @override
  void write(BinaryWriter writer, Settings obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.darkMode)
      ..writeByte(1)
      ..write(obj.metricSystem)
      ..writeByte(2)
      ..write(obj.appBarImages)
      ..writeByte(3)
      ..write(obj.reduceAnimations)
      ..writeByte(4)
      ..write(obj.marqueMusicTitle)
      ..writeByte(5)
      ..write(obj.hideNavBarOnScroll)
      ..writeByte(6)
      ..write(obj.fullscreenModeOnScroll)
      ..writeByte(7)
      ..write(obj.floatingNavBar);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
