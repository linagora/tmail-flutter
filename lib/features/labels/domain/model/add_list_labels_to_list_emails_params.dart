import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:labels/extensions/list_label_extension.dart';
import 'package:labels/model/label.dart';
import 'package:tmail_ui_user/features/email/domain/state/labels/add_list_label_to_list_email_state.dart';

class AddListLabelsToListEmailsParams extends Equatable {
  final List<Label> labels;
  final List<EmailId> emailIds;
  final OnSyncListLabelForListEmail onSync;

  const AddListLabelsToListEmailsParams({
    required this.labels,
    required this.emailIds,
    required this.onSync,
  });

  List<KeyWordIdentifier> get labelKeywords => labels.keywords;

  List<String> get labelDisplays => labels.displayNameNotNullList;

  @override
  List<Object?> get props => [labels, emailIds, onSync];
}