import 'package:model/model.dart';
import 'package:tmail_ui_user/features/login/data/model/response/presentation_account_response.dart';

extension PresentationAccountExtension on PresentationAccount {
  PresentationAccountResponse toPresentationAccountResponse() {
    return PresentationAccountResponse(emails, preferredEmailIndex, type);
  }
}