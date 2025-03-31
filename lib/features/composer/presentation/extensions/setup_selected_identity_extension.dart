
import 'package:collection/collection.dart';
import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:model/email/email_action_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';

extension SetupSelectedIdentityExtension on ComposerController {

  Future<void> setupSelectedIdentity() async {
    if (identitySelected.value != null) {
      if (PlatformInfo.isMobile && currentEmailActionType == EmailActionType.editDraft) {
        await selectIdentity(identitySelected.value);
        onCompleteSetupComposer();
      }
      return;
    }

    if (listFromIdentities.isEmpty &&
        currentEmailActionType == EmailActionType.editSendingEmail) {
      final signatureContent = await htmlEditorApi?.getSignatureContent();
      if (signatureContent?.trim().isNotEmpty == true) {
        await applySignature(signatureContent!);
      }
    }

    if (listFromIdentities.isNotEmpty) {
      final currentIdentity = _findIdentityById(
        composerArguments.value?.selectedIdentityId,
      ) ?? listFromIdentities.first;

      if (currentEmailActionType == EmailActionType.editDraft ||
          currentEmailActionType == EmailActionType.reopenComposerBrowser &&
              savedActionType == EmailActionType.editDraft) {
        identitySelected.value = currentIdentity;
      } else if (currentEmailActionType == EmailActionType.editAsNewEmail) {
        identitySelected.value = currentIdentity;
        await selectIdentity(currentIdentity);
      } else {
        await selectIdentity(currentIdentity);
      }
    }

    onCompleteSetupComposer();
  }

  Future<void> setupSelectedIdentityWithoutApplySignature() async {
    if (identitySelected.value == null && listFromIdentities.isNotEmpty) {
      final currentIdentity = _findIdentityById(
        composerArguments.value?.selectedIdentityId,
      ) ?? listFromIdentities.first;

      identitySelected.value = currentIdentity;
    }

    onCompleteSetupComposer();
  }

  void setupSelectedIdentityForEditDraft(IdentityId? identityId) {
    if (identityId == null) return;

    if (listFromIdentities.isNotEmpty) {
      final currentIdentity = _findIdentityById(identityId);
      identitySelected.value = currentIdentity;
    }
  }

  Identity? _findIdentityById(IdentityId? identityId) {
    return listFromIdentities
        .firstWhereOrNull((identity) => identity.id == identityId);
  }
}