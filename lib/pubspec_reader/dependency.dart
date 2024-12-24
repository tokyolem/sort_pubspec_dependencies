/// Data model for recording a dependency and its additional rows.
///
/// Params:
///
/// [dependencyName] - field stores the name and version of the dependency
/// in string representation.
///
/// [dependencyAdditionalLines] - field stores all additional
/// dependency strings.
///
/// Example:
/// ```yaml
/// dependencies:
///   http: #[dependencyName]
///     git: #                      |
///       url: https://example.com #↓
///       ref: main #               [dependencyAdditionalLines]
/// ```
final class Dependency {
  final String dependencyName;
  final List<String> dependencyAdditionalLines;

  const Dependency({
    required this.dependencyName,
    required this.dependencyAdditionalLines,
  });

  Dependency copyWith({
    List<String>? dependencyAdditionalLines,
  }) {
    return Dependency(
      dependencyName: dependencyName,
      dependencyAdditionalLines:
          dependencyAdditionalLines ?? this.dependencyAdditionalLines,
    );
  }

  @override
  String toString() {
    return '''
_Dependency:
  dependencyName: $dependencyName    
  dependencyAdditionalLines: $dependencyAdditionalLines
    ''';
  }
}
