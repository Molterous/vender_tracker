import 'dart:convert';
import 'package:archive/archive.dart';

// Compress and encode
String compressAndEncode(String input) {
  List<int> jsonBytes = utf8.encode(input);
  List<int> compressed = const GZipEncoder().encode(jsonBytes)!;
  return base64.encode(compressed); // Safe to store as string
}

// Decode and decompress
String decodeAndDecompress(String input) {
  List<int> compressed = base64.decode(input);
  List<int> decompressed = const GZipDecoder().decodeBytes(compressed);
  return utf8.decode(decompressed);
}
