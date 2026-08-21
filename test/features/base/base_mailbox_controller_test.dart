import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/base/base_mailbox_controller.dart';
import 'package:tmail_ui_user/features/base/extensions/toggle_mailbox_expand_with_scroll_extension.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/move_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_categories.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_sidebar_category_tree_source_resolver.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree_builder.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mixin/mailbox_sidebar_tree_layout_mixin.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/usecases/verify_name_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';
import 'package:tmail_ui_user/main/utils/twake_app_manager.dart';
import 'package:uuid/uuid.dart';

import '../../fixtures/account_fixtures.dart';
import '../../fixtures/session_fixtures.dart';
import 'base_controller_test.mocks.dart';

class _TestMailboxController extends BaseMailboxController
    with MailboxSidebarTreeLayoutMixin {
  _TestMailboxController() : super(TreeBuilder(), VerifyNameInteractor());

  PresentationMailbox? destinationMailbox;
  MailboxActions? destinationMailboxAction;
  MailboxId? destinationMailboxId;
  @override
  Future<PresentationMailbox?> pickDestinationMailbox({
    required AccountId accountId,
    required Session session,
    required MailboxActions mailboxActions,
    required MailboxId mailboxIdSelected,
  }) async {
    destinationMailboxAction = mailboxActions;
    destinationMailboxId = mailboxIdSelected;
    return destinationMailbox;
  }
}

class _FakeMailboxDashBoardController extends Fake
    implements MailboxDashBoardController {
  _FakeMailboxDashBoardController({
    AccountId? accountId,
    this.sessionCurrent,
  }) : accountId = Rxn<AccountId>(accountId);

  @override
  final Rxn<AccountId> accountId;

  @override
  final Session? sessionCurrent;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _TestMailboxController controller;

  setUpAll(() {
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
  });

  setUp(() {
    controller = _TestMailboxController();
  });

  group('BaseMailboxController::toggleMailboxFolder', () {
    for (final scenario in [
      (
        description: 'should expand node and return EXPAND when node is collapsed',
        initialMode: ExpandMode.COLLAPSE,
        expectedMode: ExpandMode.EXPAND,
      ),
      (
        description: 'should collapse node and return COLLAPSE when node is expanded',
        initialMode: ExpandMode.EXPAND,
        expectedMode: ExpandMode.COLLAPSE,
      ),
    ]) {
      test(scenario.description, () {
        final node = _buildNodeWithChild(
          MailboxId(Id('1')),
          expandMode: scenario.initialMode,
        );
        controller.defaultMailboxTree.value = _buildTreeWith(node);

        final newExpandMode = controller.toggleMailboxFolder(node);

        expect(newExpandMode, scenario.expectedMode);
        expect(node.expandMode, scenario.expectedMode);
      });
    }

    test('should toggle node belonging to the personal tree', () {
      final node = _buildNodeWithChild(MailboxId(Id('1')));
      controller.personalMailboxTree.value = _buildTreeWith(node);

      expect(controller.toggleMailboxFolder(node), ExpandMode.EXPAND);
      expect(node.expandMode, ExpandMode.EXPAND);
    });

    test('should toggle node belonging to the team mailboxes tree', () {
      final node = _buildNodeWithChild(MailboxId(Id('1')));
      controller.teamMailboxesTree.value = _buildTreeWith(node);

      expect(controller.toggleMailboxFolder(node), ExpandMode.EXPAND);
      expect(node.expandMode, ExpandMode.EXPAND);
    });

    test('should return null when node belongs to no tree', () {
      final node = _buildNodeWithChild(MailboxId(Id('1')));

      expect(controller.toggleMailboxFolder(node), isNull);
      expect(node.expandMode, ExpandMode.COLLAPSE);
    });
  });

  group('BaseMailboxController::toggleMailboxCategories', () {
    test('initializes every registered category as expanded', () {
      final categoryExpandModes = controller.mailboxCategoriesExpandMode.value;

      for (final category in MailboxCategories.values) {
        expect(category.getExpandMode(categoryExpandModes), ExpandMode.EXPAND);
      }
    });

    test('should toggle only the given category', () {
      final newExpandMode = controller.toggleMailboxCategories(
        MailboxCategories.personalFolders,
      );
      final categoriesExpandMode = controller.mailboxCategoriesExpandMode.value;

      expect(newExpandMode, ExpandMode.COLLAPSE);
      expect(
        MailboxCategories.personalFolders.getExpandMode(categoriesExpandMode),
        ExpandMode.COLLAPSE,
      );
      expect(
        MailboxCategories.exchange.getExpandMode(categoriesExpandMode),
        ExpandMode.EXPAND,
      );
      expect(
        MailboxCategories.teamMailboxes.getExpandMode(categoriesExpandMode),
        ExpandMode.EXPAND,
      );
    });

    test('should toggle the category back to its previous mode', () {
      controller.toggleMailboxCategories(MailboxCategories.teamMailboxes);

      final newExpandMode = controller.toggleMailboxCategories(
        MailboxCategories.teamMailboxes,
      );

      expect(newExpandMode, ExpandMode.EXPAND);
      expect(
        MailboxCategories.teamMailboxes.getExpandMode(
          controller.mailboxCategoriesExpandMode.value,
        ),
        ExpandMode.EXPAND,
      );
    });
  });

  group('MailboxSidebarTreeLayoutMixin', () {
    test('invalidates when expanding a mailbox or category changes the layout', () {
      final mailboxNode = _buildNodeWithChild(MailboxId(Id('mailbox')));
      controller.defaultMailboxTree.value = _buildTreeWith(mailboxNode);

      controller.toggleMailboxFolder(mailboxNode);
      controller.toggleMailboxCategories(MailboxCategories.personalFolders);

      expect(controller.mailboxSidebarTreeLayoutRevision.value, 2);
    });

    test('does not invalidate when no mailbox folder is updated', () {
      controller.toggleMailboxFolder(
        _buildNodeWithChild(MailboxId(Id('unknown'))),
      );

      expect(controller.mailboxSidebarTreeLayoutRevision.value, 0);
    });

    test('invalidates when replacing mailbox trees', () {
      controller.updateMailboxTree(
        mailboxCollection: controller.currentMailboxCollection,
      );

      expect(controller.mailboxSidebarTreeLayoutRevision.value, 1);
    });
  });

  group('MailboxSidebarCategoryTreeSourceResolver', () {
    const sourceResolver = MailboxSidebarCategoryTreeSourceResolver();

    test('registers every category with its matching roots and tree depth', () {
      final defaultNode = _buildNodeWithChild(MailboxId(Id('default')));
      final personalNode = _buildNodeWithChild(MailboxId(Id('personal')));
      final teamNode = _buildNodeWithChild(MailboxId(Id('team')));
      controller.defaultMailboxTree.value = _buildTreeWith(defaultNode);
      controller.personalMailboxTree.value = _buildTreeWith(personalNode);
      controller.teamMailboxesTree.value = _buildTreeWith(teamNode);

      final sources = sourceResolver.resolve(controller);

      expect(
        sources.map((source) => source.category),
        MailboxCategories.values,
      );
      expect(sources[0].roots, [defaultNode]);
      expect(sources[0].isFolderCategory, isFalse);
      expect(sources[0].initialDepth, 0);
      expect(sources[1].roots, [personalNode]);
      expect(sources[1].isFolderCategory, isTrue);
      expect(sources[1].initialDepth, 1);
      expect(sources[2].roots, [teamNode]);
      expect(sources[2].isFolderCategory, isTrue);
      expect(sources[2].initialDepth, 1);
    });

    test('reflects the category expansion state without mutating old state', () {
      final previousExpandModes = controller.mailboxCategoriesExpandMode.value;

      controller.toggleMailboxCategories(MailboxCategories.personalFolders);

      final sources = sourceResolver.resolve(controller);
      final personalSource = sources.firstWhere(
        (source) => source.category == MailboxCategories.personalFolders,
      );

      expect(personalSource.isExpanded, isFalse);
      expect(
        MailboxCategories.personalFolders.getExpandMode(previousExpandModes),
        ExpandMode.EXPAND,
      );
    });
  });

  group('BaseMailboxController::getListMailboxNameInParentMailbox', () {
    test('should return names at root level from every tree when parent has no parentId', () {
      controller.defaultMailboxTree.value = _buildTreeWith(
        _namedNode(MailboxId(Id('1')), MailboxName('Inbox')),
      );
      controller.personalMailboxTree.value = _buildTreeWith(
        _namedNode(MailboxId(Id('2')), MailboxName('Work')),
      );
      controller.teamMailboxesTree.value = _buildTreeWith(
        _namedNode(MailboxId(Id('3')), MailboxName('Team')),
      );

      final names = controller.getListMailboxNameInParentMailbox(
        PresentationMailbox(MailboxId(Id('99'))),
      );

      expect(names, ['Inbox', 'Work', 'Team']);
    });

    test('should skip mailboxes without a name', () {
      final root = MailboxNode.root();
      root.addChildNode(_namedNode(MailboxId(Id('1')), MailboxName('Inbox')));
      root.addChildNode(MailboxNode(PresentationMailbox(MailboxId(Id('2')))));
      controller.defaultMailboxTree.value = MailboxTree(root);

      final names = controller.getListMailboxNameInParentMailbox(
        PresentationMailbox(MailboxId(Id('99'))),
      );

      expect(names, ['Inbox']);
    });

    test('should return the children names of the parent node', () {
      final parentNode = _namedNode(MailboxId(Id('1')), MailboxName('Work'));
      parentNode.addChildNode(_namedNode(
        MailboxId(Id('11')),
        MailboxName('Reports'),
        parentId: MailboxId(Id('1')),
      ));
      parentNode.addChildNode(_namedNode(
        MailboxId(Id('12')),
        MailboxName('Invoices'),
        parentId: MailboxId(Id('1')),
      ));
      controller.personalMailboxTree.value = _buildTreeWith(parentNode);

      final names = controller.getListMailboxNameInParentMailbox(
        PresentationMailbox(MailboxId(Id('11')), parentId: MailboxId(Id('1'))),
      );

      expect(names, ['Reports', 'Invoices']);
    });

    test('should return an empty list when the parent node is not found', () {
      final names = controller.getListMailboxNameInParentMailbox(
        PresentationMailbox(
          MailboxId(Id('11')),
          parentId: MailboxId(Id('unknown')),
        ),
      );

      expect(names, isEmpty);
    });
  });

  group('ToggleMailboxExpandWithScrollExtension', () {
    test('should toggle the folder when the item is not laid out yet', () {
      final node = _buildNodeWithChild(MailboxId(Id('1')));
      controller.defaultMailboxTree.value = _buildTreeWith(node);

      controller.toggleMailboxFolderWithScroll(
        node,
        ScrollController(),
        GlobalKey(),
      );

      expect(node.expandMode, ExpandMode.EXPAND);
    });

    test('should toggle the category when the item is not laid out yet', () {
      controller.toggleMailboxCategoriesWithScroll(
        MailboxCategories.personalFolders,
        ScrollController(),
        GlobalKey(),
      );

      expect(
        MailboxCategories.personalFolders.getExpandMode(
          controller.mailboxCategoriesExpandMode.value,
        ),
        ExpandMode.COLLAPSE,
      );
    });
  });

  group('BaseMailboxController::moveMailboxAction', () {
    test('should forward a selected mailbox destination to the move callback', () async {
      final sourceMailbox = _namedMailbox(
        MailboxId(Id('source')),
        MailboxName('Source'),
      );
      final selectedDestination = _namedMailbox(
        MailboxId(Id('destination')),
        MailboxName('Destination'),
      );
      PresentationMailbox? destinationMailbox;
      controller.destinationMailbox = selectedDestination;

      await controller.moveMailboxAction(
        sourceMailbox,
        _mockDashboardController(),
        onMovingMailboxAction: (_, destination) => destinationMailbox = destination,
      );

      expect(controller.destinationMailboxAction, MailboxActions.move);
      expect(controller.destinationMailboxId, sourceMailbox.id);
      expect(destinationMailbox, selectedDestination);
    });

    test('should map the unified mailbox destination to null', () async {
      final dashboardController = _mockDashboardController();
      final sourceMailbox = _namedMailbox(
        MailboxId(Id('source')),
        MailboxName('Source'),
      );
      controller.destinationMailbox = PresentationMailbox.unifiedMailbox;
      PresentationMailbox? destinationMailbox;

      await controller.moveMailboxAction(
        sourceMailbox,
        dashboardController,
        onMovingMailboxAction: (_, destination) => destinationMailbox = destination,
      );

      expect(controller.destinationMailboxAction, MailboxActions.move);
      expect(controller.destinationMailboxId, sourceMailbox.id);
      expect(destinationMailbox, isNull);
    });

    for (final scenario in [
      (
        description: 'should not open the picker without an account',
        dashboardController: _FakeMailboxDashBoardController(),
        exceptionType: NotFoundAccountIdException,
      ),
      (
        description: 'should not open the picker without a session',
        dashboardController: _FakeMailboxDashBoardController(
          accountId: AccountFixtures.aliceAccountId,
        ),
        exceptionType: NotFoundSessionException,
      ),
    ]) {
      test(scenario.description, () async {
        var callbackCalls = 0;

        await controller.moveMailboxAction(
          _namedMailbox(MailboxId(Id('source')), MailboxName('Source')),
          scenario.dashboardController,
          onMovingMailboxAction: (_, __) => callbackCalls++,
        );

        expect(controller.destinationMailboxAction, isNull);
        expect(callbackCalls, 0);
        await Future<void>.delayed(Duration.zero);
        final failure = controller.viewState.value.fold(
          (failure) => failure,
          (_) => fail('Expected move mailbox failure'),
        );
        expect(failure, isA<MoveMailboxFailure>());
        expect(
          (failure as MoveMailboxFailure).exception.runtimeType,
          scenario.exceptionType,
        );
      });
    }
  });

  group('BaseMailboxController::moveFolderContentAction', () {
    test('should forward the destination picker result to the move callback', () async {
      final sourceMailbox = _namedMailbox(
        MailboxId(Id('source')),
        MailboxName('Source'),
      );
      final destination = _namedMailbox(
        MailboxId(Id('destination')),
        MailboxName('Destination'),
      );
      controller.destinationMailbox = destination;
      PresentationMailbox? currentMailbox;
      PresentationMailbox? destinationMailbox;

      await controller.moveFolderContentAction(
        accountId: AccountFixtures.aliceAccountId,
        session: SessionFixtures.aliceSession,
        mailboxSelected: sourceMailbox,
        onMoveFolderContentAction: (current, selectedDestination) {
          currentMailbox = current;
          destinationMailbox = selectedDestination;
        },
      );

      expect(controller.destinationMailboxAction, MailboxActions.moveFolderContent);
      expect(controller.destinationMailboxId, sourceMailbox.id);
      expect(currentMailbox, sourceMailbox);
      expect(destinationMailbox, destination);
    });

    test('should not invoke the move callback when the picker is cancelled', () async {
      var callbackCalls = 0;

      await controller.moveFolderContentAction(
        accountId: AccountFixtures.aliceAccountId,
        session: SessionFixtures.aliceSession,
        mailboxSelected: _namedMailbox(
          MailboxId(Id('source')),
          MailboxName('Source'),
        ),
        onMoveFolderContentAction: (_, __) => callbackCalls++,
      );

      expect(controller.destinationMailboxAction, MailboxActions.moveFolderContent);
      expect(callbackCalls, 0);
    });
  });
}

MailboxDashBoardController _mockDashboardController() =>
    _FakeMailboxDashBoardController(
      accountId: AccountFixtures.aliceAccountId,
      sessionCurrent: SessionFixtures.aliceSession,
    );

PresentationMailbox _namedMailbox(MailboxId id, MailboxName name) => PresentationMailbox(
  id,
  name: name,
);

MailboxNode _buildNodeWithChild(
  MailboxId id, {
  ExpandMode expandMode = ExpandMode.COLLAPSE,
}) {
  final node = MailboxNode(
    PresentationMailbox(id),
    expandMode: expandMode,
  );
  node.addChildNode(MailboxNode(
    PresentationMailbox(
      MailboxId(Id('${id.id.value}-child')),
      parentId: id,
    ),
  ));
  return node;
}

MailboxNode _namedNode(
  MailboxId id,
  MailboxName name, {
  MailboxId? parentId,
}) {
  return MailboxNode(PresentationMailbox(
    id,
    name: name,
    parentId: parentId,
  ));
}

MailboxTree _buildTreeWith(MailboxNode node) {
  final root = MailboxNode.root();
  root.addChildNode(node);
  return MailboxTree(root);
}
