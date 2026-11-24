/// Base URL of the Django REST Framework backend.
///
/// Defaults to `http://10.0.2.2:8000` (IP address of your host PC that can be
/// called from within Android emulator)
/// Override with `--dart-define=API_BASE_URL=http://localhost:8000` if you are
/// testing on Chrome/Web browser
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:8000',
);
