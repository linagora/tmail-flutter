import 'package:equatable/equatable.dart';

class RecentLoginUrl with EquatableMixin {
  final Uri url;
  final DateTime creationDate;

  RecentLoginUrl(this.url, this.creationDate);

  factory RecentLoginUrl.now(Uri url) =>
    RecentLoginUrl(url, DateTime.now());

  @override
  List<Object?> get props => [url, creationDate];
}