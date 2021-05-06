import 'dart:convert';

import 'abstract.dart';

class SimplelocalizeJsonFormat implements SimplelocalizeBaseFormat {
  const SimplelocalizeJsonFormat();

  static const encoder = const JsonEncoder.withIndent('  ');

  @override
  String convert(Map<String, String> translations) {
    return encoder.convert(translations);
  }

  @override
  Map<String, String> parse(String contents) {
    return (jsonDecode(contents) as Map).cast<String, String>();
  }
}
