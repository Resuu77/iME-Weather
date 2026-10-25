/// CityModel — represents a predefined city entry.
///
/// Used both for the built-in Turkmenistan list and for GPS-resolved cities.
class CityModel {
  const CityModel({
    required this.id,
    required this.nameEn,
    required this.nameRu,
    required this.nameTk,
    required this.lat,
    required this.lon,
  });

  final String id;
  final String nameEn;
  final String nameRu;
  final String nameTk;
  final double lat;
  final double lon;

  /// Returns the localised name for the given language code.
  String name(String langCode) {
    switch (langCode) {
      case 'ru':
        return nameRu;
      case 'tk':
        return nameTk;
      default:
        return nameEn;
    }
  }

  /// GPS-detected city with a generated id.
  factory CityModel.fromGps({required double lat, required double lon}) =>
      CityModel(
        id: 'gps_${lat.toStringAsFixed(2)}_${lon.toStringAsFixed(2)}',
        nameEn: 'My Location',
        nameRu: 'Моё место',
        nameTk: 'Meniň ýerim',
        lat: lat,
        lon: lon,
      );

  factory CityModel.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as Map<String, dynamic>;
    return CityModel(
      id: json['id'] as String,
      nameEn: name['en'] as String,
      nameRu: name['ru'] as String,
      nameTk: name['tk'] as String,
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is CityModel && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'CityModel($id, $nameEn)';
}
