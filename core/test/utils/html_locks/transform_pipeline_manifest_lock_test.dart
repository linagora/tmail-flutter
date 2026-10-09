@TestOn('vm')

import 'package:core/presentation/utils/html_transformer/text/standardize_html_sanitizing_transformers.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter_test/flutter_test.dart';

import '../html_pipeline_registry.dart';
import 'html_lock_golden.dart';

/// Locks the exact, ordered transformer list (and parameters) of every HTML
/// pipeline. Adding, removing, reordering or re-parameterizing a transformer
/// fails here with a diff naming the pipeline and position.
void main() {
  tearDown(() {
    PlatformInfo.isTestingForWeb = false;
  });

  String describeTransformer(Object transformer) {
    final name = transformer.runtimeType.toString();
    if (transformer is StandardizeHtmlSanitizingTransformers) {
      final allowed = transformer.allowAttributes;
      return allowed == null ? name : '$name(allowAttributes: $allowed)';
    }
    return name;
  }

  String describePipeline(TransformConfiguration configuration) {
    final buffer = StringBuffer()..writeln('text:');
    for (final transformer in configuration.textTransformers) {
      buffer.writeln('  - ${describeTransformer(transformer)}');
    }
    buffer.writeln('dom:');
    for (final transformer in configuration.domTransformers) {
      buffer.writeln('  - ${describeTransformer(transformer)}');
    }
    return buffer.toString();
  }

  final rows = htmlPipelineRegistry();

  for (final row in rows) {
    test('${row.name} transformer manifest is locked', () {
      expectMatchesHtmlLock(
        'pipeline_manifest/${row.name}.txt',
        describePipeline(row.build()),
      );
    });
  }

  test('no manifest lock is left for a removed pipeline', () {
    expect(
      orphanHtmlLockFiles(
        'pipeline_manifest',
        rows.map((row) => '${row.name}.txt').toSet(),
      ),
      isEmpty,
    );
  });
}
