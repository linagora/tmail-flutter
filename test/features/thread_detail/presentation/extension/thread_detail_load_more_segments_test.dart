import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/thread_detail_load_more_segments.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';

import 'thread_detail_load_more_segments_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ThreadDetailController>()])
void main() {
  late MockThreadDetailController controller;

  setUp(() {
    controller = MockThreadDetailController();
  });

  group('ThreadDetailLoadMoreSegments', () {
    test(
      'should return empty map when emailIdsPresentation is empty',
    () {
      // arrange
      when(controller.emailIdsPresentation).thenReturn(<EmailId, PresentationEmail?>{}.obs);
      
      // act
      final result = controller.loadMoreSegments;

      // assert
      expect(result, {});
    });

    test(
      'should return correct load more segments when there are null values in emailIdsPresentation',
    () {
      // arrange
      when(controller.emailIdsPresentation).thenReturn({
        EmailId(Id('1')): PresentationEmail(),
        EmailId(Id('2')): null,
        EmailId(Id('3')): null,
        EmailId(Id('4')): PresentationEmail(),
        EmailId(Id('5')): null,
      }.obs);
      
      // act
      final result = controller.loadMoreSegments;
      
      // assert
      expect(result, {
        1: 2,
        4: 1,
      });
    });

    test(
      'should return correct load more segments when there are no null values in emailIdsPresentation',
    () {
      // arrange
      when(controller.emailIdsPresentation).thenReturn({
        EmailId(Id('1')): PresentationEmail(),
        EmailId(Id('2')): PresentationEmail(),
        EmailId(Id('3')): PresentationEmail(),
        EmailId(Id('4')): PresentationEmail(),
        EmailId(Id('5')): PresentationEmail(),
      }.obs);
      
      // act
      final result = controller.loadMoreSegments;
      
      // assert
      expect(result, {});
    });
  });
}