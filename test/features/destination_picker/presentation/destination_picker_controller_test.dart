import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:mockito/mockito.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/destination_picker_controller.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/get_all_mailboxes_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/refresh_changes_all_mailboxes_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/create_new_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/get_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/refresh_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/search_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree_builder.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/usecases/verify_name_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';
import 'package:tmail_ui_user/main/utils/twake_app_manager.dart';
import 'package:uuid/uuid.dart';

import '../../base/base_controller_test.mocks.dart';

class _MockSearchMailboxInteractor extends Mock implements SearchMailboxInteractor {}

class _MockCreateNewMailboxInteractor extends Mock implements CreateNewMailboxInteractor {}

class _MockGetAllMailboxInteractor extends Mock implements GetAllMailboxInteractor {}

class _MockRefreshAllMailboxInteractor extends Mock implements RefreshAllMailboxInteractor {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DestinationPickerController controller;

  final inbox = PresentationMailbox(
    MailboxId(Id('inbox')),
    name: MailboxName('Inbox'),
    role: PresentationMailbox.roleInbox,
  );
  final outbox = PresentationMailbox(
    MailboxId(Id('outbox')),
    name: MailboxName('Outbox'),
    role: PresentationMailbox.roleOutbox,
  );
  final templates = PresentationMailbox(
    MailboxId(Id('templates')),
    name: MailboxName('Templates'),
    role: PresentationMailbox.roleTemplates,
  );
  final templatesChild = PresentationMailbox(
    MailboxId(Id('invoices')),
    name: MailboxName('Invoices'),
    parentId: templates.id,
    isSubscribed: IsSubscribed(true),
  );
  final customFolder = PresentationMailbox(
    MailboxId(Id('custom')),
    name: MailboxName('Custom'),
    isSubscribed: IsSubscribed(true),
  );
  final mailboxes = [inbox, outbox, templates, templatesChild, customFolder];

  setUp(() {
    Get.put<CachingManager>(MockCachingManager());
    Get.put<LanguageCacheManager>(MockLanguageCacheManager());
    Get.put<AuthorizationInterceptors>(MockAuthorizationInterceptors());
    Get.put<AuthorizationInterceptors>(
      MockAuthorizationInterceptors(),
      tag: BindingTag.isolateTag,
    );
    Get.put<DynamicUrlInterceptors>(MockDynamicUrlInterceptors());
    Get.put<DeleteCredentialInteractor>(MockDeleteCredentialInteractor());
    Get.put<LogoutOidcInteractor>(MockLogoutOidcInteractor());
    Get.put<DeleteAuthorityOidcInteractor>(MockDeleteAuthorityOidcInteractor());
    Get.put<AppToast>(MockAppToast());
    Get.put<ImagePaths>(MockImagePaths());
    Get.put<ResponsiveUtils>(MockResponsiveUtils());
    Get.put<Uuid>(MockUuid());
    Get.put<ToastManager>(MockToastManager());
    Get.put<TwakeAppManager>(MockTwakeAppManager());

    controller = DestinationPickerController(
      _MockSearchMailboxInteractor(),
      _MockCreateNewMailboxInteractor(),
      TreeBuilder(),
      VerifyNameInteractor(),
      _MockGetAllMailboxInteractor(),
      _MockRefreshAllMailboxInteractor(),
    );
  });

  tearDown(Get.reset);

  Future<List<MailboxId>> pickableMailboxIds(Success success) async {
    controller.handleSuccessViewState(success);
    await pumpEventQueue();
    return controller.allMailboxes.map((mailbox) => mailbox.id).toList();
  }

  List<MailboxId> personalRootIds() =>
      (controller.personalMailboxTree.value.root.childrenItems ?? [])
          .map((node) => node.item.id)
          .toList();

  group('DestinationPickerController rule action targets', () {
    test('should drop Outbox, Templates and its subfolders when picking a rule target', () async {
      controller.mailboxAction.value = MailboxActions.selectForRuleAction;

      final ids = await pickableMailboxIds(
        GetAllMailboxSuccess(mailboxList: mailboxes, currentMailboxState: null),
      );

      expect(ids, [inbox.id, customFolder.id]);
      expect(personalRootIds(), [customFolder.id]);
    });

    test('should drop the same folders when the mailbox list is refreshed', () async {
      controller.mailboxAction.value = MailboxActions.selectForRuleAction;

      final ids = await pickableMailboxIds(
        RefreshChangesAllMailboxSuccess(mailboxList: mailboxes, currentMailboxState: null),
      );

      expect(ids, [inbox.id, customFolder.id]);
    });

    test('should keep every folder when moving an email', () async {
      controller.mailboxAction.value = MailboxActions.move;
      controller.mailboxIdSelected = inbox.id;

      final ids = await pickableMailboxIds(
        GetAllMailboxSuccess(mailboxList: mailboxes, currentMailboxState: null),
      );

      expect(ids, mailboxes.map((mailbox) => mailbox.id).toList());
    });
  });
}
