
import 'package:core/data/network/dio_client.dart';
import 'package:core/presentation/utils/html_transformer/base/dom_transformer.dart';
import 'package:core/utils/app_logger.dart';
import 'package:html/dom.dart';

class SignatureTransformer extends DomTransformer {

  const SignatureTransformer();

  @override
  Future<void> process({
    required Document document,
    required DioClient dioClient,
    Map<String, String>? mapUrlDownloadCID,
  }) async {
    try {
      final signatureElements = document.querySelectorAll('div.tmail-signature');

      if (signatureElements.isEmpty) return;

      await Future.wait(signatureElements.map((element) async {
        element.attributes['class'] = 'tmail-signature-blocked';
      }));
    } catch (e) {
      logError('$runtimeType::process:Exception = $e');
    }
  }
}