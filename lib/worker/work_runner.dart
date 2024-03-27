import 'dart:io';

import 'package:unify/ast/uniapi/ast_model.dart';
import 'package:unify/ast/uniapi/ast_module.dart';
import 'package:unify/cli/options.dart';
import 'package:unify/generator/model.dart';
import 'package:unify/generator/module_flutter.dart';
import 'package:unify/generator/module_native.dart';
import 'package:unify/generator/uniapi.dart';
import 'package:unify/utils/constants.dart';

abstract class WorkRunner<T> {
  const WorkRunner({required this.module, required this.options});
  final T module;
  final UniAPIOptions options;
  void javaGenerator() {}
  void dartGenerator() {}
  void objcGenerator() {}
}

class UniModelWorkRunner extends WorkRunner<Model> {
  UniModelWorkRunner(Model module, UniAPIOptions options)
      : super(module: module, options: options);

  @override
  void javaGenerator() {
    final modelFile =
        File('${options.javaOutputPath}/${module.inputFile.javaPath()}');
    modelFile.createSync(recursive: true);
    modelFile.writeAsStringSync(ModelGenerator.javaCode(module, options));
  }

  @override
  void objcGenerator() {
    final modelHeaderFile =
        File('${options.objcOutput}/${module.inputFile.objcHeaderPath()}');
    modelHeaderFile.createSync(recursive: true);
    modelHeaderFile.writeAsStringSync(ModelGenerator.ocHeader(module, options));

    final modelSourceFile =
        File('${options.objcOutput}/${module.inputFile.objcSourcePath()}');
    modelSourceFile.createSync(recursive: true);
    modelSourceFile.writeAsStringSync(ModelGenerator.ocSource(module, options));
  }

  @override
  void dartGenerator() {
    final modelFile = File('${options.dartOutput}/${module.inputFile.path}');
    modelFile.createSync(recursive: true);
    modelFile.writeAsStringSync(ModelGenerator.dartCode(module, options));
  }
}

class UniFlutterModuleWorkRunner extends WorkRunner<Module> {
  UniFlutterModuleWorkRunner(Module module, UniAPIOptions options)
      : super(module: module, options: options);

  @override
  void dartGenerator() {
    final file = File('${options.dartOutput}/${module.inputFile.path}');
    file.createSync(recursive: true);
    file.writeAsStringSync(FlutterModuleGenerator.dartCode(module, options));
  }

  @override
  void javaGenerator() {
    final file =
        File('${options.javaOutputPath}/${module.inputFile.javaPath()}');
    file.createSync(recursive: true);
    file.writeAsStringSync(FlutterModuleGenerator.javaCode(module, options));
  }

  @override
  void objcGenerator() {
    final nativeHeaderFile =
        File('${options.objcOutput}/${module.inputFile.objcHeaderPath()}');
    nativeHeaderFile.createSync(recursive: true);
    nativeHeaderFile
        .writeAsStringSync(FlutterModuleGenerator.ocHeader(module, options));

    final nativeSourceFile =
        File('${options.objcOutput}/${module.inputFile.objcSourcePath()}');
    nativeSourceFile.createSync(recursive: true);
    nativeSourceFile
        .writeAsStringSync(FlutterModuleGenerator.ocSource(module, options));
  }
}

class UniNativeModuleWorkRunner extends WorkRunner<Module> {
  UniNativeModuleWorkRunner(Module module, UniAPIOptions options)
      : super(module: module, options: options);

  @override
  void dartGenerator() {
    final file = File('${options.dartOutput}/${module.inputFile.path}');
    file.createSync(recursive: true);
    file.writeAsStringSync(ModuleGenerator.dartCode(module, options));
  }

  @override
  void javaGenerator() {
    final file =
        File('${options.javaOutputPath}/${module.inputFile.javaPath()}');
    file.createSync(recursive: true);
    file.writeAsStringSync(ModuleGenerator.javaCode(module, options));

    final fileRegister = File(
        '${options.javaOutputPath}/${module.inputFile.javaNativeRegisterPath()}');
    fileRegister.createSync(recursive: true);
    fileRegister
        .writeAsStringSync(ModuleGenerator.javaRegisterCode(module, options));
  }

  @override
  void objcGenerator() {
    final nativeHeaderFile =
        File('${options.objcOutput}/${module.inputFile.objcHeaderPath()}');
    nativeHeaderFile.createSync(recursive: true);
    nativeHeaderFile
        .writeAsStringSync(ModuleGenerator.ocHeader(module, options));

    final nativeSourceFile =
        File('${options.objcOutput}/${module.inputFile.objcSourcePath()}');
    nativeSourceFile.createSync(recursive: true);
    nativeSourceFile
        .writeAsStringSync(ModuleGenerator.ocSource(module, options));
  }
}

class UniAPIWorkRunner {
  UniAPIWorkRunner({required this.options, this.models});

  UniAPIOptions options;
  List<Model>? models;

  void dartGenerator() {
    final uniApiCallbackManagerFile = File(
        '${options.dartOutput}/$projectName/$dotDartFileUniCallbackManager');
    uniApiCallbackManagerFile.createSync(recursive: true);
    uniApiCallbackManagerFile.writeAsStringSync(
        ModuleGenerator.dartCallbackManagerCode(options, models: models));
  }

  void javaGenerator() {
    final uniAPIJavaFile = File(
        '${options.javaOutputPath}/${UniApiGenerator.genJavaFileName(options)}');
    uniAPIJavaFile.createSync(recursive: true);
    uniAPIJavaFile.writeAsStringSync(UniApiGenerator.javaCode(options));
  }

  void objcGenerator() {
    final uniAPIHeaderFile = File(
        '${options.objcOutput}/${UniApiGenerator.genObjcHeaderFileName(options)}');
    uniAPIHeaderFile.createSync(recursive: true);
    uniAPIHeaderFile.writeAsStringSync(UniApiGenerator.ocHeaderCode(options));

    final uniAPISourceFile = File(
        '${options.objcOutput}/${UniApiGenerator.genObjcSourceFileName(options)}');
    uniAPISourceFile.createSync(recursive: true);
    uniAPISourceFile.writeAsStringSync(UniApiGenerator.ocSourceCode(options));
  }
}
