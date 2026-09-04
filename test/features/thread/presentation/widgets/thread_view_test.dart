import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_view.dart';

import '../../../../fixtures/widget_fixtures.dart';

void main() {
  final imagePaths = ImagePaths();

  testWidgets('renders the legacy archive action icon for email swipe',
      (tester) async {
    await tester.pumpWidget(
      WidgetFixtures.makeTestableWidget(
        child: Builder(
          builder: (context) => ThreadView.buildEmailSwipeSecondaryBackground(
            context,
            imagePaths,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (widget) => widget is SvgPicture
            && widget.bytesLoader is SvgAssetLoader
            && (widget.bytesLoader as SvgAssetLoader).assetName
                == imagePaths.icMailboxArchivedAction,
      ),
      findsOneWidget,
    );
  });
}
