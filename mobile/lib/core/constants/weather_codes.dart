/// WMO Weather Interpretation Codes (WW)
/// https://open-meteo.com/en/docs#weathervariables
///
/// Each code maps to an icon emoji, a label key (used for l10n lookup),
/// and a background category used to drive the dynamic gradient.
library;

enum BackgroundCategory { clearDay, clearNight, cloudy, rain, snow, storm }

class WeatherCodeInfo {
  const WeatherCodeInfo({
    required this.icon,
    required this.labelKey,
    required this.category,
  });

  /// Simple emoji icon — rendered inside CustomPaint for weather icons.
  final String icon;

  /// Key used to look up the translated label in AppLocalizations.
  final String labelKey;

  /// Drives the dynamic background gradient.
  final BackgroundCategory category;
}

const Map<int, WeatherCodeInfo> kWeatherCodes = {
  // Clear sky
  0: WeatherCodeInfo(icon: '☀️', labelKey: 'wmo_0', category: BackgroundCategory.clearDay),
  // Mainly clear
  1: WeatherCodeInfo(icon: '🌤️', labelKey: 'wmo_1', category: BackgroundCategory.clearDay),
  // Partly cloudy
  2: WeatherCodeInfo(icon: '⛅', labelKey: 'wmo_2', category: BackgroundCategory.cloudy),
  // Overcast
  3: WeatherCodeInfo(icon: '☁️', labelKey: 'wmo_3', category: BackgroundCategory.cloudy),
  // Fog
  45: WeatherCodeInfo(icon: '🌫️', labelKey: 'wmo_45', category: BackgroundCategory.cloudy),
  // Icy fog
  48: WeatherCodeInfo(icon: '🌫️', labelKey: 'wmo_48', category: BackgroundCategory.cloudy),
  // Light drizzle
  51: WeatherCodeInfo(icon: '🌦️', labelKey: 'wmo_51', category: BackgroundCategory.rain),
  // Moderate drizzle
  53: WeatherCodeInfo(icon: '🌦️', labelKey: 'wmo_53', category: BackgroundCategory.rain),
  // Dense drizzle
  55: WeatherCodeInfo(icon: '🌧️', labelKey: 'wmo_55', category: BackgroundCategory.rain),
  // Slight rain
  61: WeatherCodeInfo(icon: '🌧️', labelKey: 'wmo_61', category: BackgroundCategory.rain),
  // Moderate rain
  63: WeatherCodeInfo(icon: '🌧️', labelKey: 'wmo_63', category: BackgroundCategory.rain),
  // Heavy rain
  65: WeatherCodeInfo(icon: '🌧️', labelKey: 'wmo_65', category: BackgroundCategory.rain),
  // Slight snow
  71: WeatherCodeInfo(icon: '🌨️', labelKey: 'wmo_71', category: BackgroundCategory.snow),
  // Moderate snow
  73: WeatherCodeInfo(icon: '❄️', labelKey: 'wmo_73', category: BackgroundCategory.snow),
  // Heavy snow
  75: WeatherCodeInfo(icon: '❄️', labelKey: 'wmo_75', category: BackgroundCategory.snow),
  // Snow grains
  77: WeatherCodeInfo(icon: '🌨️', labelKey: 'wmo_77', category: BackgroundCategory.snow),
  // Slight showers
  80: WeatherCodeInfo(icon: '🌦️', labelKey: 'wmo_80', category: BackgroundCategory.rain),
  // Moderate showers
  81: WeatherCodeInfo(icon: '🌧️', labelKey: 'wmo_81', category: BackgroundCategory.rain),
  // Violent showers
  82: WeatherCodeInfo(icon: '⛈️', labelKey: 'wmo_82', category: BackgroundCategory.storm),
  // Slight snow showers
  85: WeatherCodeInfo(icon: '🌨️', labelKey: 'wmo_85', category: BackgroundCategory.snow),
  // Heavy snow showers
  86: WeatherCodeInfo(icon: '🌨️', labelKey: 'wmo_86', category: BackgroundCategory.snow),
  // Thunderstorm
  95: WeatherCodeInfo(icon: '⛈️', labelKey: 'wmo_95', category: BackgroundCategory.storm),
  // Thunderstorm w/ slight hail
  96: WeatherCodeInfo(icon: '⛈️', labelKey: 'wmo_96', category: BackgroundCategory.storm),
  // Thunderstorm w/ heavy hail
  99: WeatherCodeInfo(icon: '⛈️', labelKey: 'wmo_99', category: BackgroundCategory.storm),
};

WeatherCodeInfo getWeatherInfo(int code) =>
    kWeatherCodes[code] ??
    const WeatherCodeInfo(
      icon: '🌡️',
      labelKey: 'wmo_unknown',
      category: BackgroundCategory.cloudy,
    );
