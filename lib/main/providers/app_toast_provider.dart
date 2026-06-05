import 'package:core/presentation/utils/app_toast.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_toast_provider.g.dart';

@Riverpod(keepAlive: true)
AppToast appToast(Ref ref) => AppToast();
