import 'package:core/utils/html/host_script_nonce.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const valid = 'aBc123+/=_-XYZ';

  test('accepts a nonce and rejects empty or an invalid character', () {
    expect(HostScriptNonce.isValid(valid), isTrue);
    expect(HostScriptNonce.isValid(''), isFalse);
    expect(HostScriptNonce.isValid(null), isFalse);
    expect(HostScriptNonce.isValid('bad nonce'), isFalse);
    expect(HostScriptNonce.isValid('quote"'), isFalse);
    expect(HostScriptNonce.read(), isNull);
  });

  test('stamps only the script tags it is given', () {
    const scripts = '<script type="text/javascript">var x = 1;</script>';
    expect(
      HostScriptNonce.stampOwnScriptTags(scripts, valid),
      '<script nonce="$valid" type="text/javascript">var x = 1;</script>',
    );
    expect(HostScriptNonce.stampOwnScriptTags(scripts, null), scripts);
    expect(HostScriptNonce.stampOwnScriptTags(scripts, ''), scripts);
    expect(HostScriptNonce.stampOwnScriptTags(scripts, 'bad nonce'), scripts);
  });

  test('stamps SCRIPT tags and leaves script-x and bare <script tokens alone', () {
    const html = '<SCRIPT src="a.js"></SCRIPT>'
        '<script-x>keep</script-x>'
        '<script type="text/javascript">var re=/<script|<style/;</script>';
    expect(
      HostScriptNonce.stampOwnScriptTags(html, valid),
      '<script nonce="$valid" src="a.js"></SCRIPT>'
      '<script-x>keep</script-x>'
      '<script nonce="$valid" type="text/javascript">var re=/<script|<style/;</script>',
    );
  });

  test('rejects a 1 MB invalid nonce', () {
    final nonce = '${'a' * (1024 * 1024)}!';
    expect(HostScriptNonce.isValid(nonce), isFalse);
  });
}
