import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:scribe/scribe.dart';
import 'package:scribe/scribe/ai/presentation/bindings/ai_scribe_bindings.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';

mixin AiScribeMixin {
  AICapability? getAICapability({Session? session, AccountId? accountId}) {
    if (PlatformInfo.isMobile) return null;

    if (accountId == null || session == null) {
      return null;
    }

    return session.getAICapability(accountId);
  }

  void injectAIScribeBindings(Session? session, AccountId? accountId) {
    try {
      final aiCapability = getAICapability(
        session: session,
        accountId: accountId,
      );
      if (aiCapability?.isScribeEndpointAvailable == true) {
        AIScribeBindings(aiCapability!.scribeEndpoint!).dependencies();
      }
    } catch (e) {
      logError('AiScribeMixin::injectAIScribeBindings(): $e');
    }
  }
}
