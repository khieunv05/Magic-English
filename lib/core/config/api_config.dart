class ApiConfig {

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://14bab2abe286.ngrok-free.app',
  );
}
