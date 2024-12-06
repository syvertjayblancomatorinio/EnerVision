// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'all_devices_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ApplianceAdapter extends TypeAdapter<Appliance> {
  @override
  final int typeId = 0;

  @override
  Appliance read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Appliance(
      applianceId: fields[0] as String,
      applianceName: fields[1] as String,
      wattage: fields[2] as double,
      usagePatternPerDay: fields[3] as double,
      selectedDays: (fields[4] as List).cast<int>(),
      monthlyCost: fields[5] as double,
      createdAt: fields[6] as DateTime,
      updatedAt: fields[7] as DateTime?,
      deletedAt: fields[8] as DateTime?,
      userId: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Appliance obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.applianceId)
      ..writeByte(1)
      ..write(obj.applianceName)
      ..writeByte(2)
      ..write(obj.wattage)
      ..writeByte(3)
      ..write(obj.usagePatternPerDay)
      ..writeByte(4)
      ..write(obj.selectedDays)
      ..writeByte(5)
      ..write(obj.monthlyCost)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt)
      ..writeByte(8)
      ..write(obj.deletedAt)
      ..writeByte(9)
      ..write(obj.userId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApplianceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
