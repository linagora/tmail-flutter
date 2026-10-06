import 'dart:convert';
import 'dart:io';

void main() {
  final source = buildHtmlEmailCorpusDart();
  File('${htmlEmailCorpusDirectory().path}/html_email_corpus.g.dart')
      .writeAsStringSync(source);
  stdout.writeln(
    'Wrote ${RegExp(r'HtmlEmailCorpusFixture\(').allMatches(source).length} fixtures',
  );
}

Directory corePackageRoot() {
  final cwd = Directory.current;
  final here = File(
    '${cwd.path}/lib/presentation/utils/html_transformer/transform_configuration.dart',
  );
  if (here.existsSync()) return cwd;
  final nested = Directory('${cwd.path}/core');
  final nestedFile = File(
    '${nested.path}/lib/presentation/utils/html_transformer/transform_configuration.dart',
  );
  if (nestedFile.existsSync()) return nested;
  throw StateError('Cannot find core package from ${cwd.path}');
}

Directory htmlEmailCorpusDirectory() =>
    Directory('${corePackageRoot().path}/test/fixtures/html_emails');

String buildHtmlEmailCorpusDart() {
  final emailsDir = htmlEmailCorpusDirectory();
  if (!emailsDir.existsSync()) {
    throw StateError('Missing ${emailsDir.path}');
  }

  final rootPrefix = emailsDir.path.endsWith('/')
      ? emailsDir.path
      : '${emailsDir.path}/';
  final fixtures = <_Parsed>[];
  for (final entity in emailsDir.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.html')) continue;
    fixtures.add(_parse(entity, rootPrefix));
  }
  fixtures.sort((a, b) {
    final byCategory = a.category.compareTo(b.category);
    return byCategory != 0 ? byCategory : a.name.compareTo(b.name);
  });

  final buffer = StringBuffer()
    ..writeln('// GENERATED — run: dart run tool/generate_html_email_corpus.dart')
    ..writeln("import 'html_email_corpus_fixture.dart';")
    ..writeln()
    ..writeln('const htmlEmailCorpus = <HtmlEmailCorpusFixture>[');

  for (final fixture in fixtures) {
    buffer
      ..writeln('  HtmlEmailCorpusFixture(')
      ..writeln('    name: ${jsonEncode(fixture.name)},')
      ..writeln('    category: ${jsonEncode(fixture.category)},')
      ..writeln('    html: ${jsonEncode(fixture.html)},')
      ..writeln('    expectQuote: ${fixture.expectQuote},')
      ..writeln('    rtl: ${fixture.rtl},')
      ..writeln('    minPreservation: ${fixture.minPreservation},')
      ..writeln('    source: ${jsonEncode(fixture.source)},')
      ..writeln('    allowEmptyBody: ${fixture.allowEmptyBody},')
      ..writeln('  ),');
  }
  buffer.writeln('];');
  return buffer.toString();
}

class _Parsed {
  _Parsed({
    required this.name,
    required this.category,
    required this.html,
    required this.expectQuote,
    required this.rtl,
    required this.minPreservation,
    required this.source,
    required this.allowEmptyBody,
  });

  final String name;
  final String category;
  final String html;
  final bool expectQuote;
  final bool rtl;
  final double minPreservation;
  final String source;
  final bool allowEmptyBody;
}

_Parsed _parse(File htmlFile, String rootPrefix) {
  final relative = htmlFile.path.substring(rootPrefix.length);
  final parts = relative.split('/');
  final category = parts.length > 1 ? parts.first : 'uncategorized';
  final name = htmlFile.uri.pathSegments.last.replaceAll('.html', '');
  final sidecarPath = htmlFile.path.replaceFirst(RegExp(r'\.html$'), '.json');
  final sidecar = File(sidecarPath);
  var expectQuote = false;
  var rtl = false;
  var minPreservation = 0.95;
  var source = '';
  var allowEmptyBody = false;
  if (sidecar.existsSync()) {
    final json = jsonDecode(sidecar.readAsStringSync()) as Map<String, dynamic>;
    expectQuote = json['expectQuote'] == true;
    rtl = json['rtl'] == true;
    minPreservation = (json['minPreservation'] as num?)?.toDouble() ?? 0.95;
    source = json['source'] as String? ?? '';
    allowEmptyBody = json['allowEmptyBody'] == true;
  }
  return _Parsed(
    name: name,
    category: category,
    html: htmlFile.readAsStringSync(),
    expectQuote: expectQuote,
    rtl: rtl,
    minPreservation: minPreservation,
    source: source,
    allowEmptyBody: allowEmptyBody,
  );
}
