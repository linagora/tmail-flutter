import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Singleton [ProviderContainer] exposed to the widget tree via
/// [UncontrolledProviderScope] and accessed imperatively by GetX controllers.
/// Frozen: no new [appProviderContainer] call sites may be added (see ADR-0092).
final appProviderContainer = ProviderContainer();
