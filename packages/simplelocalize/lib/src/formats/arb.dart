import 'dart:convert';

import 'abstract.dart';

class SimplelocalizeArbFormat implements SimplelocalizeBaseFormat {
  const SimplelocalizeArbFormat();

  static const encoder = const JsonEncoder.withIndent('  ');

  @override
  String convert(Map<String, String> translations) {
    return encoder.convert(translations);
  }

  @override
  Map<String, String> parse(String contents) {
    final Map<String, String> result =
        (jsonDecode(contents) as Map).cast<String, String>();
    result.removeWhere((key, value) => key.startsWith('@'));
    return result;
  }
}
