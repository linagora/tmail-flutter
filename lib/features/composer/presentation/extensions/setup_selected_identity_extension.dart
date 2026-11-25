
import 'package:collection/collection.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:model/email/email_action_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';

extension SetupSelectedIdentityExtension on ComposerController {

  Future<void> setupSelectedIdentity() async {
    if (identitySelected.value != null) {
      // The identity comes from the email header, so nothing below runs. These
      // actions still need their baseline draft hash taken here.
      if (currentEmailActionType == EmailActionType.editAsNewEmail ||
          currentEmailActionType == EmailActionType.editDraft) {
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

    final currentIdentity = _identityToSelect();
    if (currentIdentity != null) {
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
    if (identitySelected.value == null) {
      identitySelected.value = _identityToSelect();
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

  Identity? _identityToSelect() =>
      _findIdentityById(composerArguments.value?.selectedIdentityId) ?? _fallbackIdentity;

  /// The shown mailbox's identities never stand in for the one a draft of another account names.
  Identity? get _fallbackIdentity =>
      isComposingOutsideShownAccount && fromIdentitiesAccountId != composerAccountId
          ? null
          : listFromIdentities.firstOrNull;

  Identity? _findIdentityById(IdentityId? identityId) {
    return listFromIdentities
        .firstWhereOrNull((identity) => identity.id == identityId);
  }
}