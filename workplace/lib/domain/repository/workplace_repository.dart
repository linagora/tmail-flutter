import '../entity/workplace_action_config.dart';
import '../entity/workplace_intent.dart';
import '../entity/workplace_theme.dart';

abstract class WorkplaceRepository {
  Future<WorkplaceIntent> createIntent({
    required Uri platformUrl,
    required String accessToken,
    required WorkplaceActionConfig addAsLink,
    WorkplaceActionConfig? addAsAttachment,
    required WorkplaceTheme theme,
  });
  Future<String> exchangeToken(Uri platformUrl, String oidcIdToken);
}
