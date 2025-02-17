import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/application_manager.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide State;
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/account/account.dart';
import 'package:jmap_dart_client/jmap/core/capability/default_capability.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/namespace.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/model.dart';
import 'package:rule_filter/rule_filter/capability_rule_filter.dart';
import 'package:rule_filter/rule_filter/rule_action.dart';
import 'package:rule_filter/rule_filter/rule_append_in.dart';
import 'package:rule_filter/rule_filter/rule_condition.dart';
import 'package:rule_filter/rule_filter/rule_condition_group.dart';
import 'package:rule_filter/rule_filter/tmail_rule.dart';
import 'package:tmail_ui_user/features/base/state/base_ui_state.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/get_all_mailboxes_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/get_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree_builder.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/usecases/verify_name_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_rules_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/creator_action_type.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/rule_filter_action_arguments.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/rules_filter_creator_arguments.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/rules_filter_creator_controller.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/rules_filter_creator_view.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rule_filter_action_widget.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';
import 'package:tmail_ui_user/main/utils/twake_app_manager.dart';
import 'package:uuid/uuid.dart';

import '../../../fixtures/widget_fixtures.dart';
import 'rule_filter_creator_controller_test.mocks.dart';

@GenerateNiceMocks([
  // Base controller mock specs
  MockSpec<CachingManager>(),
  MockSpec<LanguageCacheManager>(),
  MockSpec<AuthorizationInterceptors>(),
  MockSpec<DynamicUrlInterceptors>(),
  MockSpec<DeleteCredentialInteractor>(),
  MockSpec<LogoutOidcInteractor>(),
  MockSpec<DeleteAuthorityOidcInteractor>(),
  MockSpec<AppToast>(),
  MockSpec<ResponsiveUtils>(),
  MockSpec<Uuid>(),
  MockSpec<ApplicationManager>(),
  MockSpec<ToastManager>(),
  MockSpec<TwakeAppManager>(),
  // Rule filter creator controller mock specs
  MockSpec<TreeBuilder>(),
  MockSpec<VerifyNameInteractor>(),
  MockSpec<GetAllMailboxInteractor>(),
  MockSpec<GetAllRulesInteractor>(),
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RulesFilterCreatorController rulesFilterCreatorController;
  late MockTreeBuilder mockTreeBuilder;
  late MockVerifyNameInteractor mockVerifyNameInteractor;
  late MockGetAllMailboxInteractor mockGetAllMailboxInteractor;
  late MockGetAllRulesInteractor mockGetAllRulesInteractor;

  late MockCachingManager mockCachingManager;
  late MockLanguageCacheManager mockLanguageCacheManager;
  late MockAuthorizationInterceptors mockAuthorizationInterceptors;
  late MockDynamicUrlInterceptors mockDynamicUrlInterceptors;
  late MockDeleteCredentialInteractor mockDeleteCredentialInteractor;
  late MockLogoutOidcInteractor mockLogoutOidcInteractor;
  late MockDeleteAuthorityOidcInteractor mockDeleteAuthorityOidcInteractor;
  late MockAppToast mockAppToast;
  late ImagePaths imagePaths;
  late MockResponsiveUtils mockResponsiveUtils;
  late MockUuid mockUuid;
  late MockApplicationManager mockApplicationManager;
  late MockToastManager mockToastManager;
  late MockTwakeAppManager mockTwakeAppManager;

  setUpAll(() {
    Get.testMode = true;

    // Mock base controller
    mockCachingManager = MockCachingManager();
    mockLanguageCacheManager = MockLanguageCacheManager();
    mockAuthorizationInterceptors = MockAuthorizationInterceptors();
    mockDynamicUrlInterceptors = MockDynamicUrlInterceptors();
    mockDeleteCredentialInteractor = MockDeleteCredentialInteractor();
    mockLogoutOidcInteractor = MockLogoutOidcInteractor();
    mockDeleteAuthorityOidcInteractor = MockDeleteAuthorityOidcInteractor();
    mockAppToast = MockAppToast();
    imagePaths = ImagePaths();
    mockResponsiveUtils = MockResponsiveUtils();
    mockUuid = MockUuid();
    mockApplicationManager = MockApplicationManager();
    mockToastManager = MockToastManager();
    mockTwakeAppManager = MockTwakeAppManager();

    Get.put<CachingManager>(mockCachingManager);
    Get.put<LanguageCacheManager>(mockLanguageCacheManager);
    Get.put<AuthorizationInterceptors>(mockAuthorizationInterceptors);
    Get.put<AuthorizationInterceptors>(
      mockAuthorizationInterceptors,
      tag: BindingTag.isolateTag,
    );
    Get.put<DynamicUrlInterceptors>(mockDynamicUrlInterceptors);
    Get.put<DeleteCredentialInteractor>(mockDeleteCredentialInteractor);
    Get.put<LogoutOidcInteractor>(mockLogoutOidcInteractor);
    Get.put<DeleteAuthorityOidcInteractor>(mockDeleteAuthorityOidcInteractor);
    Get.put<AppToast>(mockAppToast);
    Get.put<ImagePaths>(imagePaths);
    Get.put<ResponsiveUtils>(mockResponsiveUtils);
    Get.put<Uuid>(mockUuid);
    Get.put<ApplicationManager>(mockApplicationManager);
    Get.put<ToastManager>(mockToastManager);
    Get.put<TwakeAppManager>(mockTwakeAppManager);

    // Mock rule filter creator controller
    mockTreeBuilder = MockTreeBuilder();
    mockVerifyNameInteractor = MockVerifyNameInteractor();
    mockGetAllMailboxInteractor = MockGetAllMailboxInteractor();
    mockGetAllRulesInteractor = MockGetAllRulesInteractor();

    Get.put<TreeBuilder>(mockTreeBuilder);
    Get.put<VerifyNameInteractor>(mockVerifyNameInteractor);
    Get.put<GetAllMailboxInteractor>(mockGetAllMailboxInteractor);
    Get.put<GetAllRulesInteractor>(mockGetAllRulesInteractor);

    rulesFilterCreatorController = RulesFilterCreatorController(
      mockGetAllMailboxInteractor,
      mockTreeBuilder,
      mockVerifyNameInteractor);

    Get.put<RulesFilterCreatorController>(rulesFilterCreatorController);
  });

  group("RuleFilterCreatorController::test", () {
    final accountId = AccountId(Id('value'));
    final account = Account(
      AccountName('value'),
      true,
      true,
      {capabilityRuleFilter: DefaultCapability({})});
    final session = Session(
      {},
      {accountId: account},
      {}, UserName('value'), Uri(), Uri(), Uri(), Uri(), State('value'));

    testWidgets(
      'The `Mark As Spam` action SHOULD be displayed\n'
      'WHEN editing a filter rule with a spam mailbox id',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      final dpi = tester.view.devicePixelRatio;
      tester.view.physicalSize = Size(dpi * 1920 * 2, dpi * 1080 * 2);

      final spamMailbox = PresentationMailbox(
        MailboxId(Id('SpamId')),
        name: MailboxName('Spam'),
        role: PresentationMailbox.roleJunk,
        isSubscribed: IsSubscribed(true),
        namespace: Namespace('Personal'));

      final tmailRule = TMailRule(
        name: 'Spam Rule',
        conditionGroup: RuleConditionGroup(
          conditionCombiner: ConditionCombiner.AND,
          conditions: [
            RuleCondition(
              field: Field.from,
              comparator: Comparator.exactlyEquals,
              value: 'user@linagora.com')
          ]
        ),
        action: RuleAction(appendIn: RuleAppendIn(mailboxIds: [spamMailbox.id])));

      final widget = WidgetFixtures.makeTestableWidget(child: RuleFilterCreatorView());
      await tester.pumpWidget(widget);

      rulesFilterCreatorController.arguments = RulesFilterCreatorArguments(
        accountId,
        session,
        actionType: CreatorActionType.edit,
        tMailRule: tmailRule);

      when(mockGetAllMailboxInteractor.execute(session, accountId)).thenAnswer((_) {
        return Stream.fromIterable([
          Right(GetAllMailboxLoading()),
          Right(GetAllMailboxSuccess(
            mailboxList: [spamMailbox],
            currentMailboxState: null)),
        ]);
      });

      when(mockTreeBuilder.generateMailboxTreeInUI(
        allMailboxes: [spamMailbox],
        currentDefaultTree: MailboxTree(MailboxNode.root()),
        currentPersonalTree: MailboxTree(MailboxNode.root()),
        currentTeamMailboxTree: MailboxTree(MailboxNode.root()),
      )).thenAnswer((_) async {
        return (
          allMailboxes: [spamMailbox],
          defaultTree: MailboxTree(MailboxNode(spamMailbox)),
          personalTree: MailboxTree(MailboxNode.root()),
          teamMailboxTree: MailboxTree(MailboxNode.root()),
        );
      });

      rulesFilterCreatorController.onReady();

      await tester.pumpAndSettle();

      expect(rulesFilterCreatorController.listEmailRuleFilterActionSelected.length, 1);
      expect(
        rulesFilterCreatorController.listEmailRuleFilterActionSelected,
        containsAllInOrder([MarkAsSpamActionArguments()]));

      expect(find.byType(RuleFilterActionWidget), findsNWidgets(1));
      expect(find.text('Mark as spam'), findsOneWidget);

      rulesFilterCreatorController.dispatchState(Right(UIClosedState()));
      rulesFilterCreatorController.listEmailRuleFilterActionSelected.clear();
      rulesFilterCreatorController.allMailboxes.clear();
      rulesFilterCreatorController.personalMailboxTree.value = MailboxTree(MailboxNode.root());
      rulesFilterCreatorController.defaultMailboxTree.value = MailboxTree(MailboxNode.root());
      rulesFilterCreatorController.teamMailboxesTree.value = MailboxTree(MailboxNode.root());
      debugDefaultTargetPlatformOverride = null;
      tester.view.reset();
    });

    testWidgets(
      'The `Mark As Spam` action SHOULD not be displayed\n'
      'WHEN editing a filter rule with a non-spam mailbox id',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      final dpi = tester.view.devicePixelRatio;
      tester.view.physicalSize = Size(dpi * 1920 * 2, dpi * 1080 * 2);

      final mailboxA = PresentationMailbox(
        MailboxId(Id('MailboxA')),
        name: MailboxName('MailboxA'),
        isSubscribed: IsSubscribed(true),
        namespace: Namespace('Personal'));

      final tmailRule = TMailRule(
        name: 'Move to MailboxA Rule',
        conditionGroup: RuleConditionGroup(
          conditionCombiner: ConditionCombiner.AND,
          conditions: [
            RuleCondition(
              field: Field.from,
              comparator: Comparator.exactlyEquals,
              value: 'user@linagora.com')
          ]
        ),
        action: RuleAction(appendIn: RuleAppendIn(mailboxIds: [mailboxA.id])));

      final widget = WidgetFixtures.makeTestableWidget(child: RuleFilterCreatorView());
      await tester.pumpWidget(widget);

      rulesFilterCreatorController.arguments = RulesFilterCreatorArguments(
        accountId,
        session,
        actionType: CreatorActionType.edit,
        tMailRule: tmailRule);

      when(mockGetAllMailboxInteractor.execute(session, accountId)).thenAnswer((_) {
        return Stream.fromIterable([
          Right(GetAllMailboxLoading()),
          Right(GetAllMailboxSuccess(
            mailboxList: [mailboxA],
            currentMailboxState: null)),
        ]);
      });

      when(mockTreeBuilder.generateMailboxTreeInUI(
        allMailboxes: [mailboxA],
        currentDefaultTree: MailboxTree(MailboxNode.root()),
        currentPersonalTree: MailboxTree(MailboxNode.root()),
        currentTeamMailboxTree: MailboxTree(MailboxNode.root()),
      )).thenAnswer((_) async {
        return (
          allMailboxes: [mailboxA],
          defaultTree: MailboxTree(MailboxNode.root()),
          personalTree: MailboxTree(MailboxNode(mailboxA)),
          teamMailboxTree: MailboxTree(MailboxNode.root()),
        );
      });

      rulesFilterCreatorController.onReady();

      await tester.pumpAndSettle();

      expect(rulesFilterCreatorController.listEmailRuleFilterActionSelected.length, 1);
      expect(
        rulesFilterCreatorController.listEmailRuleFilterActionSelected,
        containsAllInOrder([MoveMessageActionArguments(mailbox: mailboxA)]));

      expect(find.byType(RuleFilterActionWidget), findsNWidgets(1));
      expect(find.text('Move message'), findsOneWidget);
      expect(find.text('MailboxA'), findsOneWidget);
      expect(find.text('Mark as spam'), findsNothing);

      rulesFilterCreatorController.dispatchState(Right(UIClosedState()));
      rulesFilterCreatorController.listEmailRuleFilterActionSelected.clear();
      rulesFilterCreatorController.allMailboxes.clear();
      rulesFilterCreatorController.personalMailboxTree.value = MailboxTree(MailboxNode.root());
      rulesFilterCreatorController.defaultMailboxTree.value = MailboxTree(MailboxNode.root());
      rulesFilterCreatorController.teamMailboxesTree.value = MailboxTree(MailboxNode.root());
      debugDefaultTargetPlatformOverride = null;
      tester.view.reset();
    });
  });
}