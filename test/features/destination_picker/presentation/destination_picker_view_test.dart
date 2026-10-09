import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/namespace.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/destination_picker_controller.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/destination_picker_view.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/model/destination_picker_arguments.dart';
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
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';
import 'package:tmail_ui_user/main/utils/twake_app_manager.dart';
import 'package:uuid/uuid.dart';

import '../../base/base_controller_test.mocks.dart';

class _FakeMailboxRepository extends Fake implements MailboxRepository {}

final _teamNamespace = Namespace('TeamMailbox[team@example.com]');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DestinationPickerController controller;
  late MailboxNode teamMailboxRootNode;

  setUpAll(_registerBaseControllerDependencies);

  setUp(() {
    controller = _buildController();
    teamMailboxRootNode = _buildTeamMailboxRootNode();
    controller.teamMailboxesTree.value = _buildTreeWith(teamMailboxRootNode);
    Get.put<DestinationPickerController>(controller);
  });

  tearDown(() => Get.delete<DestinationPickerController>(force: true));

  testWidgets(
    'expands a team mailbox root instead of picking it as a search scope',
    (tester) async {
      await _pumpPicker(tester);
      expect(find.text('Team inbox'), findsNothing);

      await tester.tap(find.text('Team'));
      await tester.pumpAndSettle();

      expect(teamMailboxRootNode.expandMode, ExpandMode.EXPAND);
      expect(find.text('Team inbox'), findsOneWidget);
      expect(controller.mailboxDestination.value, isNull);
    },
  );
}

DestinationPickerController _buildController() {
  final mailboxRepository = _FakeMailboxRepository();
  final controller = DestinationPickerController(
    SearchMailboxInteractor(),
    CreateNewMailboxInteractor(mailboxRepository),
    TreeBuilder(),
    VerifyNameInteractor(),
    GetAllMailboxInteractor(mailboxRepository),
    RefreshAllMailboxInteractor(mailboxRepository),
  );
  controller.arguments = DestinationPickerArguments(
    AccountId(Id('account')),
    MailboxActions.select,
    null,
  );
  controller.mailboxAction.value = MailboxActions.select;
  return controller;
}

Future<void> _pumpPicker(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(1440, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(GetMaterialApp(
    localizationsDelegates: const [
      AppLocalizationsDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: LocalizationService.supportedLocales,
    home: Scaffold(body: DestinationPickerView()),
  ));
  await tester.pumpAndSettle();
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
  Get.put<ImagePaths>(ImagePaths());
  Get.put<ResponsiveUtils>(ResponsiveUtils());
  Get.put<Uuid>(MockUuid());
  Get.put<ToastManager>(MockToastManager());
  Get.put<TwakeAppManager>(MockTwakeAppManager());
  Get.testMode = true;
}

MailboxNode _buildTeamMailboxRootNode() {
  final node = MailboxNode(PresentationMailbox(
    MailboxId(Id('team-root')),
    name: MailboxName('Team'),
    namespace: _teamNamespace,
  ));
  node.addChildNode(MailboxNode(PresentationMailbox(
    MailboxId(Id('team-inbox')),
    name: MailboxName('Team inbox'),
    parentId: MailboxId(Id('team-root')),
    namespace: _teamNamespace,
  )));
  return node;
}

MailboxTree _buildTreeWith(MailboxNode node) {
  final root = MailboxNode.root();
  root.addChildNode(node);
  return MailboxTree(root);
}
