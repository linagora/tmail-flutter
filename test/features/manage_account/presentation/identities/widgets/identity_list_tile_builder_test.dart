import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/html_viewer/html_content_viewer_widget.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/identities/widgets/identity_list_tile_builder.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/identities/widgets/signature_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';

import '../../../../base/fake_inappwebview_platform.dart';

void main() {
  final identityId = IdentityId(Id('identity-1'));
  const rawSignature = '<p>Sig</p><img src="x" onerror="alert(1)">';
  const sanitizedSignature = '<p>Sig</p><img src="x">';

  setUp(() {
    FakeInAppWebViewPlatform.install();
    Get.testMode = true;
    Get.put(ImagePaths());
    Get.put(ResponsiveUtils());
  });

  tearDown(Get.reset);

  Future<void> pumpTile(
    WidgetTester tester, {
    required Map<IdentityId, String> mapIdentitySignatures,
  }) async {
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LocalizationService.supportedLocales,
      home: Scaffold(
        body: SingleChildScrollView(
          child: IdentityListTileBuilder(
            identity: Identity(
              id: identityId,
              name: 'Work',
              email: 'alice@example.com',
              htmlSignature: Signature(rawSignature),
              mayDelete: true,
            ),
            mapIdentitySignatures: mapIdentitySignatures,
            signatureViewState: Right(UIState.idle),
            imagePaths: Get.find<ImagePaths>(),
            onEditIdentityAction: (_) {},
            onDeleteIdentityAction: (_) {},
          ),
        ),
      ),
    ));
    await tester.pump();
    expect(tester.takeException(), isNull);
  }

  testWidgets(
    'should not render the stored signature '
    'while its sanitized version is not ready',
  (tester) async {
    await pumpTile(tester, mapIdentitySignatures: {});

    expect(find.byType(SignatureBuilder), findsNothing);
    expect(find.text('--'), findsOneWidget);
  });

  testWidgets(
    'should render only the sanitized signature '
    'once it is ready',
  (tester) async {
    await pumpTile(
      tester,
      mapIdentitySignatures: {identityId: sanitizedSignature},
    );

    final viewer = tester.widget<HtmlContentViewer>(find.byType(HtmlContentViewer));
    expect(viewer.contentHtml, sanitizedSignature);
  });
}
