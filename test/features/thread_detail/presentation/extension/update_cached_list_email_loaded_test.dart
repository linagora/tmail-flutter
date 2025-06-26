import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/email/presentation/model/email_loaded.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/update_cached_list_email_loaded.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';

import 'update_cached_list_email_loaded_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ThreadDetailController>()])
void main() {
  late MockThreadDetailController threadDetailController;

  setUp(() {
    threadDetailController = MockThreadDetailController();
  });

  group('update cached list email loaded test:', () {
    test(
      'should update cachedEmailLoaded as expected '
      'when cachedEmailLoaded contains less than limit (20)',
    () {
      // arrange
      when(threadDetailController.cachedEmailLoaded).thenReturn({
        for (int i = 0; i < 18; i++) EmailId(Id('$i')): EmailLoaded(
          htmlContent: '',
          attachments: [],
          inlineImages: [],
          emailCurrent: Email(id: EmailId(Id('$i'))),
        ),
      });
      final expectedEmailLoaded = EmailLoaded(
        htmlContent: '',
        attachments: [],
        inlineImages: [],
        emailCurrent: Email(id: EmailId(Id('19'))),
      );
      
      // act
      threadDetailController.cacheEmailLoaded(
        expectedEmailLoaded.emailCurrent!.id!,
        expectedEmailLoaded,
      );
      
      // assert
      expect(
        expectedEmailLoaded,
        threadDetailController.cachedEmailLoaded.values.last,
      );
    });

    test(
      'should update cachedEmailLoaded as expected '
      'when cachedEmailLoaded contains more than limit (20)',
    () {
      when(threadDetailController.cachedEmailLoaded).thenReturn({});
      for (var i = 0; i < 25; i++) {
        final expectedEmailLoaded = EmailLoaded(
          htmlContent: '',
          attachments: [],
          inlineImages: [],
          emailCurrent: Email(id: EmailId(Id('$i'))),
        );
        threadDetailController.cacheEmailLoaded(
          expectedEmailLoaded.emailCurrent!.id!,
          expectedEmailLoaded,
        );

        if (i >= 20) {
          expect(
            expectedEmailLoaded,
            threadDetailController.cachedEmailLoaded.values.last,
          );
          expect(
            threadDetailController.cachedEmailLoaded[EmailId(Id('${i - 20}'))],
            isNull,
          );
        }
      }
    });
  });
}