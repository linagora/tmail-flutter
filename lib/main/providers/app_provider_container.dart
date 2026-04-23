import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Singleton [ProviderContainer] shared between the [ProviderScope] and
/// non-widget code (e.g. GetX controllers / services).
final appProviderContainer = ProviderContainer();
