import '../data/models/city_model.dart';

/// Predefined list of Turkmenistan cities embedded in the app.
/// Hardcoded with precise coordinates and trilingual names so the mobile app
/// operates completely independently of any backend /api/cities endpoint.
const List<CityModel> kTurkmenistanCities = [
  CityModel(
    id: 'ashgabat',
    nameEn: 'Ashgabat',
    nameRu: 'Ашхабад',
    nameTk: 'Aşgabat',
    lat: 37.9601,
    lon: 58.3261,
  ),
  CityModel(
    id: 'mary',
    nameEn: 'Mary',
    nameRu: 'Мары',
    nameTk: 'Mary',
    lat: 37.6006,
    lon: 61.8311,
  ),
  CityModel(
    id: 'turkmenabat',
    nameEn: 'Turkmenabat',
    nameRu: 'Туркменабат',
    nameTk: 'Türkmenabat',
    lat: 39.0833,
    lon: 63.5667,
  ),
  CityModel(
    id: 'dashoguz',
    nameEn: 'Dashoguz',
    nameRu: 'Дашогуз',
    nameTk: 'Daşoguz',
    lat: 41.8361,
    lon: 59.9639,
  ),
  CityModel(
    id: 'balkanabat',
    nameEn: 'Balkanabat',
    nameRu: 'Балканабат',
    nameTk: 'Balkanabat',
    lat: 39.5117,
    lon: 54.3694,
  ),
  CityModel(
    id: 'turkmenbasy',
    nameEn: 'Turkmenbasy',
    nameRu: 'Туркменбаши',
    nameTk: 'Türkmenbaşy',
    lat: 40.0000,
    lon: 52.9667,
  ),
];

/// Default city when opening the app (Ashgabat)
final CityModel kDefaultCity = kTurkmenistanCities[0];
/// Lookup map by city id
final Map<String, CityModel> kTurkmenistanCitiesMap = {
  for (final city in kTurkmenistanCities) city.id: city,
};

/// Get a Turkmenistan city by ID, or null if not found
CityModel? getTurkmenistanCityById(String id) => kTurkmenistanCitiesMap[id];
