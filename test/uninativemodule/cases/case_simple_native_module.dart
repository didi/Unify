import 'package:unify/ast/basic/ast_string.dart';
import 'package:unify/ast/basic/ast_variable.dart';
import 'package:unify/ast/uniapi/ast_method.dart';
import 'package:unify/ast/uniapi/ast_module.dart';
import 'package:unify/generator/common.dart';

import '../../inputfile/mock_input_file.dart';

abstract class BaseUniNativeModuleCase {
  Module getModule();
  String getFlutterOutput();
}

/// 基本模块测试
class UniNativeModuleSimpleModule extends BaseUniNativeModuleCase {
  @override
  Module getModule() {
    return Module(
      mockInputFile('m.dart'),
      name: 'MyModule',
      methods: [
        Method(
            name: 'methodA',
            returnType: AstString(),
            parameters: [Variable(AstString(), 'param1')])
      ],
    );
  }

  @override
  String getFlutterOutput() {
    return flutterOutput;
  }
}

const flutterOutput = '''$generatedCodeWarning
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'uniapi/uni_api.dart';


class MyModule {

    static Future<String> methodA(String param1) async  {
        final Map<String, dynamic> encoded = {};
        encoded["param1"] = param1 as String;
        const BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?> (
            'com.didi.flutter.uni_api.MyModule.methodA', StandardMessageCodec());
        final Map<Object?, Object?>? replyMap =
            await channel.send(encoded) as Map<Object?, Object?>?;
        if (replyMap == null) {
            UniApi.trackError('MyModule', 'com.didi.flutter.uni_api.MyModule.methodA', 'Unable to establish connection on channel : "com.didi.flutter.uni_api.MyModule.methodA" .');
            if (!kReleaseMode) {
                throw PlatformException(
                    code: 'channel-error',
                    message: 'Unable to establish connection on channel : "com.didi.flutter.uni_api.MyModule.methodA" .',
                    details: null,
                );
            }
        } else if (replyMap['error'] != null) {
            final Map<Object?, Object?> error = (replyMap['error']  as Map<Object?, Object?>);
            String errorMsg = '';
            if (error.containsKey('code')) errorMsg += '[ \${error['code']?.toString() ?? ''} ]';
            if (error.containsKey('message')) errorMsg += '[ \${error['message']?.toString() ?? ''} ]';
            if (error.containsKey('details')) errorMsg += '[ \${error['details']?.toString() ?? ''} ]';
            UniApi.trackError('MyModule', 'com.didi.flutter.uni_api.MyModule.methodA', 'methodA: \$errorMsg);');
            if (!kReleaseMode) {
                throw PlatformException(
                    code: error['code'] as String,
                    message: error['message'] as String,
                    details: error['details'],
                );
            }
        } else {
            return replyMap['result'] as String;
        }
        throw Exception('方法 "methodA" : 返回类型错误!');
    }

}
''';
