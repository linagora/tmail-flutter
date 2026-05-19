import 'backend_reset_client.dart';

/// Singleton timing collector for Patrol integration tests.
///
/// Usage:
///   TestTimer().startTest(description);
///   await TestTimer().timedPhase('app_launch', setupTest);
///   // inside scenario:
///   await timedStep('openComposer', robots.threadRobot().openComposer);
///   // in tearDown:
///   await TestTimer().timedPhase('backend_reset', BackendResetClient.reset);
///   await TestTimer().printReport();
class TestTimer {
  static final TestTimer _instance = TestTimer._internal();
  factory TestTimer() => _instance;
  TestTimer._internal();

  String _testName = '';
  final Map<String, int> _phases = {};
  final List<Map<String, dynamic>> _steps = [];
  final Stopwatch _totalWatch = Stopwatch();

  String _status = 'unknown';

  void startTest(String name) {
    _testName = name;
    _status = 'unknown';
    _phases.clear();
    _steps.clear();
    _totalWatch
      ..reset()
      ..start();
  }

  void recordStatus(String status) {
    _status = status;
  }

  /// Time a top-level phase (app_launch, login, test_logic, backend_reset).
  Future<T> timedPhase<T>(String name, Future<T> Function() action) async {
    final watch = Stopwatch()..start();
    try {
      return await action();
    } finally {
      watch.stop();
      _phases[name] = watch.elapsedMilliseconds;
    }
  }

  /// Time an individual step inside runTestLogic().
  Future<T> timedStep<T>(String name, Future<T> Function() action) async {
    final watch = Stopwatch()..start();
    try {
      return await action();
    } finally {
      watch.stop();
      _steps.add({'name': name, 'ms': watch.elapsedMilliseconds});
    }
  }

  /// POST structured JSON timing report to the reset server's /timing endpoint.
  /// The server emits [TIMING_REPORT] to its stdout log, which is captured by
  /// the shell script and parsed by patrol-timing-report.py.
  /// Platform-agnostic: works on Android and web — no logcat dependency.
  Future<void> printReport() async {
    _totalWatch.stop();
    final report = <String, dynamic>{
      'test': _testName,
      'status': _status,
      'phases': Map<String, dynamic>.from(_phases),
      'steps': List<Map<String, dynamic>>.from(_steps),
      'total_ms': _totalWatch.elapsedMilliseconds,
    };
    await BackendResetClient.postTiming(report);
  }
}
