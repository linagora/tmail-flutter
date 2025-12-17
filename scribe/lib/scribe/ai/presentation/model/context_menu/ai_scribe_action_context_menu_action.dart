import 'package:core/presentation/resources/image_paths.dart';
import 'package:scribe/scribe/ai/localizations/scribe_localizations.dart';
import 'package:scribe/scribe/ai/presentation/model/ai_scribe_menu_action.dart';
import 'package:scribe/scribe/ai/presentation/model/context_menu/ai_scribe_context_menu_action.dart';

class AiScribeActionContextMenuAction
    extends AiScribeContextMenuAction<AIScribeMenuAction> {
  AiScribeActionContextMenuAction(
    super.action,
    this.localizations,
    this.imagePaths,
  );

  final ScribeLocalizations localizations;
  final ImagePaths imagePaths;

  @override
  String get actionName => action.getLabel(localizations);

  @override
  String? get actionIcon => action.getIcon(imagePaths);

  @override
  bool get hasSubmenu => false;

  @override
  List<AiScribeContextMenuAction>? get submenuActions => null;
}
