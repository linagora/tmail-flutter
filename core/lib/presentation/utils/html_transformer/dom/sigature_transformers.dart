
import 'package:core/data/network/dio_client.dart';
import 'package:core/presentation/utils/html_transformer/base/dom_transformer.dart';
import 'package:html/dom.dart';

class SignatureTransformer extends DomTransformer {

  const SignatureTransformer();

  @override
  Future<void> process(
      Document document,
      String message,
      {
        Map<String, String>? mapUrlDownloadCID,
        DioClient? dioClient
      }
  ) async {
    final signatureElements = document.querySelectorAll('div.tmail-signature');
    await Future.wait(signatureElements.map((element) async {
      element.attributes['class'] = 'tmail-signature-blocked';
    }));
  }
}