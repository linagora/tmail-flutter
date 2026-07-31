@TestOn('chrome')
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workplace/data/model/workplace_intent_request.dart';
import 'package:workplace/domain/entity/workplace_intent.dart';
import 'package:workplace/presentation/model/drive_intent_image_assets.dart';
import 'package:workplace/presentation/view/drive_intent_web_view_modal.dart';

const _imageAssets = DriveIntentImageAssets(
  driveLogo: 'assets/images/twake-drive-logo.svg',
  closeIcon: 'assets/images/ic_close.svg',
  searchIcon: 'assets/images/ic_search_bar.svg',
);

const _filePickerConfig = WorkplaceFilePickerConfigRequest(
  sharingLink: WorkplaceActionConfigRequest(),
  downloadLink: null,
);

Widget _modal(Future<WorkplaceIntent> intent) {
  return MaterialApp(
    home: DriveIntentWebViewModal(
      intentLoader: () => intent,
      filePickerConfig: _filePickerConfig,
      imageAssets: _imageAssets,
    ),
  );
}

void main() {
  testWidgets(
    'preserves the iframe platform view in both resize directions (#4738)',
    (tester) async {
      // The intent never resolves: the modal stays in its loading phase, which
      // is exactly the window #4738 regresses in. The iframe lives in the shell
      // regardless of the skeleton, so it is mounted throughout.
      final intent = Completer<WorkplaceIntent>();
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1280, 800);

      await tester.pumpWidget(_modal(intent.future));
      await tester.pump();

      // The flutter_test web embedder does not attach the real <iframe> to the
      // live DOM, so recreation is asserted at the framework level: a stable
      // HtmlElementView Element means the platform view — and its iframe — was
      // never torn down. findsOneWidget additionally rules out an orphaned view
      // leaking alongside a fresh one.
      final platformView = find.byType(HtmlElementView);
      expect(platformView, findsOneWidget);
      final platformViewElement = tester.element(platformView);

      // Desktop -> mobile crosses the responsive breakpoint (1280 >= 1200 desktop,
      // 375 < 900 mobile), the transition that used to remount the iframe.
      tester.view.physicalSize = const Size(375, 800);
      await tester.pump();
      expect(platformView, findsOneWidget);
      expect(identical(platformViewElement, tester.element(platformView)), isTrue);

      // Mobile -> desktop: the reverse transition must be just as stable.
      tester.view.physicalSize = const Size(1280, 800);
      await tester.pump();
      expect(platformView, findsOneWidget);
      expect(identical(platformViewElement, tester.element(platformView)), isTrue);
    },
  );
}
