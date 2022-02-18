
class AppConfig {
  static const baseUrl = String.fromEnvironment('SERVER_URL', defaultValue: '');
}