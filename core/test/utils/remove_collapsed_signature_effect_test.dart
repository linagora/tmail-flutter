import 'package:core/presentation/utils/html_transformer/html_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('removeCollapsedSignatureEffect test', () {
    test('RemoveCollapsedSignatureEffect should remove all signature html tags when content CONTAIN ONE tag with attribute class is `tmail-signature-button`', () async {
      String originContent = '<p>Hello dab</p><div class="tmail-signature"><div class="tmail-signature-button">Signature</div><div class="tmail-signature-content">Content</div></div>';
      String expectedContent = '<p>Hello dab</p><div class="tmail-signature"><div class="tmail-signature-content">Content</div></div>';

      String actualContent = await HtmlUtils.removeCollapsedSignatureEffect(originContent);

      expect(actualContent, expectedContent);
    });

    test('RemoveCollapsedSignatureEffect should remove all signature html tags when content CONTAIN MULTIPLE tag with attribute class is `tmail-signature-button`', () async {
      String originContent = '<p>Hello dab</p><div class="tmail-signature"><div class="tmail-signature-button">Signature 1</div><div class="tmail-signature-content">Content 1</div></div><div class="tmail-signature"><div class="tmail-signature-button">Signature 2</div><div class="tmail-signature-content">Content 2</div></div>';
      String expectedContent = '<p>Hello dab</p><div class="tmail-signature"><div class="tmail-signature-content">Content 1</div></div><div class="tmail-signature"><div class="tmail-signature-content">Content 2</div></div>';

      String actualContent = await HtmlUtils.removeCollapsedSignatureEffect(originContent);

      expect(actualContent, expectedContent);
    });

    test('RemoveCollapsedSignatureEffect should be return origin content when content NOT CONTAIN tag with attribute class is `tmail-signature-button`', () async {
      String originContent = '<p>Hello dab</p><div class="tmail-signature"><div class="tmail-signature-content">Content</div></div>';
      String expectedContent = '<p>Hello dab</p><div class="tmail-signature"><div class="tmail-signature-content">Content</div></div>';

      String actualContent = await HtmlUtils.removeCollapsedSignatureEffect(originContent);

      expect(actualContent, expectedContent);
    });
  });
}