import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/namespace.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/destination_picker_controller.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/create_new_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/get_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/refresh_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/search_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree_builder.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/usecases/verify_name_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';
import 'package:tmail_ui_user/main/utils/twake_app_manager.dart';
import 'package:uuid/uuid.dart';

import '../../base/base_controller_test.mocks.dart';

class _FakeMailboxRepository extends Fake implements MailboxRepository {}

final _teamMailboxRoot = PresentationMailbox(
  MailboxId(Id('team-root')),
  namespace: Namespace('TeamMailbox[team@example.com]'),
);
final _teamMailboxInbox = PresentationMailbox(
  MailboxId(Id('team-inbox')),
  parentId: MailboxId(Id('team-root')),
  namespace: Namespace('TeamMailbox[team@example.com]'),
);
final _sharedTopLevelFolder = PresentationMailbox(
  MailboxId(Id('shared-folder')),
  namespace: Namespace('Delegated[bob@example.com]'),
);
final _personalInbox = PresentationMailbox(MailboxId(Id('inbox')));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DestinationPickerController controller;

  setUpAll(_registerBaseControllerDependencies);

  setUp(() {
    final mailboxRepository = _FakeMailboxRepository();
    controller = DestinationPickerController(
      SearchMailboxInteractor(),
      CreateNewMailboxInteractor(mailboxRepository),
      TreeBuilder(),
      VerifyNameInteractor(),
      GetAllMailboxInteractor(mailboxRepository),
      RefreshAllMailboxInteractor(mailboxRepository),
    );
    controller.allMailboxes = [
      _personalInbox,
      _teamMailboxRoot,
      _teamMailboxInbox,
      _sharedTopLevelFolder,
    ];
  });

  group('DestinationPickerController::searchableMailboxes', () {
    test(
      'should search team mailbox folders but not team mailbox roots '
      'when selecting a search scope',
    () {
      controller.mailboxAction.value = MailboxActions.select;

      expect(
        controller.searchableMailboxes,
        [_personalInbox, _teamMailboxInbox, _sharedTopLevelFolder],
      );
    });

    test('should search team mailbox roots when moving an email', () {
      controller.mailboxAction.value = MailboxActions.moveEmail;

      expect(controller.searchableMailboxes, controller.allMailboxes);
    });

    test('should search personal mailboxes only when creating a folder', () {
      controller.mailboxAction.value = MailboxActions.create;

      expect(controller.searchableMailboxes, [_personalInbox]);
    });

    test('should search personal mailboxes when no action is set', () {
      controller.mailboxAction.value = null;

      expect(controller.searchableMailboxes, [_personalInbox]);
    });
  });

  group('DestinationPickerController::toggleUnpickableMailboxNode', () {
    test(
      'should expand a team mailbox root instead of picking it '
      'when selecting a search scope',
    () {
      final node = _buildTeamMailboxRootNode();
      controller.teamMailboxesTree.value = _buildTreeWith(node);
      controller.mailboxAction.value = MailboxActions.select;

      expect(controller.toggleUnpickableMailboxNode(node), isTrue);
      expect(node.expandMode, ExpandMode.EXPAND);
    });

    test(
      'should let a team mailbox folder be picked '
      'when selecting a search scope',
    () {
      final node = MailboxNode(_teamMailboxInbox);
      controller.mailboxAction.value = MailboxActions.select;

      expect(controller.toggleUnpickableMailboxNode(node), isFalse);
      expect(node.expandMode, ExpandMode.COLLAPSE);
    });

    test('should let a team mailbox root be picked when moving an email', () {
      final node = _buildTeamMailboxRootNode();
      controller.teamMailboxesTree.value = _buildTreeWith(node);
      controller.mailboxAction.value = MailboxActions.moveEmail;

      expect(controller.toggleUnpickableMailboxNode(node), isFalse);
      expect(node.expandMode, ExpandMode.COLLAPSE);
    });
  });
}

void _registerBaseControllerDependencies() {
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
  Get.testMode = true;
}

MailboxNode _buildTeamMailboxRootNode() {
  final node = MailboxNode(_teamMailboxRoot);
  node.addChildNode(MailboxNode(_teamMailboxInbox));
  return node;
}

MailboxTree _buildTreeWith(MailboxNode node) {
  final root = MailboxNode.root();
  root.addChildNode(node);
  return MailboxTree(root);
}
