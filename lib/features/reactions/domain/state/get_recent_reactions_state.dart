import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:flutter_emoji_mart/flutter_emoji_mart.dart';

class GetRecentReactionsSuccess extends UIState {
  final Category category;

  GetRecentReactionsSuccess(this.category);

  @override
  List<Object?> get props => [category];
}

class GetRecentReactionsFailure extends FeatureFailure {
  GetRecentReactionsFailure(dynamic exception) : super(exception: exception);
}
