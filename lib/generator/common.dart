import 'package:unify/ast/uniapi/ast_method.dart';
import 'package:unify/ast/uniapi/ast_module.dart';
import 'package:unify/utils/constants.dart';

const String generatedCodeWarning = generatedWarning;

const String generatedClassWarning = generatedWarning;

const String generatedInterfaceWarning = generatedWarning;

const String channelPrefix = 'com.didi.flutter.uni_api';

/// Create the generated channel name for a [func] on a [api].
String makeChannelName(Module module, Method func) =>
    '$channelPrefix.${module.name}.${func.name}';
