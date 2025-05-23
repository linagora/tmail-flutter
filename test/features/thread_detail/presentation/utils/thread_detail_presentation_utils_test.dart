import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/utils/thread_detail_presentation_utils.dart';

void main() {
  group('ThreadDetailPresentationUtils', () {
    group('getEmailIdsToLoad', () {
      test('loads first time with length equal or more than initial load size', () {
        final emailIdsPresentation = {
          EmailId(Id('1')): null,
          EmailId(Id('2')): null,
          EmailId(Id('3')): null,
          EmailId(Id('4')): null,
          EmailId(Id('5')): null,
        };

        final result = ThreadDetailPresentationUtils.getEmailIdsToLoad(emailIdsPresentation);

        expect(result.length, equals(ThreadDetailPresentationUtils.initialLoadSize));
        expect(result, equals([EmailId(Id('1')), EmailId(Id('2'))]));
      });

      test('loads first time with length smaller than initial load size', () {
        final emailIdsPresentation = {
          EmailId(Id('1')): null,
          EmailId(Id('2')): null,
        };

        final result = ThreadDetailPresentationUtils.getEmailIdsToLoad(emailIdsPresentation);

        expect(result.length, equals(emailIdsPresentation.length));
        expect(result, equals([EmailId(Id('1')), EmailId(Id('2'))]));
      });

      test('loads with length equal or more than default load size', () {
        final emailIdsPresentation = {
          EmailId(Id('1')): PresentationEmail(),
          EmailId(Id('2')): null,
          EmailId(Id('3')): null,
          EmailId(Id('4')): null,
          EmailId(Id('5')): null,
          EmailId(Id('6')): null,
          EmailId(Id('7')): null,
        };

        final result = ThreadDetailPresentationUtils.getEmailIdsToLoad(emailIdsPresentation);

        expect(result.length, equals(6));
        expect(result, equals([EmailId(Id('2')), EmailId(Id('3')), EmailId(Id('4')), EmailId(Id('5')), EmailId(Id('6')), EmailId(Id('7'))]));
      });

      test('loads with length smaller than default load size', () {
        final emailIdsPresentation = {
          EmailId(Id('1')): PresentationEmail(),
          EmailId(Id('2')): null,
          EmailId(Id('3')): null,
        };

        final result = ThreadDetailPresentationUtils.getEmailIdsToLoad(emailIdsPresentation);

        expect(result.length, equals(emailIdsPresentation.length - 1));
        expect(result, equals([EmailId(Id('2')), EmailId(Id('3'))]));
      });
    });
  });
}