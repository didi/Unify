import 'package:unify_flutter/cli/options.dart';
import 'package:unify_flutter/generator/callback_dispatcher.dart';
import 'package:unify_flutter/generator/widgets/base/comment.dart';
import 'package:unify_flutter/generator/widgets/base/line.dart';
import 'package:unify_flutter/generator/widgets/code_template.dart';
import 'package:unify_flutter/generator/widgets/lang/java/java_import.dart';
import 'package:unify_flutter/generator/widgets/lang/java/java_package.dart';
import 'package:unify_flutter/generator/widgets/lang/oc/oc_import.dart';
import 'package:unify_flutter/utils/constants.dart';
import 'package:unify_flutter/utils/template_internal/java/uni_class_methods.dart';
import 'package:unify_flutter/utils/template_internal/objc/uni_class_methods.dart';
import 'package:unify_flutter/utils/template_internal/objc/uni_static_function.dart';

abstract class UniApiGenerator {
  static String genObjcHeaderFileName(UniAPIOptions options) {
    return '${_genObjcClassName(options)}.h';
  }

  static String genObjcSourceFileName(UniAPIOptions options) {
    return '${_genObjcClassName(options)}.m';
  }

  static String _genObjcClassName(UniAPIOptions options) {
    return '${options.objcUniAPIPrefix}$kUniAPI';
  }

  static String _genSectname(UniAPIOptions options) {
    if (options.objcUniAPIPrefix.isNotEmpty) {
      return '${options.objcUniAPIPrefix.toLowerCase()}_$projectNameSnake';
    }
    return projectNameSnake;
  }

  static String _genCallbackDispatcherClassName(UniAPIOptions options) {
    return CallbackDispatcherGenerator.className(options);
  }

  static String ocHeaderCode(UniAPIOptions options) {
    return CodeTemplate(children: [
      CommentUniAPI(),
      EmptyLine(),
      OCImport(fullImportName: 'Foundation/Foundation.h'),
      OCImport(fullImportName: 'Flutter/Flutter.h'),
      OneLine(body: 'NS_ASSUME_NONNULL_BEGIN'),
      EmptyLine(),
      OneLine(body: '#ifndef UNI_EXPORT'),
      OneLine(body: r'#define UNI_EXPORT(className) \'),
      OneLine(
          body:
              '__attribute__((used, section("__DATA , ${_genSectname(options)}"))) '
              r'\'),
      OneLine(
          body:
              'static char *__uni_export_class_##className##__ = ""#className"";'),
      OneLine(body: '#endif'),
      EmptyLine(),
      OneLine(body: '@interface ${_genObjcClassName(options)} : NSObject'),
      EmptyLine(),
      OneLine(body: '/// 初始化'),
      OneLine(
          body:
              '+ (void)init:(NSObject<FlutterBinaryMessenger>* _Nonnull)binaryMessenger;'),
      EmptyLine(),
      OneLine(body: '/// 加载导出类'),
      OneLine(body: '+ (void)loadExportClass;'),
      EmptyLine(),
      OneLine(body: '/// 获取协议的遵守者'),
      OneLine(body: '+ (id)get:(NSString *)className;'),
      EmptyLine(),
      OneLine(body: '@end'),
      EmptyLine(),
      OneLine(body: 'NS_ASSUME_NONNULL_END'),
    ]).build();
  }

  static String ocSourceCode(UniAPIOptions options) {
    return CodeTemplate(children: [
      CommentUniAPI(),
      EmptyLine(),
      OCImport(
          fullImportName: genObjcHeaderFileName(options),
          importType: ocImportTypeLocal),
      OCImport(fullImportName: 'dlfcn.h'),
      OCImport(fullImportName: 'mach-o/getsect.h'),
      OCImport(
          fullImportName:
              '${CallbackDispatcherGenerator.genOcHeaderFileName(options)}',
          importType: ocImportTypeLocal),
      OneLine(body: objcUniApiPrivateStaticFounction),
      EmptyLine(),
      OneLine(body: '@implementation ${_genObjcClassName(options)}'),
      EmptyLine(),
      OneLine(body: objcUniApiClassMethods(_genSectname(options), _genCallbackDispatcherClassName(options))),
      OneLine(body: '@end')
    ]).build();
  }

  static String genJavaFileName(UniAPIOptions options) {
    return '${_genJavaClassName(options)}$javaSuffix';
  }

  static String _genJavaClassName(UniAPIOptions options) {
    return '${options.javaUniAPIPrefix}$kUniAPI';
  }

  static String javaCode(UniAPIOptions options) {
    return CodeTemplate(children: [
      CommentUniAPI(),
      EmptyLine(),
      JavaPackage(null, options),
      EmptyLine(),
      JavaImport(fullClassName: 'java.util.HashMap'),
      JavaImport(fullClassName: 'java.util.Map'),
      EmptyLine(),
      OneLine(body: 'public class ${_genJavaClassName(options)} {'),
      OneLine(body: javaUniApiClassMethods(options)),
      OneLine(body: '}')
    ]).build();
  }
}
