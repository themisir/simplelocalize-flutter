library simplelocalize;

import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

import 'src/formats/abstract.dart';
import 'src/formats/json.dart';
import 'src/formats/yaml.dart';
import 'src/simplelocalize_api.dart';
import 'src/simplelocalize_config.dart';

const kSimplelocalizeKey = 'simplelocalize';
const kSimplelocalizeFormats = <String, SimplelocalizeBaseFormat>{
  'json': SimplelocalizeJsonFormat(),
  'yaml': SimplelocalizeYamlFormat(),
};

class SimplelocalizeGenerator {
  SimplelocalizeConfig config;
  SimplelocalizeBaseFormat format;

  void validateConfig() {
    if (config.directory == null) {
      error(2, 'Parameter "directory" is not defined in config file');
    }

    if (config.filename == null) {
      error(2, 'Parameter "filename" is not defined in config file');
    }

    if (!config.filename.contains('{1}')) {
      error(
        2,
        'File name pattern should contain {1} argument which refers to '
        'the language name',
      );
    }

    if (config.format == null) {
      error(2, 'Parameter "format" is not defined in config file');
    }

    if (!kSimplelocalizeFormats.containsKey(config.format)) {
      error(
        2,
        'Unfortunately "${config.format}" format is not supported currently. '
        'Supported formats are: ${kSimplelocalizeFormats.keys}',
      );
    }
  }

  Future<void> readConfig(String file) async {
    final contents = await File(file).readAsString();
    final yaml = loadYaml(contents) as YamlMap;

    if (yaml.containsKey(kSimplelocalizeKey)) {
      final section =
          (yaml[kSimplelocalizeKey] as YamlMap).cast<String, dynamic>();
      config = SimplelocalizeConfig.fromMap(section);
      validateConfig();
      config.directory = path.join(path.dirname(file), config.directory);
      format = kSimplelocalizeFormats[config.format];
    } else {
      error(1, 'SimpleLocalize config not found in $file');
    }
  }

  Future<void> download() async {
    final result = await downloadTranslations(config.projectToken);

    for (var item in result.entries) {
      final file = File(path.join(
        config.directory,
        formatPattern(config.filename, [item.key]),
      ));
      stdout.writeln('Writing ${item.value.length} entries to ${file.path}');
      await file.writeAsString(format.convert(item.value));
    }
  }

  Future<void> publish({String apiKey}) async {
    apiKey ??= config.apiKey;

    if (apiKey == null) {
      error(
        1,
        'Publishing requires api-key to be provided either using pubspec.yaml '
        'or as an argument.',
      );
    }

    stdout.writeln('Publishing...');

    final result = await publishTranslations(apiKey);

    for (var item in result.data['failtures'] ?? []) {
      stderr.writeln(item.toString());
    }

    if (result.status == 200) {
      stdout.writeln('Published!');
    } else {
      stdout.writeln('Failed to publish! [${result.msg}]');
    }
  }

  Future<void> upload({String apiKey, bool publish = false}) async {
    apiKey ??= config.apiKey;

    if (apiKey == null) {
      error(
        1,
        'Uploading requires api-key to be provided either using pubspec.yaml '
        'or as an argument.',
      );
    }

    final files = await Directory(config.directory)
        .list(recursive: false, followLinks: false)
        .where((f) => f.statSync().type == FileSystemEntityType.file)
        .map((f) => File(f.path))
        .toList();

    final items = List<TranslationEntry>();

    for (var item in files) {
      final match = matchPattern(path.basename(item.path), config.filename);
      if (match == null) continue;
      final contents = await item.readAsString();
      final messages = format.parse(contents);

      messages.forEach(
        (key, value) => items.add(TranslationEntry(
          key: key,
          text: value,
          language: match.group(1),
        )),
      );
    }

    final result = await uploadTranslations(apiKey, items);

    for (var item in result.data['failtures'] ?? []) {
      stderr.writeln(item.toString());
    }

    if (result.status == 200) {
      stdout.writeln('Upload completed!');
      stdout.writeln();
      stdout.writeln('Updated: ${result.data['numberOfUpdates']}');
      stdout.writeln('Inserted: ${result.data['numberOfInserts']}');
    } else {
      stdout.writeln('Failed to upload! [${result.msg}]');
    }

    if (publish == true) {
      stdout.writeln();
      this.publish();
    }
  }

  void error(int code, String message) {
    stderr.writeln(message);
    exit(code);
  }
}

String formatPattern(String pattern, Iterable arguments) {
  var index = 1;
  var result = pattern;
  for (var item in arguments) {
    result = result.replaceAll('{$index}', item.toString());
    index++;
  }
  return result;
}

RegExpMatch matchPattern(String text, String pattern) {
  final re = pattern.replaceAll(RegExp(r'\{\d+\}'), '(.+)');
  return RegExp('^$re\$').firstMatch(text);
}
