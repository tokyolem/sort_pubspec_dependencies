import 'dart:io';

/// An abstract final class that provides utility methods for running system
/// processes.
abstract final class ProcessRunner {
  /// Runs the `flutter pub get` command to fetch and resolve dependencies
  /// for a Flutter project.
  ///
  /// This method starts a system process to execute the `flutter pub get` command.
  /// The process streams its standard output and error output to the terminal
  /// in real time.
  ///
  /// Returns a [Future] that resolves to `true` if the command completes
  /// successfully with an exit code of 0, or `false` if the command fails with
  /// a non-zero exit code.
  static Future<bool> runPubGet() async {
    final process = await Process.start(
      'flutter',
      ['pub', 'get'],
      runInShell: true,
    );

    process.stdout.transform(SystemEncoding().decoder).listen(stdout.write);
    process.stderr.transform(SystemEncoding().decoder).listen(stderr.write);

    final exitCode = await process.exitCode;

    return exitCode == 0;
  }
}
