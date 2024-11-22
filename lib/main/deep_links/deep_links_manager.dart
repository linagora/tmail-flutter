import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:core/utils/app_logger.dart';
import 'package:rxdart/subjects.dart';
import 'package:tmail_ui_user/features/base/mixin/message_dialog_action_mixin.dart';
import 'package:tmail_ui_user/main/deep_links/deep_link_action_type.dart';
import 'package:tmail_ui_user/main/deep_links/deep_link_callback_action_define.dart';
import 'package:tmail_ui_user/main/deep_links/deep_link_data.dart';
import 'package:tmail_ui_user/main/deep_links/open_app_deep_link_handler_mixin.dart';

class DeepLinksManager with MessageDialogActionMixin, OpenAppDeepLinkHandlerMixin {

  BehaviorSubject<DeepLinkData?> _pendingDeepLinkData = BehaviorSubject.seeded(null);

  BehaviorSubject<DeepLinkData?> get pendingDeepLinkData => _pendingDeepLinkData;

  StreamSubscription<Uri>? _deepLinkStreamSubscription;

  Future<DeepLinkData?> getDeepLinkData() async {
    final uriLink = await AppLinks().getInitialLink();
    log('DeepLinksManager::getDeepLinkData:uriLink = $uriLink');
    if (uriLink == null) return null;

    final deepLinkData = parseDeepLink(uriLink.toString());
    return deepLinkData;
  }

  void registerDeepLinkStreamListener() {
    _deepLinkStreamSubscription =
        AppLinks().uriLinkStream.listen(_handleUriLinkStream);
  }

  void _handleUriLinkStream(Uri uri) {
    final deepLinkData = parseDeepLink(uri.toString());
    log('DeepLinksManager::_handleUriLinkStream:DeepLinkData = $deepLinkData');
    setPendingDeepLinkData(deepLinkData);
  }

  void setPendingDeepLinkData(DeepLinkData? deepLinkData) {
    clearPendingDeepLinkData();
    _pendingDeepLinkData.add(deepLinkData);
  }

  void clearPendingDeepLinkData() {
    if(_pendingDeepLinkData.isClosed) {
      _pendingDeepLinkData = BehaviorSubject.seeded(null);
    } else {
      _pendingDeepLinkData.add(null);
    }
  }

  DeepLinkData? parseDeepLink(String url) {
    try {
      final decodedUrl = Uri.decodeFull(url);
      final uri = Uri.parse(decodedUrl);
      log('DeepLinksManager::parseDeepLink:uri = $uri');
      final action = uri.host;

      if (action == DeepLinkActionType.openApp.name.toLowerCase()) {
        return parseOpenAppDeepLink(uri);
      } else {
        return DeepLinkData(actionType: DeepLinkActionType.unknown);
      }
    } catch (e) {
      logError('DeepLinksManager::parseDeepLink:Exception = $e');
      return null;
    }
  }

  Future<void> handleDeepLinksWhenAppTerminated({
    required OnDeepLinkSuccessCallback onSuccessCallback,
    required OnDeepLinkFailureCallback onFailureCallback,
  }) async {
    final deepLinkData = await getDeepLinkData();

    if (deepLinkData == null) {
      onFailureCallback();
      return;
    }

    onSuccessCallback(deepLinkData);
  }

  Future<void> handleDeepLinksWhenAppRunning({
    required DeepLinkData? deepLinkData,
    required OnDeepLinkSuccessCallback onSuccessCallback,
    OnDeepLinkFailureCallback? onFailureCallback,
  }) async {
    if (deepLinkData == null) {
      onFailureCallback?.call();
      return;
    }

    onSuccessCallback(deepLinkData);
  }

  void dispose() {
    _deepLinkStreamSubscription?.cancel();
    _pendingDeepLinkData.close();
  }
}