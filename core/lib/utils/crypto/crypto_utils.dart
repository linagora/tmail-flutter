class CryptoUtils {
  CryptoUtils();

  String encodeBase64(String base64, {bool noPadding = true, bool noWrapping = true}) {
    if (noPadding) {
      base64 = base64.replaceAll('=', '');
    }
    if (noWrapping) {
      base64 = base64.replaceAll('\n', '')
        .replaceAll('\r', '');
    }
    return base64;
  }
}