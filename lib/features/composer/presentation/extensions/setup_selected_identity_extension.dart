
import 'package:collection/collection.dart';
import 'package:core/utils/app_logger.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:model/email/email_action_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';

extension SetupSelectedIdentityExtension on ComposerController {

  Future<void> setupSelectedIdentity() async {
    if (identitySelected.value != null) return;

    if (listFromIdentities.isEmpty &&
        currentEmailActionType == EmailActionType.editSendingEmail) {
      final signatureContent = await htmlEditorApi?.getSignatureContent();
      if (signatureContent?.trim().isNotEmpty == true) {
        await applySignature(signatureContent!);
      }
    }

    if (listFromIdentities.isNotEmpty) {
      final currentIdentity = _findIdentityById(composerArguments.value?.selectedIdentityId)
          ?? listFromIdentities.first;
      log('SetupSelectedIdentityExtension::setupSelectedIdentity:currentIdentity = ${currentIdentity.props}');
      if (currentEmailActionType == EmailActionType.editDraft) {
        identitySelected.value = currentIdentity;
      } else {
        await selectIdentity(currentIdentity);
      }
    }

    onCompleteSetupComposer();
  }

  Future<void> setupSelectedIdentityWithoutApplySignature() async {
    if (identitySelected.value == null && listFromIdentities.isNotEmpty) {
      final currentIdentity = _findIdentityById(composerArguments.value?.selectedIdentityId)
          ?? listFromIdentities.first;
      log('SetupSelectedIdentityExtension::setupSelectedIdentityWithoutApplySignature:currentIdentity = ${currentIdentity.props}');
      identitySelected.value = currentIdentity;
    }

    onCompleteSetupComposer();
  }

  Identity? _findIdentityById(IdentityId? identityId) {
    return listFromIdentities
        .firstWhereOrNull((identity) => identity.id == identityId);
  }
}