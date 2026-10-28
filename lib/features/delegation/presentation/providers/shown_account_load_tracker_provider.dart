import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/features/delegation/presentation/utils/shown_account_load_tracker.dart';

part 'shown_account_load_tracker_provider.g.dart';

/// Kept alive because the GetX readers report to it through the bridge without listening.
@Riverpod(keepAlive: true)
ShownAccountLoadTracker shownAccountLoadTracker(Ref ref) => ShownAccountLoadTracker();
