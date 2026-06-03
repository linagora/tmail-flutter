import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/main/exceptions/thrower/cache_exception_thrower.dart';

part 'cache_exception_thrower_provider.g.dart';

@Riverpod(keepAlive: true)
CacheExceptionThrower cacheExceptionThrower(Ref ref) => CacheExceptionThrower();
