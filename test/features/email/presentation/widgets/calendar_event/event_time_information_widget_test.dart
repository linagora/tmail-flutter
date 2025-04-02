import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/calendar_event/event_time_information_widget.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/resources/image_paths.dart';

import '../../../../../fixtures/widget_fixtures.dart';

void main() {
  setUp(() {
    Get.put<ResponsiveUtils>(ResponsiveUtils());
    Get.put<ImagePaths>(ImagePaths());
  });

  tearDown(() {
    Get.reset();
  });

  group('EventTimeInformationWidget tests', () {
    Widget makeTestableWidget({
      required String timeEvent,
      required bool isFree,
    }) {
      return WidgetFixtures.makeTestableWidget(
        child: EventTimeInformationWidget(
          timeEvent: timeEvent,
          isFree: isFree,
        ),
      );
    }

    testWidgets('should show error icon with tooltip when isFree is false', (tester) async {
      // arrange
      final widget = makeTestableWidget(
        timeEvent: '10:00 AM - 11:00 AM',
        isFree: false,
      );

      // act
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // assert
      final svgFinder = find.byWidgetPredicate((widget) {
        return widget is SvgPicture
          && (widget.bytesLoader as SvgAssetLoader).assetName == Get.find<ImagePaths>().icError;
      });
      expect(svgFinder, findsOneWidget);
      expect(find.byType(Tooltip), findsOneWidget);
    });

    testWidgets('should not show error icon when isFree is true', (tester) async {
      // arrange
      final widget = makeTestableWidget(
        timeEvent: '10:00 AM - 11:00 AM',
        isFree: true,
      );

      // act
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // assert
      expect(find.byType(SvgPicture), findsNothing);
      expect(find.byType(Tooltip), findsNothing);
    });
  });
}