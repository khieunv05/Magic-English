class ApiConfig {
  /// Configure at build/run time with:
  /// `--dart-define=API_BASE_URL=https://your-host`
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://f02de3d722fa.ngrok-free.app',
  );
}
