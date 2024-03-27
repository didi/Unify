import 'dart:async';
import 'dart:io';

import 'package:unify/cli/unify_command_runner.dart';

Future<void> cli(List<String> args) async {
  await _runAndExit(await UnifyCommandRunner().run(args));
}

Future<void> _runAndExit(int status) {
  return Future.wait<void>([stdout.close(), stderr.close()])
      .then<void>((_) => exit(status));
}
