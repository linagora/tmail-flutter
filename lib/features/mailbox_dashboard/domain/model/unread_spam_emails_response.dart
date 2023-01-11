
import 'package:equatable/equatable.dart';

class UnreadSpamEmailsResponse with EquatableMixin {
  final int? unreadSpamEmailNumber;

  UnreadSpamEmailsResponse({
    this.unreadSpamEmailNumber,
  });

  @override
  List<Object?> get props => [unreadSpamEmailNumber];
}