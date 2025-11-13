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
/// [leadingComments] - field stores comment lines that appear before
/// the dependency.
///
/// Example:
/// ```yaml
/// dependencies:
///   # This is a comment [leadingComments]
///   http: #[dependencyName]
///     git: #                      |
///       url: https://example.com #↓
///       ref: main #               [dependencyAdditionalLines]
/// ```
final class Dependency {
  final String dependencyName;
  final List<String> dependencyAdditionalLines;
  final List<String> leadingComments;

  const Dependency({
    required this.dependencyName,
    required this.dependencyAdditionalLines,
    this.leadingComments = const [],
  });

  Dependency copyWith({
    List<String>? dependencyAdditionalLines,
    List<String>? leadingComments,
  }) {
    return Dependency(
      dependencyName: dependencyName,
      dependencyAdditionalLines:
          dependencyAdditionalLines ?? this.dependencyAdditionalLines,
      leadingComments: leadingComments ?? this.leadingComments,
    );
  }

  @override
  String toString() {
    return '''
_Dependency:
  dependencyName: $dependencyName
  dependencyAdditionalLines: $dependencyAdditionalLines
  leadingComments: $leadingComments
    ''';
  }
}
