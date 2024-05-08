import 'package:unify/ast/base.dart';
import 'package:unify/ast/basic/ast_custom.dart';
import 'package:unify/ast/basic/ast_int.dart';
import 'package:unify/ast/basic/ast_list.dart';
import 'package:unify/ast/basic/ast_map.dart';
import 'package:unify/ast/basic/ast_void.dart';
import 'package:unify/cli/options.dart';
import 'package:unify/utils/constants.dart';
import 'package:unify/utils/utils.dart';

const _funcPlaceholder = '@@function@@';
const _valuePlaceholder = '@@value@@';
const _replyPlaceholder = "replyMap['${Keys.result}']";

String get replyPlaceholder => _replyPlaceholder;

extension AstTypeExtension on AstType {
  List<AstCustomType> recursiveCustomType() {
    final astTypes = <AstCustomType>[];
    if (this is AstList || this is AstMap || astType() == typeUniCallback) {
      for (final element in generics) {
        final tmp = element.recursiveCustomType();
        astTypes.addAll(tmp);
      }
    }

    if (this is AstCustomType) {
      astTypes.add(this as AstCustomType);
    }
    return astTypes;
  }

  bool containsCustomType() => recursiveCustomType().isNotEmpty;

  String _customReturnStyle(AstType type) =>
      '${type.realType().astType()}.decode($_valuePlaceholder)';
  String _defaultReturnStyle(AstType type) =>
      '$_valuePlaceholder as ${type.realType().dartType(showGenerics: true)}';

  void _recursiveAstType(AstType type, List<String> results) {
    const listReturnStyle =
        '($_valuePlaceholder as List).map(($_valuePlaceholder) => $_funcPlaceholder).toList()';
    const mapReturnStyle =
        '($_valuePlaceholder as Map).map((key, $_valuePlaceholder) => MapEntry(key as String, $_funcPlaceholder))';
    const voidReturnStyle = '// noop';

    if (type.realType() is AstList) {
      results.add(listReturnStyle);
      for (final element in type.generics) {
        _recursiveAstType(element, results);
      }
    } else if (type.realType() is AstMap) {
      results.add(mapReturnStyle);
      final m = type.realType() as AstMap;
      _recursiveAstType(m.valueType.realType(), results);
    } else if (type.realType() is AstCustomType) {
      results.add(_customReturnStyle(type));
    } else if (type.realType() is AstVoid) {
      results.add(voidReturnStyle);
    } else {
      results.add(_defaultReturnStyle(type));
    }
  }

  void _recursiveCollectGenerics(AstType type, List<String> results,
      {bool isJava = false}) {
    if (type.realType() is AstList) {
      isJava == false
          ? results.add(type.realType().ocType())
          : results.add(type.realType().astType());
      for (final element in type.generics) {
        _recursiveCollectGenerics(element, results, isJava: isJava);
      }
    } else if (type.realType() is AstMap) {
      isJava == false
          ? results.add(type.realType().ocType())
          : results.add(type.realType().astType());
      final m = type.realType() as AstMap;
      _recursiveCollectGenerics(m.valueType.realType(), results,
          isJava: isJava);
    } else if (type.realType() is AstCustomType) {
      isJava == false
          ? results.add(type.realType().ocType())
          : results.add(type.realType().astType());
    }
  }

  String? convertDartJson2Obj({String vname = _replyPlaceholder}) {
    var funcStr = '';
    final funcBodys = <String>[];

    _recursiveAstType(this, funcBodys);

    final length = funcBodys.length;
    if (length > 1) {
      for (var j = length - 1; j > 0; j--) {
        if (funcBodys[j - 1].contains(_funcPlaceholder)) {
          funcStr = funcBodys[j - 1].replaceAll(_funcPlaceholder, funcBodys[j]);
          funcBodys[j - 1] = funcStr;
        }
      }
    } else if (length == 1) {
      funcStr = funcBodys.first;
    }

    if (funcStr.isNotEmpty) {
      if (kEnableNullSafety == true &&
          funcStr.endsWith('.decode($_valuePlaceholder)')) {
        funcStr = funcStr.replaceAll(_valuePlaceholder, '$_valuePlaceholder!');
      }
      funcStr = funcStr.replaceFirst(_valuePlaceholder, vname);
      funcStr = funcStr.replaceAll(_valuePlaceholder, 'value');
    }
    return funcStr;
  }

  String convertDartObj2Json(String valueName) {
    if (containsCustomType() == true) {
      if (realType() is AstMap) {
        return '${Keys.mapClone}($valueName)';
      } else if (realType() is AstList) {
        return '${Keys.listClone}($valueName)';
      }
    }

    return unpackArgAST(realType(), valueName);
  }

  String convertJavaJson2Obj(
      {String vname = '[message objectForKey:@"data"]',
      bool hasDefaultValue = true,
      bool showGenerics = false}) {
    if (containsCustomType() == false) {
      if (realType() is AstInt) {
        return '((Number) $vname).longValue()${hasDefaultValue == true ? ' : 0' : ''}';
      } else if (realType() is AstVoid) {
        return 'null';
      } else {
        return '(${realType().javaType(showGenerics: showGenerics)}) $vname${hasDefaultValue == true ? ' : ${realType().javaDefault()}' : ''}';
      }
    }

    final generics = <String>[];
    _recursiveCollectGenerics(this, generics, isJava: true);

    final javaGenerics = generics.map((e) => '"$e"').toList().join(',');
    if (realType() is AstList) {
      return '${Keys.listConvert}((List)$vname,  new String[]{$javaGenerics}, 1) ${hasDefaultValue == true ? ': new ArrayList<>()' : ''}';
    } else if (realType() is AstMap) {
      return '${Keys.mapConvert}((Map)$vname,  new String[]{$javaGenerics}, 1) ${hasDefaultValue == true ? ': new HashMap<>()' : ''}';
    } else if (realType() is AstCustomType) {
      return '${realType().javaType()}.fromMap((Map) $vname) ${hasDefaultValue == true ? ': null' : ''}';
    } else if (realType() is AstInt) {
      return '((Number) $vname).longValue() ${hasDefaultValue == true ? ': 0' : ''}';
    } else {
      return '(${realType().javaType()}) $vname : ${realType().javaDefault()}';
    }
  }

  String convertJavaObj2Json(String valueName) {
    if (containsCustomType()) {
      if (realType() is AstList) {
        return '${Keys.listClone}((List)$valueName)';
      } else if (realType() is AstMap) {
        return '${Keys.mapClone}((Map)$valueName)';
      } else if (realType() is AstCustomType) {
        return '$valueName.toMap()';
      } else if (realType() is AstVoid) {
        return 'null';
      } else {
        return valueName;
      }
    }

    if (realType() is AstVoid) {
      return 'null';
    }
    return valueName;
  }

  String? convertOcJson2Obj({String vname = '[message objectForKey:@"data"]'}) {
    if (containsCustomType() == false) {
      return vname;
    }

    final generics = <String>[];
    _recursiveCollectGenerics(this, generics);

    final ocGenerics = generics.map((e) => '@"$e"').toList().join(',');
    if (realType() is AstList) {
      return '${Keys.listConvert}($vname,  @[$ocGenerics], 1)';
    } else if (realType() is AstMap) {
      return '${Keys.mapConvert}($vname,  @[$ocGenerics], 1)';
    } else if (realType() is AstCustomType) {
      return '[${realType().ocType()} fromMap:$vname]';
    } else {
      return vname;
    }
  }

  String convertOcObj2Json(String valueName) {
    if (containsCustomType()) {
      if (realType() is AstList) {
        return '${Keys.listClone}($valueName)';
      } else if (realType() is AstMap) {
        return '${Keys.mapClone}($valueName)';
      } else if (realType() is AstCustomType) {
        return '[$valueName toMap]';
      } else if (realType() is AstVoid) {
        return 'nil';
      } else {
        return valueName;
      }
    }

    if (realType() is AstVoid) {
      return 'nil';
    }
    return valueName;
  }
}
