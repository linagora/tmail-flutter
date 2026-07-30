import '../../domain/entity/workplace_action_config.dart';
import '../../domain/entity/workplace_intent.dart';
import '../../domain/entity/workplace_theme.dart';

abstract class WorkplaceDataSource {
  Future<WorkplaceIntent> createIntent({
    required Uri platformUrl,
    required String accessToken,
    required WorkplaceActionConfig addAsLink,
    WorkplaceActionConfig? addAsAttachment,
    required WorkplaceTheme theme,
  });
  Future<String> exchangeToken(Uri platformUrl, String oidcIdToken);
}
