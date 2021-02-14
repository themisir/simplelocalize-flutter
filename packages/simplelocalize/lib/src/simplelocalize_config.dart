class SimplelocalizeConfig {
  SimplelocalizeConfig({
    this.projectToken,
    this.directory,
    this.format,
    this.filename,
    this.apiKey,
  });

  SimplelocalizeConfig.fromMap(Map<String, dynamic> map)
      : projectToken = (map['project_token'] ??
            map['project-token'] ??
            map['projectToken']) as String,
        directory = map['directory'] as String,
        format = map['format'] as String,
        filename = map['filename'] as String,
        apiKey = (map['api_key'] ?? map['api-key'] ?? map['apiKey']) as String;

  String projectToken;
  String directory;
  String format;
  String filename;
  String apiKey;
}
