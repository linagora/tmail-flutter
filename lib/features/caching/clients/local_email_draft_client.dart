import 'package:tmail_ui_user/features/caching/config/hive_cache_client.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/local_email_draft.dart';

class LocalEmailDraftClient extends HiveCacheClient<LocalEmailDraft> {

  @override
  String get tableName => CachingConstants.localDraftEmailCacheBoxName;
}