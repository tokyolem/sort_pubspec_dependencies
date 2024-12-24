import 'package:sort_pubspec_dependencies/config_mapper.dart';
import 'package:sort_pubspec_dependencies/process_runner.dart';
import 'package:sort_pubspec_dependencies/pubspec_reader/pubspec_reader.dart';

/// Sort script input function.
Future<void> main() async {
  try {
    final config = ConfigMapper().fetchConfig();

    final pubspecPath = config?['pubspecPath']?.toString();
    final needRunPubGet =
        config?['needRunPugGetAfterSorting'] as bool? ?? false;

    PubspecReader().writeSortedPubspec(pubspecPath);

    if (needRunPubGet) await ProcessRunner.runPubGet();
  } on Object catch (e) {
    print(e);
  }
}
