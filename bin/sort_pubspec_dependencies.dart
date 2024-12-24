import 'package:sort_pubspec_dependencies/config_mapper.dart';
import 'package:sort_pubspec_dependencies/process_runner.dart';
import 'package:sort_pubspec_dependencies/pubspec_reader/pubspec_reader.dart';

const _withRunPubGetArg = '--with-run-pub-get';

/// Sort script input function.
Future<void> main(List<String> args) async {
  try {
    final runArgs = takeRunArguments(args);

    final config = ConfigMapper().fetchConfig();

    final pubspecPath =
        runArgs.pubspecPath ?? config?['pubspecPath']?.toString();
    final needRunPubGet = runArgs.withRunPubGet ||
        (config?['needRunPugGetAfterSorting'] as bool? ?? false);

    PubspecReader().writeSortedPubspec(pubspecPath);

    if (needRunPubGet) await ProcessRunner.runPubGet();

    print('''
      
Dependencies successfully sorted!
      ''');
  } on Object catch (e) {
    print(e);
  }
}

({String? pubspecPath, bool withRunPubGet}) takeRunArguments(
  List<String> args,
) {
  final pubspecPathRegExp = RegExp(r'--(pubspec-path|p)=(.+)');

  String? pubspecPath;

  for (final arg in args) {
    final match = pubspecPathRegExp.firstMatch(arg);
    if (match != null) {
      pubspecPath = match.group(2);
      break;
    }
  }

  return (
    pubspecPath: pubspecPath,
    withRunPubGet: args.contains(_withRunPubGetArg),
  );
}
