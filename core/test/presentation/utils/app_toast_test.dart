import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';

class MockResponsiveUtils extends Mock implements ResponsiveUtils {
  @override
  double getMaxWidthToast(BuildContext context) => 300;
}

void main() {
  group('AppToast - showToastMessageWithMultipleActions', () {
    late AppToast appToast;
    late MockResponsiveUtils mockResponsiveUtils;

    setUp(() {
      appToast = AppToast();
      mockResponsiveUtils = MockResponsiveUtils();
      Get.put<ResponsiveUtils>(mockResponsiveUtils);
    });

    tearDown(() {
      Get.reset();
    });

    testWidgets(
      'should show action button '
      'when actionName is provided and trigger callback when tapped',
    (WidgetTester tester) async {
      await tester.runAsync(() async {
        var callbackTriggered = false;
      
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return TextButton(
                    onPressed: () {
                      appToast.showToastMessageWithMultipleActions(
                        context,
                        'Test message',
                        actions: [
                          (
                            actionName: 'Retry',
                            onActionClick: () {
                              callbackTriggered = true;
                            },
                            actionIcon: null,
                          ),
                        ],
                      );
                    },
                    child: const Text('Show toast'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show toast'));
        await tester.pump();

        expect(find.text('Retry'), findsOneWidget);

        await tester.tap(find.text('Retry'));
        await tester.pump();

        expect(callbackTriggered, true);
      });
    });
  });
}