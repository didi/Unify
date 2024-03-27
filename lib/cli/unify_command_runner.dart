import 'dart:async';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:unify/cli/commands/generate_api_command.dart';
import 'package:unify/utils/constants.dart';

import 'package:unify/utils/log.dart';
import 'package:unify/version.dart';

class UnifyCommandRunner extends CommandRunner<int> {
  UnifyCommandRunner() : super('unify', '') {
    argParser.addFlag('version',
        abbr: 'V',
        negatable: false,
        help: 'Display the version number of Unify.');
    addCommand(GenerateApiCommand());
  }

  @override
  String get invocation => 'dart run unify <command> [arguments]';

  @override
  Future<int> run(Iterable<String> args) async {
    try {
      final argResults = parse(args);
      return await runCommand(argResults) ?? 0;
    } on FormatException catch (e, stackTrace) {
      printf('err = ${e.message}, stackTrace = $stackTrace, info = $usage');
      return -1;
    } on UsageException catch (e) {
      printf('err = ${e.message}, info = ${e.usage}');
      return -1;
    }
  }

  @override
  Future<int?> runCommand(ArgResults topLevelResults) {
    final future = Future<int>.value(0);
    if (topLevelResults['help'] == true) {
      printUsage();
      return future;
    }

    if (topLevelResults['version'] == true) {
      printf('Unify $packageVersion • $gitUrl');
      return future;
    }

    return super.runCommand(topLevelResults);
  }

  @override
  void printUsage() => printf(usage);
}
