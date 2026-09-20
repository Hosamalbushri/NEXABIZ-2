import 'dart:math';

/// RFC 9562 UUIDv7, adapted from the legacy NexaBiz ID generator.
/// Stable across restarts and independent of SQLite row order.
String generateCoreUuidV7() {
  final random = Random.secure();
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final bytes = List<int>.filled(16, 0);
  for (var i = 0; i < 6; i++) {
    bytes[i] = (timestamp >> (40 - i * 8)) & 0xff;
  }
  final randA = random.nextInt(4096);
  bytes[6] = 0x70 | ((randA >> 8) & 0x0f);
  bytes[7] = randA & 0xff;
  bytes[8] = 0x80 | random.nextInt(64);
  for (var i = 9; i < 16; i++) {
    bytes[i] = random.nextInt(256);
  }
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}
