import 'package:unify/cli/cli.dart';
import 'package:unify/utils/log.dart';


Future<void> main(List<String> arguments) async {
  log('arguments', value: arguments);
  await cli(arguments);
}