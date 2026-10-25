/// API configuration constants.
///
/// MODE CONFIGURATION:
/// By default, [kUseDirectOpenMeteo] is true, so the mobile app connects
/// DIRECTLY to Open-Meteo API (https://api.open-meteo.com/v1) without needing
/// any custom backend proxy or VPS.
///
/// When you are ready to deploy and use your VPS backend proxy:
/// 1. Set [kUseDirectOpenMeteo] = false (or pass --dart-define=USE_DIRECT_API=false)
/// 2. Set [kCustomBackendBaseUrl] to your VPS address or domain.
library;

/// When true (DEFAULT), the app talks directly to open-meteo.com.
/// Set to false when connecting through your VPS backend proxy.
const bool kUseDirectOpenMeteo = bool.fromEnvironment(
  'USE_DIRECT_API',
  defaultValue: true,
);

/// Direct Open-Meteo API endpoint
const String kOpenMeteoBaseUrl = 'https://api.open-meteo.com/v1';
const String kOpenMeteoForecastEndpoint = '$kOpenMeteoBaseUrl/forecast';

/// Custom VPS proxy base URL (used when [kUseDirectOpenMeteo] == false)
const String kCustomBackendBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://YOUR_VPS_IP:3000',
);

/// Endpoints for custom backend proxy
const String kWeatherProxyEndpoint = '$kCustomBackendBaseUrl/api/weather';
const String kCitiesProxyEndpoint = '$kCustomBackendBaseUrl/api/cities';
const String kHealthProxyEndpoint = '$kCustomBackendBaseUrl/api/health';

// Aliases for backwards compatibility
const String kApiBaseUrl = kCustomBackendBaseUrl;
const String kWeatherEndpoint = kWeatherProxyEndpoint;
const String kCitiesEndpoint = kCitiesProxyEndpoint;
const String kHealthEndpoint = kHealthProxyEndpoint;

/// HTTP request timeout
const Duration kRequestTimeout = Duration(seconds: 12);
