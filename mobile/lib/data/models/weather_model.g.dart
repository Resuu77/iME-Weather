// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HourlyEntryAdapter extends TypeAdapter<HourlyEntry> {
  @override
  final int typeId = 1;

  @override
  HourlyEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HourlyEntry(
      time: fields[0] as String,
      temperature: fields[1] as int,
      weatherCode: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, HourlyEntry obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.time)
      ..writeByte(1)
      ..write(obj.temperature)
      ..writeByte(2)
      ..write(obj.weatherCode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HourlyEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DailyEntryAdapter extends TypeAdapter<DailyEntry> {
  @override
  final int typeId = 2;

  @override
  DailyEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyEntry(
      date: fields[0] as String,
      weatherCode: fields[1] as int,
      tempMax: fields[2] as int,
      tempMin: fields[3] as int,
      uvIndexMax: fields[4] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, DailyEntry obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.weatherCode)
      ..writeByte(2)
      ..write(obj.tempMax)
      ..writeByte(3)
      ..write(obj.tempMin)
      ..writeByte(4)
      ..write(obj.uvIndexMax);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CurrentWeatherAdapter extends TypeAdapter<CurrentWeather> {
  @override
  final int typeId = 3;

  @override
  CurrentWeather read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CurrentWeather(
      temperature: fields[0] as int,
      apparentTemperature: fields[1] as int,
      humidity: fields[2] as int,
      windSpeed: fields[3] as int,
      weatherCode: fields[4] as int,
      isDay: fields[5] as bool,
      time: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CurrentWeather obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.temperature)
      ..writeByte(1)
      ..write(obj.apparentTemperature)
      ..writeByte(2)
      ..write(obj.humidity)
      ..writeByte(3)
      ..write(obj.windSpeed)
      ..writeByte(4)
      ..write(obj.weatherCode)
      ..writeByte(5)
      ..write(obj.isDay)
      ..writeByte(6)
      ..write(obj.time);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrentWeatherAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WeatherModelAdapter extends TypeAdapter<WeatherModel> {
  @override
  final int typeId = 0;

  @override
  WeatherModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WeatherModel(
      cityId: fields[0] as String,
      cityNameEn: fields[1] as String,
      cityNameRu: fields[2] as String,
      cityNameTk: fields[3] as String,
      timezone: fields[4] as String,
      current: fields[5] as CurrentWeather,
      hourly: (fields[6] as List).cast<HourlyEntry>(),
      daily: (fields[7] as List).cast<DailyEntry>(),
      fetchedAt: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, WeatherModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.cityId)
      ..writeByte(1)
      ..write(obj.cityNameEn)
      ..writeByte(2)
      ..write(obj.cityNameRu)
      ..writeByte(3)
      ..write(obj.cityNameTk)
      ..writeByte(4)
      ..write(obj.timezone)
      ..writeByte(5)
      ..write(obj.current)
      ..writeByte(6)
      ..write(obj.hourly)
      ..writeByte(7)
      ..write(obj.daily)
      ..writeByte(8)
      ..write(obj.fetchedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeatherModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
