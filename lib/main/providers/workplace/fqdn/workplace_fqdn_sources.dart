import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/main/providers/workplace/fqdn/workplace_fqdn_ecosystem_notifier.dart';
import 'package:tmail_ui_user/main/providers/workplace/fqdn/workplace_fqdn_source.dart';
import 'package:tmail_ui_user/main/providers/workplace/fqdn/workplace_fqdn_user_info_notifier.dart';

part 'workplace_fqdn_sources.g.dart';

/// Workplace FQDN sources ordered by priority — index 0 wins.
///
/// To add a source: write a notifier implementing [WorkplaceFqdnSource] and
/// insert a reader for its provider at the right index. Nothing else changes.
@Riverpod(keepAlive: true)
List<WorkplaceFqdnSourceReader> workplaceFqdnSources(Ref ref) => [
      (ref) => ref.watch(workplaceFqdnUserInfoProvider),
      (ref) => ref.watch(workplaceFqdnEcosystemProvider),
    ];
