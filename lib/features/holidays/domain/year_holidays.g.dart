// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'year_holidays.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class YearHolidaysCacheAdapter extends TypeAdapter<YearHolidaysCache> {
  @override
  final typeId = 1;

  @override
  YearHolidaysCache read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return YearHolidaysCache(
      year: (fields[0] as num).toInt(),
      dates: (fields[1] as Map).cast<String, String>(),
      fetchedAt: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, YearHolidaysCache obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.year)
      ..writeByte(1)
      ..write(obj.dates)
      ..writeByte(2)
      ..write(obj.fetchedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is YearHolidaysCacheAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
