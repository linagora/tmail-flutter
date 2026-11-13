import 'package:jmap_dart_client/jmap/core/session/session.dart';

/// Session handed to the dashboard when a screen finishes its session read.
///
/// [fromCache] is set when that read failed and the stored session was used.
/// Cleanup of ended delegations waits for an online read (ADR-0114).
class DashboardSessionArguments {
  final Session session;
  final bool fromCache;

  const DashboardSessionArguments({
    required this.session,
    required this.fromCache,
  });
}
