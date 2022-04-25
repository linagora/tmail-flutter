
import 'package:core/core.dart';

class _Benchmark {
  final Map<String, int> _starts = <String, int>{};

  void start(dynamic id) {
    if (BuildUtils.isDebugMode || BuildUtils.isProfileMode) {
      final String benchId = id.toString();
      if (_starts.containsKey(benchId)) {
        log('_Benchmark::start(): Benchmark already have comparing with id=$benchId in time');
      } else {
        _starts[benchId] = DateTime.now().microsecondsSinceEpoch;
      }
    }
  }

  double end(dynamic id) {
    if (BuildUtils.isDebugMode || BuildUtils.isProfileMode) {
      final String benchId = id.toString();
      if (!_starts.containsKey(benchId)) {
        throw Exception('In Benchmark not placed comparing with id=$benchId');
      }
      final double diff = (DateTime
          .now()
          .microsecondsSinceEpoch - _starts[benchId]!) / 1000;
      final String info = '$benchId need ${diff}ms';
      log('_Benchmark::end(): $info');
      _starts.remove(benchId);
      return diff;
    }
    return 0;
  }
}

final _Benchmark bench = _Benchmark();