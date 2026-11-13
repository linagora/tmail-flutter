import 'package:flutter/foundation.dart';

/// Sync mirror of "dashboard shortcuts must not run" for GetX key handlers.
///
/// [ShownAccountInputBlocker] updates this when the switch blocks input or the
/// loading dialog is still up, so handlers can reject key-downs before
/// [ExcludeFocus] rebuilds without new `appProviderContainer` reads (ADR-0092).
final ValueNotifier<bool> shownAccountShortcutBlocked = ValueNotifier<bool>(false);
