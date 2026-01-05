class ApiConfig {

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://844e1eac2b60.ngrok-free.app',
  );
}
