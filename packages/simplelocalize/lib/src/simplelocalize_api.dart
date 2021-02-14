import 'package:dio/dio.dart';

final _dio = Dio();

/// Downloads translations using given [projectKey] from SimpleLocalize.io using
/// [read translations](https://simplelocalize.io/docs/api/read-translations/)
/// API.
Future<Map<String, Map<String, String>>> downloadTranslations(
  String projectKey,
) async {
  ArgumentError.checkNotNull(projectKey, 'projectKey');

  final response = await _dio.get<Map<String, dynamic>>(
    'https://cdn.simplelocalize.io/$projectKey/_latest/_index',
    options: Options(
      responseType: ResponseType.json,
    ),
  );

  return response.data.map(
    (k, v) => MapEntry<String, Map<String, String>>(
      k,
      (v as Map).cast<String, String>(),
    ),
  );
}

/// Uploads given [translations] to SimpleLocalize.io using [update translations](https://simplelocalize.io/docs/api/update-translations/)
/// API.
Future<ServerResult> uploadTranslations(
  String apiKey,
  List<TranslationEntry> translations,
) async {
  ArgumentError.checkNotNull(apiKey, 'apiKey');
  ArgumentError.checkNotNull(translations, 'translations');

  final response = await _dio.patch<Map<String, dynamic>>(
    'https://api.simplelocalize.io/api/v1/translations',
    queryParameters: <String, dynamic>{
      'updateOptions': 'CREATE_KEY_IF_NOT_FOUND',
    },
    options: Options(
      contentType: 'application/json',
      headers: <String, dynamic>{'X-SimpleLocalize-Token': apiKey},
    ),
    data: <String, dynamic>{
      'content': translations.map((t) => t.toJson()).toList(),
    },
  );

  return ServerResult.fromJson(response.data);
}

/// Publish translations using [publish translations](https://simplelocalize.io/docs/api/publish-translations/)
/// API.
Future<ServerResult> publishTranslations(String apiKey) async {
  ArgumentError.checkNotNull(apiKey, 'apiKey');

  final response = await _dio.post<Map<String, dynamic>>(
    'https://api.simplelocalize.io/api/v1/translations/publish',
    options: Options(
      headers: <String, dynamic>{'X-SimpleLocalize-Token': apiKey},
    ),
  );

  return ServerResult.fromJson(response.data);
}

/// Translation entry
class TranslationEntry {
  String key;
  String language;
  String text;

  TranslationEntry({this.key, this.language, this.text});

  TranslationEntry.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    language = json['language'];
    text = json['text'];
  }

  Map<String, dynamic> toJson() {
    final data = new Map<String, dynamic>();
    data['key'] = this.key;
    data['language'] = this.language;
    data['text'] = this.text;
    return data;
  }
}

/// Result sent by the server
class ServerResult {
  String msg;
  int status;
  Map<String, dynamic> data;

  ServerResult({this.msg, this.status, this.data});

  ServerResult.fromJson(Map<String, dynamic> json) {
    msg = json['msg'];
    status = json['status'];
    data = json['data'] != null
        ? (json['data'] as Map).cast<String, dynamic>()
        : null;
  }

  Map<String, dynamic> toJson() {
    final data = Map<String, dynamic>();
    data['msg'] = this.msg;
    data['status'] = this.status;
    data['data'] = this.data;
    return data;
  }

  @override
  String toString() {
    final sb = StringBuffer();
    sb.writeln('$status $msg');
    data.forEach((key, value) {
      sb.write('$key: ');
      if (value is List) {
        for (var item in value) {
          sb.writeln();
          sb.write(item);
        }
        sb.writeln();
      } else {
        sb.writeln('$value');
      }
    });
    return sb.toString();
  }
}
