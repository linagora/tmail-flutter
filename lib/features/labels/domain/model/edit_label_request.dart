import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:labels/model/label.dart';

class EditLabelRequest with EquatableMixin {
  final Id labelId;
  final KeyWordIdentifier? labelKeyword;
  final Label newLabel;

  EditLabelRequest({
    required this.labelId,
    required this.labelKeyword,
    required this.newLabel,
  });

  @override
  List<Object?> get props => [labelId, labelKeyword, newLabel];
}
