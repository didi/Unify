import 'package:unify_flutter/cli/cli.dart';
import 'package:unify_flutter/utils/log.dart';

Future<void> main(List<String> arguments) async {
  log('arguments', value: arguments);
  await cli(arguments);
}
