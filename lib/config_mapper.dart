import 'dart:io';

/// A utility class for mapping configuration lines from a YAML file into a key-value map.
///
/// This class is designed to process configuration data from the `sort_dependencies.yaml` file,
/// providing a structured map of configuration entries for further use.
final class ConfigMapper {
  /// Fetches and maps configuration data from the `sort_dependencies.yaml` file.
  ///
  /// Reads the configuration file line by line and converts valid entries into a map.
  /// Each line should follow the format `key: value`. Lines with invalid or missing keys
  /// are ignored.
  ///
  /// - Returns a [Map] of configuration entries where the keys are [String] and the values
  ///   are either [bool] (if the value can be parsed as a boolean) or [String].
  /// - Returns `null` if the configuration file cannot be read or contains no valid entries.
  Map<String, Object>? fetchConfig() {
    final configLines = _fetchConfigLines();
    if (configLines == null || configLines.isEmpty) return null;

    final mappedConfigEntries = configLines.map(
      (line) {
        final entry = _mapLineToEntry(line);

        return entry ?? MapEntry('', '');
      },
    ).toList()
      ..removeWhere((e) => e.key.isEmpty);

    return Map.fromEntries(mappedConfigEntries);
  }

  /// Maps a single configuration line into a [MapEntry].
  ///
  /// Splits the given configuration line at the first colon (`:`) and trims any surrounding
  /// whitespace. If the value is wrapped in quotes (`'` or `"`), they are removed. Additionally,
  /// attempts to parse the value as a [bool] (e.g., `true` or `false`) before defaulting to
  /// treating it as a [String].
  ///
  /// - Returns a [MapEntry] with the parsed key-value pair if the line is valid.
  /// - Returns `null` if the line does not contain a valid key-value pair.
  MapEntry<String, Object>? _mapLineToEntry(String line) {
    final splitLine = line.split(':');

    if (splitLine.length < 2) return null;

    final quotesRemoveExp = RegExp('[\'"]');
    final quotesRemovedValue =
        splitLine[1].replaceAll(quotesRemoveExp, '').trim();

    final entryValue = bool.tryParse(quotesRemovedValue) ?? quotesRemovedValue;

    return MapEntry(splitLine.first.trim(), entryValue);
  }

  /// Fetches all lines from the `sort_dependencies.yaml` file.
  ///
  /// Reads the `sort_dependencies.yaml` file from the current working directory
  /// and returns its content as a list of strings. If the file does not exist or
  /// an error occurs during reading, an error message is printed, and `null` is returned.
  ///
  /// - Returns a [List] of strings containing the lines from the configuration file.
  /// - Returns `null` if the file does not exist or cannot be read.
  List<String>? _fetchConfigLines() {
    try {
      final configFile = File('sort_dependencies.yaml');

      if (!configFile.existsSync()) throw FileSystemException();

      return configFile.readAsLinesSync();
    } on Object catch (_) {
      print("sort_dependencies.yaml does not exists");

      return null;
    }
  }
}
