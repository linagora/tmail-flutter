
import 'package:core/data/network/dio_client.dart';
import 'package:core/presentation/utils/html_transformer/base/dom_transformer.dart';
import 'package:html/dom.dart';

class EnsureRelationNoReferrerTransformer extends DomTransformer {

  const EnsureRelationNoReferrerTransformer();

  @override
  Future<void> process(
      Document document,
      String message,
      Map<String, String>? mapUrlDownloadCID,
      DioClient dioClient
  ) async {
    final linkElements = document.getElementsByTagName('a');
    await Future.wait(linkElements.map((linkElement) async {
      linkElement.attributes['rel'] = 'noopener noreferrer';
    }));
  }
}