import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/composer/domain/state/restore_email_inline_images_state.dart';
import 'package:tmail_ui_user/features/composer/domain/transformer/html_email_transformer.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/restore_email_inline_images_interactor.dart';

import 'restore_email_inline_images_interactor_test.mocks.dart';

@GenerateMocks([HtmlEmailTransformer])
void main() {
  late MockHtmlEmailTransformer mockTransformer;
  late RestoreEmailInlineImagesInteractor interactor;

  const htmlWithCid = '<img src="cid:abc123">';
  const restoredHtml = '<img src="data:image/png;base64,abc==">';
  final transformConfig = TransformConfiguration.forRestoreEmail();
  final mapCid = {'abc123': 'https://example.com/download/abc'};

  setUp(() {
    mockTransformer = MockHtmlEmailTransformer();
    interactor = RestoreEmailInlineImagesInteractor(mockTransformer);
  });

  group('execute', () {
    test('emits RestoringEmailInlineImages then RestoreEmailInlineImagesSuccess on success', () async {
      when(mockTransformer.transformToHtml(
        htmlContent: htmlWithCid,
        transformConfiguration: transformConfig,
        mapCidImageDownloadUrl: mapCid,
      )).thenAnswer((_) async => restoredHtml);

      final states = await interactor.execute(
        htmlContent: htmlWithCid,
        transformConfiguration: transformConfig,
        mapUrlDownloadCID: mapCid,
      ).map((either) => either.fold((f) => f, (s) => s)).toList();

      expect(states[0], isA<RestoringEmailInlineImages>());
      expect(states[1], isA<RestoreEmailInlineImagesSuccess>());
      expect((states[1] as RestoreEmailInlineImagesSuccess).emailContent, equals(restoredHtml));
    });

    test('emits RestoreEmailInlineImagesFailure when transformer throws', () async {
      when(mockTransformer.transformToHtml(
        htmlContent: anyNamed('htmlContent'),
        transformConfiguration: anyNamed('transformConfiguration'),
        mapCidImageDownloadUrl: anyNamed('mapCidImageDownloadUrl'),
      )).thenThrow(Exception('network error'));

      final states = await interactor.execute(
        htmlContent: htmlWithCid,
        transformConfiguration: transformConfig,
        mapUrlDownloadCID: mapCid,
      ).map((either) => either.fold((f) => f, (s) => s)).toList();

       expect(states, hasLength(2));
       expect(states[0], isA<RestoringEmailInlineImages>());
       expect(states[1], isA<RestoreEmailInlineImagesFailure>());
    });
  });
}
