import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/shown_account_capabilities.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';

part 'shown_account_capabilities_provider.g.dart';

@riverpod
ShownAccountCapabilities shownAccountCapabilities(Ref ref) =>
    ShownAccountCapabilities.of(ref.watch(activeAccountProvider));
