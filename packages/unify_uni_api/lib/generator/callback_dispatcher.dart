import 'package:unify_flutter/cli/options.dart';
import 'package:unify_flutter/generator/widgets/base/comment.dart';
import 'package:unify_flutter/generator/widgets/base/line.dart';
import 'package:unify_flutter/generator/widgets/code_template.dart';
import 'package:unify_flutter/generator/widgets/lang/java/java_package.dart';
import 'package:unify_flutter/generator/widgets/lang/oc/oc_import.dart';
import 'package:unify_flutter/utils/constants.dart';
import 'package:unify_flutter/utils/extension/string_extension.dart';
import 'package:unify_flutter/utils/template_internal/dart/uni_callback_dispatcher.dart';

abstract class CallbackDispatcherGenerator {
  static String className(UniAPIOptions options) =>
      '${options.objcUniAPIPrefix}$typeCallbackDispatcher';
  static String disposeProtocolName(UniAPIOptions options) =>
      '${options.objcUniAPIPrefix}$typeUniCallbackDispose';

  static String genOcHeaderFileName(UniAPIOptions options) {
    return '${className(options)}.h';
  }

  static String genOcSourceFileName(UniAPIOptions options) {
    return '${className(options)}.m';
  }

  static String genJavaDispatcherFileName(UniAPIOptions options) {
    return '${className(options)}$javaSuffix';
  }

  static String genJavaCallbackFileName(UniAPIOptions options) {
    return '${options.objcUniAPIPrefix}$typeUniCallback$javaSuffix';
  }

  static String genJavaCallbackDisposeFileName(UniAPIOptions options) {
    return '${disposeProtocolName(options)}$javaSuffix';
  }

  static String ocHeaderCode(UniAPIOptions options) {
    return CodeTemplate(children: [
      CommentUniAPI(),
      EmptyLine(),
      OCImport(fullImportName: 'Foundation/Foundation.h'),
      OCImport(fullImportName: 'Flutter/Flutter.h'),
      OneLine(body: 'NS_ASSUME_NONNULL_BEGIN'),
      EmptyLine(),
      OneLine(body: '@protocol ${disposeProtocolName(options)}'),
      OneLine(body: '@required'),
      OneLine(body: '- (void)disposeCallback:(id)params;'),
      OneLine(body: '@end'),
      EmptyLine(),
      OneLine(body: '@interface ${className(options)} : NSObject'),
      OneLine(
          body:
              '+ (void)init:(NSObject<FlutterBinaryMessenger>* _Nonnull)binaryMessenger;'),
      OneLine(
          body:
              '+ (void)registe:(NSString * _Nonnull)name callback:(id _Nonnull)subscriber;'),
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
          fullImportName: genOcHeaderFileName(options),
          importType: ocImportTypeLocal),
      OneLine(body: objcPrivateStaticUniDispatchCache),
      EmptyLine(),
      OneLine(body: '@implementation ${className(options)}'),
      EmptyLine(),
      OneLine(body: objcDispatcherClassMethed(options.objcUniAPIPrefix.suffix())),
      OneLine(body: '@end')
    ]).build();
  }

  static String javaDispatcherCode(UniAPIOptions options) {
    return CodeTemplate(children: [
      CommentUniAPI(),
      EmptyLine(),
      JavaPackage(null, options),
      EmptyLine(),
      OneLine(body: javaDispatcherClassContent(options.objcUniAPIPrefix)),
    ]).build();
  }

  static String javaCallbackCode(UniAPIOptions options) {
    return CodeTemplate(children: [
      CommentUniAPI(),
      EmptyLine(),
      JavaPackage(null, options),
      EmptyLine(),
      OneLine(body: javaUniCallbackContent(options.objcUniAPIPrefix)),
    ]).build();
  }

  static String javaCallbackDisposeCode(UniAPIOptions options) {
    return CodeTemplate(children: [
      CommentUniAPI(),
      EmptyLine(),
      JavaPackage(null, options),
      EmptyLine(),
      OneLine(body: javaUniCallbackDisposeContent(options.objcUniAPIPrefix)),
    ]).build();
  }
}
