/// Formatter definition for language files.
abstract class SimplelocalizeBaseFormat {
  /// Parses [contents] into key value map.
  Map<String, String> parse(String contents);

  /// Converts key value map into string.
  String convert(Map<String, String> translations);
}
