import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/caching/entries/sentry_configuration_cache.dart';

class MockBinaryReader extends Mock implements BinaryReader {
  @override
  int readByte() => super.noSuchMethod(
        Invocation.method(#readByte, []),
        returnValue: 0,
      ) as int;
}

void main() {
  test('reads existing cached configuration without reporting consent', () {
    final reader = MockBinaryReader();
    when(reader.readByte()).thenReturnInOrder([
      13,
      0,
      1,
      2,
      3,
      4,
      5,
      6,
      7,
      8,
      9,
      10,
      11,
      12,
    ]);
    when(reader.read()).thenReturnInOrder([
      'https://public@example.com/1',
      'staging',
      '1.2.3',
      0.2,
      0.3,
      false,
      true,
      true,
      true,
      0.4,
      0.5,
      false,
      'abc123',
    ]);

    final config = SentryConfigurationCacheAdapter().read(reader);

    expect(config.dsn, 'https://public@example.com/1');
    expect(config.environment, 'staging');
    expect(config.release, '1.2.3');
    expect(config.tracesSampleRate, 0.2);
    expect(config.profilesSampleRate, 0.3);
    expect(config.enableLogs, isFalse);
    expect(config.isDebug, isTrue);
    expect(config.attachScreenshot, isTrue);
    expect(config.isAvailable, isTrue);
    expect(config.sessionSampleRate, 0.4);
    expect(config.onErrorSampleRate, 0.5);
    expect(config.enableFramesTracking, isFalse);
    expect(config.dist, 'abc123');
    expect(config.isReportingAllowed, isFalse);
  });
}
