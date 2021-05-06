import 'package:yaml/yaml.dart';

import 'abstract.dart';

class SimplelocalizeYamlFormat implements SimplelocalizeBaseFormat {
  const SimplelocalizeYamlFormat();

  @override
  String convert(Map<String, String> translations) {
    return translations.entries
        .map((kv) => '${kv.key}: "${kv.value.replaceAll('\n', '\\n')}"')
        .join('\n');
  }

  @override
  Map<String, String> parse(String contents) {
    return (loadYaml(contents) as Map).cast<String, String>();
  }
}
