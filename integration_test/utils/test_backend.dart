/// Backend a test runs against; defaults to the --dart-define URL.
class TestBackend {
  final String url;
  final String? token;

  const TestBackend({required this.url, this.token});

  static const TestBackend fromDefines = TestBackend(
    url: String.fromEnvironment('BASIC_AUTH_URL'),
  );

  static TestBackend? _leased;

  static TestBackend get current => _leased ?? fromDefines;

  static TestBackend? get leased => _leased;

  static void use(TestBackend? backend) => _leased = backend;
}
