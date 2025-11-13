import 'dart:io';

import 'package:sort_pubspec_dependencies/pubspec_reader/dependency.dart';

/// Helper class responsible for reading and sorting pubspec.yaml.
final class PubspecReader {
  /// Writes a sorted version of the `pubspec.yaml` file to the disk.
  ///
  /// This method reads the `pubspec.yaml` file, sorts the dependencies
  /// and dev_dependencies sections alphabetically, and then overwrites
  /// the file with the updated content.
  ///
  /// If the `pubspec.yaml` file is not found, an error message is displayed
  /// with possible solutions to resolve the issue.
  ///
  /// [pubspecPath] (optional) - The path to the `pubspec.yaml` file. If
  /// not provided, the method assumes the file is located in the main
  /// project directory.
  ///
  /// Throws:
  /// - [FileSystemException] if the `pubspec.yaml` file is not found.
  ///
  /// Example:
  /// ```dart
  /// writeSortedPubspec(); // Sorts pubspec.yaml in the current directory.
  /// writeSortedPubspec('path/to/pubspec.yaml'); // Sorts a specific pubspec.yaml file.
  /// ```
  void writeSortedPubspec([String? pubspecPath]) {
    try {
      final pubspecFile = File(pubspecPath ?? 'pubspec.yaml');

      if (!pubspecFile.existsSync()) {
        throw FileSystemException(
          '''
Error:
  pubspec.yaml not found.

  Solutions:
  - Check the presence of pubspec.yaml in the main project directory
  - Explicitly specify the path to your pubspec.yaml through the config (pubspec_path)
          ''',
        );
      }

      final sortedPubspecContent = _sortPubspec(pubspecFile);

      pubspecFile.writeAsStringSync(sortedPubspecContent);
    } on Object catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  /// Sorts the dependencies in the `pubspec.yaml` file.
  ///
  /// This method processes the `pubspec.yaml` file to extract the
  /// `dependencies` and `dev_dependencies` sections, sorts each
  /// alphabetically, and returns the updated content.
  ///
  /// [pubspecFile] - The file object representing the `pubspec.yaml` file.
  ///
  /// Returns:
  /// - A string containing the sorted `pubspec.yaml` content.
  ///
  /// Throws:
  /// - Any exception encountered during file reading or processing will
  ///   be rethrown.
  String _sortPubspec(File pubspecFile) {
    try {
      final dependenciesSectionRegExp = RegExp(r'^\s*dependencies\s*:$');
      final devDependenciesSectionRegExp = RegExp(r'^\s*dev_dependencies\s*:$');
      final dependenciesOverrideSectionRegExp =
          RegExp(r'^\s*dependency_overrides\s*:$');

      final pubspecLines = pubspecFile.readAsLinesSync();

      final dependencies = _extractDependencies(
        pubspecLines,
        dependenciesSectionRegExp,
      );
      final devDependencies = _extractDependencies(
        pubspecLines,
        devDependenciesSectionRegExp,
      );
      final dependenciesOverride = _extractDependencies(
        pubspecLines,
        dependenciesOverrideSectionRegExp,
      );

      final replacedDependenciesLines = _replaceDependencies(
        pubspecLines,
        dependencies,
        dependenciesSectionRegExp,
      );
      final replacedDevDependencies = _replaceDependencies(
        replacedDependenciesLines,
        devDependencies,
        devDependenciesSectionRegExp,
      );
      final replacedDependenciesOverride = _replaceDependencies(
        replacedDevDependencies,
        dependenciesOverride,
        dependenciesOverrideSectionRegExp,
      );

      return '${replacedDependenciesOverride.join('\n').trim()}\n';
    } on Object catch (_) {
      rethrow;
    }
  }

  /// Dependency separation method.
  ///
  /// The method generates, sorts and returns a [Dependency] array with possible
  /// additional rows.
  ///
  /// Params:
  ///
  /// [lines] - pubspec.yaml as separate lines.
  ///
  /// [sectionRegex] - regular expression, reflects the key of the shared
  /// section without taking into account possible spaces between and after :
  List<Dependency> _extractDependencies(
    List<String> lines,
    RegExp sectionRegex,
  ) {
    final dependencies = <Dependency>[];
    var inSection = false;

    for (var index = 0; index < lines.length; index++) {
      final line = lines[index];

      if (sectionRegex.hasMatch(line)) {
        inSection = true;
        continue;
      }

      if (inSection && line.isNotEmpty && !line.startsWith(' ')) {
        inSection = false;
        break;
      }

      if (line.trim().isEmpty || line.trim().startsWith('#')) continue;

      if (inSection && line.isNotEmpty && !line.startsWith('    ')) {
        final leadingComments = <String>[];
        for (var commentIndex = index - 1; commentIndex >= 0; commentIndex--) {
          final commentLine = lines[commentIndex];
          if (!commentLine.trim().startsWith('#')) break;
          leadingComments.insert(0, commentLine);
        }

        var mainDependency = Dependency(
          dependencyName: line,
          dependencyAdditionalLines: const [],
          leadingComments: leadingComments,
        );

        for (var additionalIndex = index + 1;
            additionalIndex < lines.length;
            additionalIndex++) {
          final additionalLine = lines[additionalIndex];

          if (additionalLine.isNotEmpty && !additionalLine.startsWith('    ')) {
            break;
          }

          if (additionalLine.isNotEmpty) {
            mainDependency = mainDependency.copyWith(
              dependencyAdditionalLines: [
                ...mainDependency.dependencyAdditionalLines,
                additionalLine,
              ],
            );
          }
        }

        dependencies.add(mainDependency);
      }
    }

    final regExp = RegExp(r':.*$');
    dependencies.sort(
      (cmp1, cmp2) {
        return cmp1.dependencyName.replaceAll(regExp, '').trim().compareTo(
              cmp2.dependencyName.replaceAll(regExp, '').trim(),
            );
      },
    );

    return dependencies;
  }

  /// The method replaces the unsorted dependency section with a sorted one
  /// and returns pubspec.yaml as separate lines.
  ///
  /// Params:
  ///
  /// [lines] - pubspec.yaml as separate lines.
  ///
  /// [sortedDependencies] - array of sorted [Dependency] of a specific section
  ///
  /// [sectionRegex] - regular expression, reflects the key of the shared
  /// section without taking into account possible spaces between and after :
  List<String> _replaceDependencies(
    List<String> lines,
    List<Dependency> sortedDependencies,
    RegExp sectionRegex,
  ) {
    final copyLines = [...lines];
    final indicesToRemove = <int>[];
    var inSection = false;
    var startSectionIndex = 0;

    for (var index = 0; index < lines.length; index++) {
      final line = lines[index];

      if (sectionRegex.hasMatch(line)) {
        inSection = true;
        startSectionIndex = index + 1;
        continue;
      }

      if (inSection && line.isNotEmpty && !line.startsWith(' ')) {
        inSection = false;
        break;
      }

      if (inSection) {
        indicesToRemove.add(index);
      }
    }

    for (var index in indicesToRemove.reversed) {
      copyLines.removeAt(index);
    }

    copyLines.insert(startSectionIndex, '');

    for (final dependency in sortedDependencies.reversed) {
      for (final additionalLine
          in dependency.dependencyAdditionalLines.reversed) {
        copyLines.insert(startSectionIndex, additionalLine);
      }

      copyLines.insert(startSectionIndex, dependency.dependencyName);
      for (final comment in dependency.leadingComments.reversed) {
        copyLines.insert(startSectionIndex, comment);
      }
    }

    return copyLines;
  }
}
