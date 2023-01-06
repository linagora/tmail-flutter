import 'package:equatable/equatable.dart';

class SpamReport with EquatableMixin {

  final DateTime lastTimeDismissedSpamReported;

  SpamReport(this.lastTimeDismissedSpamReported);

  @override
  List<Object?> get props => [lastTimeDismissedSpamReported];
}