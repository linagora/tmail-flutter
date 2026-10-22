import 'dart:io';

import '../abstract/composer_os_key_injector.dart';

class AndroidHostAdbKeyInjector implements ComposerOsKeyInjector {
  static const _host = '10.0.2.2:18764';

  @override
  Future<void> typeText(String text) => _inject(text);

  @override
  Future<void> pressKey(String key) => _inject('key:${_androidKeyCode(key)}');

  Future<void> _inject(String token) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(
        Uri.http(_host, '/inject', {'token': token}),
      );
      final response = await request.close();
      await response.drain<void>();
    } finally {
      client.close(force: true);
    }
  }

  static int _androidKeyCode(String key) {
    if (key == 'Space') return 62;
    if (key.length == 1) {
      final lower = key.toLowerCase();
      if (lower.compareTo('a') >= 0 && lower.compareTo('z') <= 0) {
        return 29 + (lower.codeUnitAt(0) - 97);
      }
    }
    throw UnsupportedError('Unsupported OS key "$key"');
  }
}
