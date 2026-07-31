import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workplace/presentation/model/drive_intent_image_assets.dart';
import 'package:workplace/presentation/view/drive_intent_skeleton_loader.dart';

const _closeButtonKey = ValueKey('close-button');
const _skeletonKey = ValueKey('desktop-skeleton');
const _imageAssets = DriveIntentImageAssets(
  driveLogo: 'assets/images/twake-drive-logo.svg',
  closeIcon: 'assets/images/ic_close.svg',
  searchIcon: 'assets/images/ic_search_bar.svg',
);

void main() {
  testWidgets('desktop loading close button matches the design', (tester) async {
    var closeCalls = 0;
    final closeButton = TMailButtonWidget.fromIcon(
      key: _closeButtonKey,
      icon: _imageAssets.closeIcon,
      width: 40,
      height: 40,
      iconSize: 24,
      padding: const EdgeInsets.all(8),
      backgroundColor: Colors.transparent,
      onTapActionCallback: () => closeCalls++,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            key: _skeletonKey,
            width: 800,
            height: 500,
            child: DriveIntentSkeletonLoader.table(
              imageAssets: _imageAssets,
              closeButton: closeButton,
            ),
          ),
        ),
      ),
    );

    final closeButtonFinder = find.byKey(_closeButtonKey);
    final closeContainerFinder = find.descendant(
      of: closeButtonFinder,
      matching: find.byType(Container),
    );
    final skeletonRect = tester.getRect(find.byKey(_skeletonKey));
    final closeRect = tester.getRect(closeContainerFinder);

    expect(closeRect.size, const Size(40, 40));
    expect(closeRect.top, skeletonRect.top + 12);
    expect(closeRect.right, skeletonRect.right - 17);

    await tester.tap(closeContainerFinder);
    expect(closeCalls, 1);
  });
}
