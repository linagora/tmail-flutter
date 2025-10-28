import 'dart:async';

import 'package:core/utils/app_logger.dart';
import 'package:core/utils/build_utils.dart';
import 'package:super_dns_client/super_dns_client.dart';
import 'package:tmail_ui_user/features/login/data/network/dns_lookup/dns_lookup_priority.dart';

/// Handles DNS SRV lookups for JMAP service discovery.
///
/// The manager attempts lookups in order of priority:
/// **System → Public UDP → Public DoH → Cloud (Google/Cloudflare)**.
class DnsLookupManager {
  static const String _jmapServicePrefix = '_jmap._tcp';
  static const Duration _defaultTimeout = Duration(seconds: 3);

  /// Builds the JMAP SRV hostname from [emailAddress].
  ///
  /// Example:
  /// ```
  /// input : user@example.com
  /// output: _jmap._tcp.example.com
  /// ```
  String buildJmapHostName(String emailAddress) {
    final parts = emailAddress.split('@');
    if (parts.length != 2 || parts[1].isEmpty) {
      throw ArgumentError('Invalid email address: $emailAddress');
    }
    return '$_jmapServicePrefix.${parts[1]}';
  }

  /// Creates the appropriate [DnsClient] for the given [priority].
  DnsClient createClient(DnsLookupPriority priority) {
    const debug = BuildUtils.isDebugMode;
    switch (priority) {
      case DnsLookupPriority.system:
        return SystemUdpSrvClient(debugMode: debug);
      case DnsLookupPriority.publicUdp:
        return PublicUdpSrvClient(debugMode: debug);
      case DnsLookupPriority.publicDoh:
        return DnsOverHttpsBinaryClient(debugMode: debug);
      case DnsLookupPriority.cloud:
        return DnsOverHttps.google(debugMode: debug);
    }
  }

  /// Attempts SRV resolution for the JMAP hostname derived from [emailAddress].
  ///
  /// Each lookup attempt will timeout after [_defaultTimeout] seconds.
  /// Returns the first successfully resolved hostname, or an empty string if all fail.
  Future<String> lookupJmapUrl(String emailAddress) async {
    final jmapHostName = buildJmapHostName(emailAddress);
    log('$runtimeType::lookupJmapUrl → Resolving SRV for: $jmapHostName');

    final priorities = List.of(DnsLookupPriority.values)
      ..sort((a, b) => a.priority.compareTo(b.priority));

    for (final priority in priorities) {
      final client = createClient(priority);
      log('$runtimeType::lookupJmapUrl → 🔍 Trying ${priority.label} (timeout: ${_defaultTimeout.inSeconds}s)...');

      try {
        final records = client is DnsOverHttps
            ? await client.lookupSrvParallel(jmapHostName).timeout(
                _defaultTimeout,
                onTimeout: () {
                  throw TimeoutException(
                      'Lookup timed out after ${_defaultTimeout.inSeconds}s');
                },
              )
            : await client.lookupSrv(jmapHostName).timeout(
                _defaultTimeout,
                onTimeout: () {
                  throw TimeoutException(
                      'Lookup timed out after ${_defaultTimeout.inSeconds}s');
                },
              );

        if (records.isNotEmpty) {
          final target = records.first.target;
          log('$runtimeType::lookupJmapUrl → ✅ Success via ${priority.label}: $target');
          return target;
        }

        log('$runtimeType::lookupJmapUrl → ⚠️ No records via ${priority.label}, continuing...');
      } on TimeoutException catch (_) {
        logError(
            '$runtimeType::lookupJmapUrl → ⏱️ ${priority.label} lookup timed out');
      } catch (error, stack) {
        logError(
            '$runtimeType::lookupJmapUrl → ❌ ${priority.label} lookup failed: $error, $stack');
      }
    }

    log('$runtimeType::lookupJmapUrl → 🚨 All DNS lookups failed for $jmapHostName');
    return '';
  }
}
