import 'package:core/utils/app_logger.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/initial_scripts/web_editor_script_descriptor.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/initial_scripts/web_editor_script_group.dart';

/// Derives both the initial script registrations and the init-time command
/// names from one deduplicated descriptor list (first group wins on a name).
final class WebEditorScriptsFactory {
  WebEditorScriptsFactory({required this.groups});

  final List<WebEditorScriptGroup> groups;

  late final List<WebEditorScriptDescriptor> _descriptors =
      _dedupeDescriptors();

  List<WebScript> buildInitialScripts() => [
    for (final descriptor in _descriptors) descriptor.script,
  ];

  List<String> buildInitializationScriptNames() => [
    for (final descriptor in _descriptors)
      if (descriptor.runOnInit) descriptor.script.name,
  ];

  List<WebEditorScriptDescriptor> _dedupeDescriptors() {
    final registeredNames = <String>{};
    final dedupedDescriptors = <WebEditorScriptDescriptor>[];

    for (final group in groups) {
      for (final descriptor in group.build()) {
        if (registeredNames.add(descriptor.script.name)) {
          dedupedDescriptors.add(descriptor);
        } else {
          logWarning(
            'WebEditorScriptsFactory::_dedupeDescriptors: '
            'duplicated script name "${descriptor.script.name}" skipped, '
            'the first registration wins',
          );
        }
      }
    }

    return dedupedDescriptors;
  }
}
