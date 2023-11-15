
import 'package:equatable/equatable.dart';

class EmailUnsubscribe with EquatableMixin {

  final List<String> httpLinks;
  final List<String> mailtoLinks;

  EmailUnsubscribe({
    required this.httpLinks,
    required this.mailtoLinks
  });

  @override
  List<Object?> get props => [
    httpLinks,
    mailtoLinks
  ];
}