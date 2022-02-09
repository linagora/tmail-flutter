
import 'package:model/email/presentation_email.dart';

extension ListPresentationEmailExtension on List<PresentationEmail> {
  bool get isAllEmailRead => every((email) => email.isReadEmail());
}