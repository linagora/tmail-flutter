import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/caching/clients/authentication_info_cache_client.dart';
import 'package:tmail_ui_user/features/caching/exceptions/local_storage_exception.dart';
import 'package:tmail_ui_user/features/caching/utils/session_storage_manager.dart';
import 'package:tmail_ui_user/features/login/data/model/authentication_info_cache.dart';

import 'authentication_info_cache_test_doubles.mocks.dart';

@GenerateNiceMocks([
  MockSpec<AuthenticationInfoCacheClient>(),
])
// Hive login box: one item, counts inserts and clears; clearFailures makes the next clears throw.
class FakeHiveLoginBox {
  final mock = MockAuthenticationInfoCacheClient();
  AuthenticationInfoCache? item;
  int insertCalls = 0;
  int clearCalls = 0;
  int clearFailures = 0;

  FakeHiveLoginBox() {
    when(mock.insertItem(any, any, isolated: anyNamed('isolated'))).thenAnswer((invocation) async {
      insertCalls++;
      item = invocation.positionalArguments[1] as AuthenticationInfoCache;
    });
    when(mock.getItem(any, isolated: anyNamed('isolated'))).thenAnswer((_) async => item);
    when(mock.clearAllData(isolated: anyNamed('isolated'))).thenAnswer((_) async {
      clearCalls++;
      if (clearFailures > 0) {
        clearFailures--;
        throw Exception('clear failed');
      }
      item = null;
    });
  }
}

// Same noSuchMethod approach as FakeSecureStorage: SessionStorageManager exposes dart:html types.
class FakeSessionStorage implements SessionStorageManager {
  final Map<String, String> values = {};

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final args = invocation.positionalArguments;
    switch (invocation.memberName) {
      case #save:
        values[args[0] as String] = args[1] as String;
        return null;
      case #get:
        return values[args[0] as String] ?? (throw const NotFoundDataWithThisKeyException());
      case #remove:
        values.remove(args[0] as String);
        return null;
    }
    return super.noSuchMethod(invocation);
  }
}

// Map-backed secure storage; dropped writes model fss 8 iOS OSStatus results that look like success.
// Handles write/read/delete in one noSuchMethod: mocking FlutterSecureStorage pulls dart:html into the VM test.
class FakeSecureStorage implements FlutterSecureStorage {
  final Map<String, String> values = {};
  bool isUnavailable = false;
  bool dropAllWrites = false;
  int writesToDrop = 0;
  bool throwOnWrite = false;
  bool throwOnDelete = false;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (isUnavailable) throw UnimplementedError();
    final key = invocation.namedArguments[#key] as String;
    switch (invocation.memberName) {
      case #write:
        _write(invocation);
        return Future<void>.value();
      case #read:
        return Future<String?>.value(values[key]);
      case #delete:
        if (throwOnDelete) throw Exception('delete failed');
        values.remove(key);
        return Future<void>.value();
    }
    return super.noSuchMethod(invocation);
  }

  void _write(Invocation invocation) {
    if (throwOnWrite) throw Exception('keystore unavailable');
    if (dropAllWrites) return;
    if (writesToDrop > 0) {
      writesToDrop--;
      return;
    }
    final key = invocation.namedArguments[#key] as String;
    final value = invocation.namedArguments[#value] as String?;
    if (value == null) {
      values.remove(key);
    } else {
      values[key] = value;
    }
  }
}
