import 'package:textfield_tags/textfield_tags.dart';

class CustomController extends TextfieldTagsController {
  CustomController() : super();
  late Function(String)? actionRemoveTag;
  late Function(String)? actionAddTag;
  late Function(String)? actionChangeText;

  //create your own methods
  void setActionRemoveTag(Function(String) action) {
    actionRemoveTag = action;
  }

  void setActionAddTag(Function(String) action) {
    actionAddTag = action;
  }

  void setActionChangeText(Function(String) action) {
    actionChangeText = action;
  }

  @override
  set removeTag(String tag) {
    actionRemoveTag?.call(tag);
    super.removeTag = tag;
  }

  @override
  void onTagDelete(String tag) {
    actionRemoveTag?.call(tag);
    super.onTagDelete(tag);
  }

  @override
  void onChanged(String value) {
    final ts = [' ', ','];
    final separator = ts.cast<String?>().firstWhere(
        (element) => value.contains(element!) && value.indexOf(element) != 0,
        orElse: () => null);
    actionChangeText?.call(value);
    if (separator != null) {
      final splits = value.split(separator);
      final indexer = splits.length > 1 ? splits.length - 2 : splits.length - 1;
      final val = splits.elementAt(indexer).trim();
      if(val.isNotEmpty){
        actionAddTag?.call(val);
      }
    }
    super.onChanged(value);
  }
}
