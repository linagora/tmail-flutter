import 'package:built_collection/built_collection.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';

extension ListMailboxExtensions on List<Mailbox> {
  Tuple2<List<PresentationMailbox>, List<PresentationMailbox>> splitMailboxList(bool Function(Mailbox element) test) {
    final validBuilder = ListBuilder<PresentationMailbox>();
    final invalidBuilder = ListBuilder<PresentationMailbox>();
    forEach((element) {
      if (test(element)) {
        validBuilder.add(element.toPresentationMailbox());
      } else {
        invalidBuilder.add(element.toPresentationMailbox());
      }
    });
    return Tuple2(
        validBuilder.build().toList(),
        invalidBuilder.build().toList());
  }
}