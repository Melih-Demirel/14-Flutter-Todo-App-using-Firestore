import 'dart:math';
String generateUuid() {
  final random = Random();
  final sb = StringBuffer();
  for (var i = 0; i < 32; i++) {
  final hex = (random.nextInt(16)).toRadixString(16);
  sb.write(hex);
  }
  return sb.toString();
}