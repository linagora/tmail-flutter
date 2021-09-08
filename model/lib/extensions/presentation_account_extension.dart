import 'package:model/model.dart';

extension PresentationAccountExtension on PresentationAccount {
  PresentationAccountResponse toPresentationAccountResponse() {
    return PresentationAccountResponse(emails, preferredEmailIndex, type);
  }
}