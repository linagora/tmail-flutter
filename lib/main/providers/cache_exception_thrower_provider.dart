import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tmail_ui_user/main/exceptions/thrower/cache_exception_thrower.dart';

final cacheExceptionThrowerProvider = Provider<CacheExceptionThrower>(
  (_) => CacheExceptionThrower(),
);
