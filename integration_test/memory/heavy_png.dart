import 'dart:math';
import 'dart:typed_data';

/// Size of the heavy image used by the memory scenarios.
/// 5 MiB keeps four copies base64-encoded (about 37% bigger) under bob's 50 MB quota.
const int kHeavyBytes = 5 * 1024 * 1024;

const int _width = 1024;
const int _rowBytes = _width * 3 + 1;
const int _maxStoredBlock = 65535;

/// Builds a valid RGB PNG of at least [targetBytes] bytes.
///
/// Rows hold seeded noise inside stored (uncompressed) deflate blocks, so the
/// size is predictable and the generator is pure Dart (web and IO).
Uint8List heavyPng({required int targetBytes, int seed = 42}) {
  if (targetBytes < _rowBytes) {
    throw ArgumentError.value(
      targetBytes,
      'targetBytes',
      'must be at least $_rowBytes',
    );
  }
  final height = (targetBytes + _rowBytes - 1) ~/ _rowBytes;
  final raw = Uint8List(height * _rowBytes);
  final random = Random(seed);
  for (var row = 0; row < height; row++) {
    final start = row * _rowBytes;
    // raw[start] stays 0: PNG filter type "None".
    for (var i = 1; i < _rowBytes; i++) {
      raw[start + i] = random.nextInt(256);
    }
  }

  final header = ByteData(13)
    ..setUint32(0, _width)
    ..setUint32(4, height)
    ..setUint8(8, 8) // bit depth
    ..setUint8(9, 2); // color type: RGB

  final out = BytesBuilder(copy: false)
    ..add(const [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
  _addChunk(out, 'IHDR', header.buffer.asUint8List());
  _addChunk(out, 'IDAT', _zlibStored(raw));
  _addChunk(out, 'IEND', Uint8List(0));
  return out.takeBytes();
}

Uint8List _zlibStored(Uint8List data) {
  final out = BytesBuilder(copy: false)..add(const [0x78, 0x01]);
  for (var offset = 0; offset < data.length; offset += _maxStoredBlock) {
    final length = min(_maxStoredBlock, data.length - offset);
    final isFinal = offset + length >= data.length;
    out
      ..add([
        isFinal ? 1 : 0,
        length & 0xFF,
        length >> 8,
        ~length & 0xFF,
        (~length >> 8) & 0xFF,
      ])
      ..add(Uint8List.sublistView(data, offset, offset + length));
  }
  final adler = ByteData(4)..setUint32(0, _adler32(data));
  out.add(adler.buffer.asUint8List());
  return out.takeBytes();
}

int _adler32(Uint8List data) {
  var a = 1;
  var b = 0;
  for (final byte in data) {
    a = (a + byte) % 65521;
    b = (b + a) % 65521;
  }
  return ((b << 16) | a) & 0xFFFFFFFF;
}

void _addChunk(BytesBuilder out, String type, Uint8List data) {
  final typeBytes = Uint8List.fromList(type.codeUnits);
  final length = ByteData(4)..setUint32(0, data.length);
  final crc = ByteData(4)
    ..setUint32(0, _crc32(data, _crc32(typeBytes, 0xFFFFFFFF)) ^ 0xFFFFFFFF);
  out
    ..add(length.buffer.asUint8List())
    ..add(typeBytes)
    ..add(data)
    ..add(crc.buffer.asUint8List());
}

final Uint32List _crcTable = _buildCrcTable();

Uint32List _buildCrcTable() {
  final table = Uint32List(256);
  for (var n = 0; n < 256; n++) {
    var c = n;
    for (var k = 0; k < 8; k++) {
      c = (c & 1) != 0 ? (0xEDB88320 ^ (c >> 1)) : (c >> 1);
    }
    table[n] = c & 0xFFFFFFFF;
  }
  return table;
}

// Runs the CRC update over [data] starting from [crc] (not yet inverted).
int _crc32(Uint8List data, int crc) {
  var c = crc;
  for (final byte in data) {
    c = (_crcTable[(c ^ byte) & 0xFF] ^ (c >> 8)) & 0xFFFFFFFF;
  }
  return c;
}

final Uint8List _heavyImage = heavyPng(targetBytes: kHeavyBytes);

/// A fresh copy per use, so a leak that keeps the bytes shows up as growth.
Uint8List get heavyImageBytes => Uint8List.fromList(_heavyImage);
