import 'package:unify/ast/basic/ast_variable.dart';
import 'package:unify/ast/uniapi/ast_method.dart';
import 'package:unify/generator/widgets/base/line.dart';
import 'package:unify/generator/widgets/code_unit.dart';
import 'package:unify/utils/constants.dart';
import 'package:unify/utils/extension/list_extension.dart';
import 'package:unify/utils/utils.dart';

extension CodeUnitExtension on CodeUnit {
  // clone函数里  动态生成Dart代码
  String _dynamicDartCodeInClone(List<String> names) {
    final dynamicCode = StringBuffer();
    for (final element in names) {
      dynamicCode.write('value is $element ? value.encode() : ');
    }
    return dynamicCode.toString();
  }

  // 创建List数据的clone体，可以提供处理元数据中自定义类型，使其转换为基础类型的能力
  List<OneLine> _cloneDartList({List<String> names = const [], int depth = 0}) {
    final func = '''
    static List<T> ${Keys.listClone}<T>(List list) {
      List<T> newList = <T>[];
      for (var value in list) {
        newList.add(
          value is Map ? ${Keys.mapClone}(value) :
          value is List ? ${Keys.listClone}(value) :
          ${_dynamicDartCodeInClone(names)}
          value);
      }

      return newList;
    }
    ''';

    return [OneLine(depth: depth, body: func)];
  }

  // 创建Map数据的clone体，可以提供处理元数据中自定义类型，使其转换为基础类型的能力
  List<OneLine> _cloneDartMap({List<String> names = const [], int depth = 0}) {
    final func = '''
    static Map<K, dynamic> ${Keys.mapClone}<K, V>(Map<K, V> map) {
      Map<K, dynamic> newMap = <K, dynamic>{};

      map.forEach((key, value) {
        newMap[key] = 
          (value is Map ? ${Keys.mapClone}(value) : 
          value is List ? ${Keys.listClone}(value): 
          ${_dynamicDartCodeInClone(names)}
          value);
      });

      return newMap;
    }
    ''';

    return [OneLine(depth: depth, body: func)];
  }

  List<OneLine> cloneDartCollectionType(
      {List<Method> methods = const [],
      List<Variable> fields = const [],
      int depth = 0}) {
    final names = collectCustomTypeNames(methods: methods, fields: fields);
    // 去除非@UniModel导入类型
    names.removeBuildInType();

    if (names.isNotEmpty) {
      return [
        ..._cloneDartMap(names: names, depth: depth),
        ..._cloneDartList(names: names, depth: depth)
      ];
    }
    return [];
  }

  //  -------- Java ---------
  // clone函数里  动态生成Java代码
  String _dynamicJavaCodeInClone(List<String> names) {
    final dynamicCode = StringBuffer();
    for (final element in names) {
      dynamicCode
          .write('value instanceof $element ? (($element) value).toMap() :');
    }
    return dynamicCode.toString();
  }

  List<OneLine> _cloneJavaList({List<String> names = const [], int depth = 0}) {
    final func = '''
    private static List<Object> ${Keys.listClone}(List list) {
      List newList = new ArrayList<>();
      for (Object value: list) {
          newList.add(
            value instanceof Map ? ${Keys.mapClone}((Map<String, Object>) value) :
            value instanceof List ? ${Keys.listClone}((List<Object>) value) :
            ${_dynamicJavaCodeInClone(names)}
            value
          );
      }
      return newList;
    }
    ''';

    return [OneLine(depth: depth, body: func)];
  }

  List<OneLine> _cloneJavaMap({List<String> names = const [], int depth = 0}) {
    final func = '''
    private static  Map<String, Object> ${Keys.mapClone}(Map<String, Object> map) {
      Map<String, Object> newDic = new HashMap<String, Object>();
      for(Map.Entry<String, Object> entry : map.entrySet()) {
          Object value = entry.getValue();
          String key = entry.getKey();
          newDic.put(key,
          value instanceof Map ? ${Keys.mapClone}((Map<String, Object>) value):
          value instanceof List? ${Keys.listClone}((List<Object>) value) :
          ${_dynamicJavaCodeInClone(names)}
          value);
      }
      return newDic;
    }
    ''';

    return [OneLine(depth: depth, body: func)];
  }

  // convert函数里  动态生成Java代码
  String _dynamicJavaCodeInConvert(List<String> names) {
    final dynamicCode = StringBuffer();
    for (final element in names) {
      dynamicCode.write(
          'generics[depth] == "$element" ? $element.fromMap((Map<String, Object>)value) :');
    }
    return dynamicCode.toString();
  }

  List<OneLine> _convertJavaList(
      {List<String> names = const [], int depth = 0}) {
    final func = '''
    private static List ${Keys.listConvert}(List list, String[] generics, int depth) {
      List newList = new ArrayList<>();
      for (Object value : list) {
          newList.add(
              generics[depth] == "List" ? ${Keys.listConvert}((List<Object>)value, generics, depth+1) :
              generics[depth] == "Map" ? ${Keys.mapConvert}((Map<String, Object>)value, generics, depth+1) :
              ${_dynamicJavaCodeInConvert(names)}
              value);
      }
    
      return newList;
    }
''';
    return [OneLine(depth: depth, body: func)];
  }

  List<OneLine> _convertJavaMap(
      {List<String> names = const [], int depth = 0}) {
    final func = '''
    private static Map<String, Object> ${Keys.mapConvert}(Map<String, Object> map, String[] generics, int depth) {
      Map<String, Object> newDic = new HashMap<String, Object>();
      for(Map.Entry<String, Object> entry : map.entrySet()) {
          Object value = entry.getValue();
          String key = entry.getKey();
          newDic.put(key,
          generics[depth] == "List" ? ${Keys.listConvert}((List<Object>)value, generics, depth+1) :
          generics[depth] == "Map" ? ${Keys.mapConvert}((Map<String, Object>)value, generics, depth+1) :
          ${_dynamicJavaCodeInConvert(names)}
          value);
      }
      return  newDic;
    }
    ''';
    return [OneLine(depth: depth, body: func)];
  }

  // 处理 集合类型并且内部元素含有自定义类型
  List<OneLine> handlerJavaCollectionType(
      {List<Method> methods = const [],
      List<Variable> fields = const [],
      int depth = 0}) {
    final names = collectCustomTypeNames(methods: methods, fields: fields);
    // 去除非@UniModel导入类型
    names.removeBuildInType();

    if (names.isNotEmpty) {
      return [
        ..._cloneJavaList(names: names, depth: depth),
        ..._cloneJavaMap(names: names, depth: depth),
        ..._convertJavaList(names: names, depth: depth),
        ..._convertJavaMap(names: names, depth: depth)
      ];
    }
    return [];
  }

  //  -------- OC ---------

  // clone函数里  动态生成OC代码
  String _dynamicOcCodeInClone(List<String> names) {
    final dynamicCode = StringBuffer();
    for (final element in names) {
      dynamicCode
          .write('[value isKindOfClass:[$element class]]? [value toMap] :');
    }
    return dynamicCode.toString();
  }

  List<OneLine> _cloneOCList({List<String> names = const [], int depth = 0}) {
    final func = '''
static NSDictionary * ${Keys.mapClone}(NSDictionary *dic);
static NSArray * ${Keys.listClone}(NSArray *list) {
    NSMutableArray *newList = NSMutableArray.new;
    if ([list isKindOfClass:[NSNull class]]) return [newList copy];
    for (id value in list) {
        [newList addObject:
            [value isKindOfClass:[NSArray class]]? ${Keys.listClone}(value) :
            [value isKindOfClass:[NSDictionary class]]?${Keys.mapClone}(value) :
            ${_dynamicOcCodeInClone(names)}
            value];
    }
  
    return [newList copy];
}
    ''';

    return [OneLine(depth: depth, body: func)];
  }

  List<OneLine> _cloneOCMap({List<String> names = const [], int depth = 0}) {
    final func = '''
static NSDictionary * ${Keys.mapClone}(NSDictionary *dic) {
  NSMutableDictionary *newDic = NSMutableDictionary.new;
  if ([dic isKindOfClass:[NSNull class]]) return [newDic copy];
  for (id key in dic) {
      id value = [dic objectForKey:key];
      newDic[key] =
          [value isKindOfClass:[NSArray class]]? ${Keys.listClone}(value) :
          [value isKindOfClass:[NSDictionary class]]? ${Keys.mapClone}(value) :
          ${_dynamicOcCodeInClone(names)}
          value;
  }
  return  [newDic copy];;
}
    ''';

    return [OneLine(depth: depth, body: func)];
  }

  // convert函数里  动态生成OC代码
  String _dynamicOcCodeInConvert(List<String> names) {
    final dynamicCode = StringBuffer();
    for (final element in names) {
      dynamicCode.write(
          '[generics[depth] isEqual:@"$element"]? [$element fromMap: value] :');
    }
    return dynamicCode.toString();
  }

  // 将集合中的List转换成Model
  List<OneLine> _convertOCList({List<String> names = const [], int depth = 0}) {
    final func = '''
static NSDictionary * ${Keys.mapConvert}(NSDictionary *dic, NSArray *generics, int depth);
static NSArray * ${Keys.listConvert}(NSArray *list, NSArray *generics, int depth) {
        NSMutableArray *newList = NSMutableArray.new;
        if ([list isKindOfClass:[NSNull class]]) return [newList copy];
        for (id value in list) {
            [newList addObject:
                [generics[depth] isEqual:@"NSArray"]? ${Keys.listConvert}(value, generics, depth+1) :
                [generics[depth] isEqual:@"NSDictionary"]? ${Keys.mapConvert}(value, generics, depth+1) :
                ${_dynamicOcCodeInConvert(names)}
                value];
        }
      
        return [newList copy];
}
''';
    return [OneLine(depth: depth, body: func)];
  }

  // 将集合中的Map转换成Model
  List<OneLine> _convertOCMap({List<String> names = const [], int depth = 0}) {
    final func = '''
static NSDictionary * ${Keys.mapConvert}(NSDictionary *dic, NSArray *generics, int depth) {
  NSMutableDictionary *newDic = NSMutableDictionary.new;
  if ([dic isKindOfClass:[NSNull class]]) return [newDic copy];
  for (id key in dic) {
      id value = [dic objectForKey:key];
      newDic[key] =
      [generics[depth] isEqual:@"NSArray"]? ${Keys.listConvert}(value, generics, depth+1) :
      [generics[depth] isEqual:@"NSDictionary"]? ${Keys.mapConvert}(value, generics, depth+1) :
      ${_dynamicOcCodeInConvert(names)}
      value;
  }
  return  [newDic copy];;
}
''';
    return [OneLine(depth: depth, body: func)];
  }

  // 处理 集合类型并且内部元素含有自定义类型
  List<OneLine> handlerOCCollectionType(
      {List<Method> methods = const [],
      List<Variable> fields = const [],
      int depth = 0}) {
    final names = collectCustomTypeNames(methods: methods, fields: fields);
    // 去除非@UniModel导入类型
    names.removeBuildInType();

    if (names.isNotEmpty) {
      return [
        ..._cloneOCList(names: names, depth: depth),
        ..._cloneOCMap(names: names, depth: depth),
        ..._convertOCList(names: names, depth: depth),
        ..._convertOCMap(names: names, depth: depth)
      ];
    }
    return [];
  }
}
