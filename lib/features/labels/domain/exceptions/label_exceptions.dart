import 'package:core/domain/exceptions/app_base_exception.dart';

class LabelKeywordIsNull extends AppBaseException {
  const LabelKeywordIsNull([super.message = 'Label keyword is null']);

  @override
  String get exceptionName => 'LabelKeywordIsNull';
}

class LabelIdIsNull extends AppBaseException {
  const LabelIdIsNull([super.message = 'Label id is null']);

  @override
  String get exceptionName => 'LabelIdIsNull';
}
