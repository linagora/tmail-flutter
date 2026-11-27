import 'package:get/get.dart';
import 'package:tmail_ui_user/features/caching/utils/session_storage_manager.dart';
import 'package:tmail_ui_user/features/delegation/presentation/utils/sign_in_email_link.dart';

bool isSignInEmailLinkKept() =>
    Get.find<SessionStorageManager>().sessionStorage.containsKey(SignInEmailLink.storageKey);
