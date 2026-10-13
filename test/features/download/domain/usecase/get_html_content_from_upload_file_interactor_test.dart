import 'dart:convert';
import 'dart:typed_data';

import 'package:core/presentation/utils/html_transformer/text/standardize_html_sanitizing_transformers.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:model/email/attachment.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/download/domain/repository/download_repository.dart';
import 'package:tmail_ui_user/features/download/domain/usecase/get_html_content_from_upload_file_interactor.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_task_id.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/upload_file_state.dart';

/// Records the configuration the attachment HTML is sanitized with.
class _CapturingDownloadRepository extends Fake implements DownloadRepository {
  final List<TransformConfiguration> configurations = [];

  @override
  Future<String> sanitizeHtmlContent(
    String htmlContent,
    TransformConfiguration configuration,
  ) async {
    configurations.add(configuration);
    return htmlContent;
  }
}

void main() {
  test('SHOULD sanitize the HTML of an uploaded attachment before previewing it', () async {
    final repository = _CapturingDownloadRepository();
    const html = '<p>attachment</p>';

    await GetHtmlContentFromUploadFileInteractor(repository)
        .execute(
          uploadFile: UploadFileState(
            const UploadTaskId('task'),
            file: FileBytesInfo(
              fileName: 'page.html',
              bytes: Uint8List.fromList(utf8.encode(html)),
            ),
            attachment: Attachment(name: 'page.html', type: null),
          ),
          session: null,
          accountId: null,
        )
        .toList();

    expect(repository.configurations, hasLength(1));
    expect(
      repository.configurations.single.textTransformers,
      contains(isA<StandardizeHtmlSanitizingTransformers>()),
    );
  });
}
