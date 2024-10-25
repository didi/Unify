// ignore_for_file: unnecessary_brace_in_string_interps

import 'package:unify_flutter/ast/basic/ast_bool.dart';
import 'package:unify_flutter/ast/basic/ast_int.dart';
import 'package:unify_flutter/ast/basic/ast_list.dart';
import 'package:unify_flutter/ast/basic/ast_string.dart';
import 'package:unify_flutter/ast/basic/ast_variable.dart';
import 'package:unify_flutter/ast/uniapi/ast_model.dart';
import 'package:unify_flutter/generator/common.dart';

import '../../inputfile/mock_input_file.dart';

abstract class BaseUniModelCase {
  Model getModel();
  String getAndroidOutput();
  String getFlutterOutput();
  String getIOSHeaderOutput();
  String getIOSSourceOutput();
}

/// 基本类型测试
class UniModelCaseSimpleTypes extends BaseUniModelCase {
  @override
  Model getModel() {
    final field1 = Variable(AstInt(maybeNull: true), 'a');
    final field2 = Variable(AstString(maybeNull: true), 'b');
    final field3 = Variable(AstBool(maybeNull: true), 'c');
    final fieldListInt =
        Variable(AstList(maybeNull: true, generics: [AstInt()]), 'listInt');
    final fieldListString = Variable(
        AstList(maybeNull: true, generics: [AstString()]), 'listString');

    return Model(
      'M',
      mockInputFile('m.dart'),
      fields: [field1, field2, field3, fieldListInt, fieldListString],
    );
  }

  @override
  String getAndroidOutput() {
    return '''${generatedCodeWarning}
package com.uniapi;

import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.ArrayList;
import com.uniapi.uniapi.UniModel;

public class M extends UniModel {
    private long a;
    private String b;
    private boolean c;
    private List<Long> listInt;
    private List<String> listString;

    public long getA() { return a; }

    public void setA(long a) { this.a = a; }

    public String getB() { return b; }

    public void setB(String b) { this.b = b; }

    public boolean getC() { return c; }

    public void setC(boolean c) { this.c = c; }

    public List<Long> getListInt() { return listInt; }

    public void setListInt(List<Long> listInt) { this.listInt = listInt; }

    public List<String> getListString() { return listString; }

    public void setListString(List<String> listString) { this.listString = listString; }


    @Override
    public Map<String, Object> toMap() {
        Map<String, Object> result = new HashMap<>();
        result.put("a", a);
        result.put("b", b);
        result.put("c", c);
        result.put("listInt", listInt);
        result.put("listString", listString);
        return result;
    }

    public static M fromMap(Map<String, Object> map) {
        M result = new M();
        result.a = map.containsKey("a") && map.get("a") != null ? ((Number) map.get("a")).longValue() : 0;
        result.b = map.containsKey("b") && map.get("b") != null ? (String) map.get("b") : "";
        result.c = map.containsKey("c") && map.get("c") != null ? (Boolean) map.get("c") : false;
        result.listInt = map.containsKey("listInt") && map.get("listInt") != null ? (List<Long>) map.get("listInt") : new ArrayList<>();
        result.listString = map.containsKey("listString") && map.get("listString") != null ? (List<String>) map.get("listString") : new ArrayList<>();
        return result;
    }

}
''';
  }

  @override
  String getFlutterOutput() {
    return """
${generatedCodeWarning}

class M {
    int? a;
    String? b;
    bool? c;
    List<int>? listInt;
    List<String>? listString;

    Object encode() {
        final Map<String, dynamic> ret = <String, dynamic>{};
        ret['a'] = a as int?;
        ret['b'] = b as String?;
        ret['c'] = c as bool?;
        ret['listInt'] = listInt?.map((e) => e as int).toList();
        ret['listString'] = listString?.map((e) => e as String).toList();
        return ret;
    }

    static M decode(Object message) {
        final Map<dynamic, dynamic> rawMap = message as Map<dynamic, dynamic>;
        final Map<String, dynamic> map = Map.from(rawMap);
        return M()
            ..a = map['a'] == null
                ? 0
                : map['a'] as int?
            ..b = map['b'] == null
                ? ''
                : map['b'] as String?
            ..c = map['c'] == null
                ? false
                : map['c'] as bool?
            ..listInt = map['listInt'] == null
                ? []
                : (map['listInt'] as List).map((value) => value as int).toList()
            ..listString = map['listString'] == null
                ? []
                : (map['listString'] as List).map((value) => value as String).toList()
            ;
    }
}
""";
  }

  @override
  String getIOSHeaderOutput() {
    return '''${generatedCodeWarning}
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface M : NSObject

@property(nonatomic, strong) NSNumber* a; // Origin dart type is 'int'
@property(nonatomic, copy) NSString* b; // Origin dart type is 'String'
@property(nonatomic, strong) NSNumber* c; // Origin dart type is 'bool'
@property(nonatomic, strong) NSArray<NSNumber*>* listInt; // Origin dart type is 'List'
@property(nonatomic, strong) NSArray<NSString*>* listString; // Origin dart type is 'List'

+ (M*)fromMap:(NSDictionary<NSString*, NSObject*>*)dict;
+ (NSArray<M*>*)modelList:(NSArray<NSDictionary<NSObject*, NSObject*>*>*)list;
+ (NSArray<NSDictionary<NSObject*, NSObject*>*>*)dicList:(NSArray<M*>*)list;

- (NSDictionary<NSString*, NSObject*>*)toMap;

@end

NS_ASSUME_NONNULL_END
''';
  }

  @override
  String getIOSSourceOutput() {
    return '''${generatedCodeWarning}
#import "M.h"

@interface M ()


@end

@implementation M

+ (NSArray<NSObject*>*)modelList:(NSArray<NSDictionary<NSObject*, NSObject*>*>*)list {
    if ((NSNull *)list == [NSNull null]) return nil;
    NSMutableArray *models = NSMutableArray.new;
    for (NSDictionary *item in list) {
        id obj = [[self class] fromMap:item];
        [models addObject:obj];
    }
    if (models.count==0) return nil;
    return models;
}

+ (NSArray<NSObject*>*)dicList:(NSArray<NSObject*>*)list {
    if ((NSNull *)list == [NSNull null]) return nil;
    NSMutableArray *dicList = NSMutableArray.new;
    for (id item in list) {
        NSDictionary *dic = [item toMap];
        [dicList addObject:dic];
    }
    return dicList;
}

+ (id)wrapNil:(id)value {
    return (value == nil) || ((NSNull *)value == [NSNull null]) || [value isEqual:@"<null>"]? nil : value;
}

+ (M*)fromMap:(NSDictionary<NSString*, NSObject*>*)dict {
    if ((NSNull *)dict == [NSNull null]) return nil;
    M* result = [[M alloc] init];
    result.a = [self wrapNil:dict[@"a"]];
    result.b = [self wrapNil:dict[@"b"]];
    result.c = [self wrapNil:dict[@"c"]];
    result.listInt = [self wrapNil:dict[@"listInt"]];
    result.listString = [self wrapNil:dict[@"listString"]];
    return result;
}

- (NSDictionary<NSString*, NSObject*>*)toMap {
    return [NSDictionary dictionaryWithObjectsAndKeys:
        (self.a ? self.a : [NSNull null]), @"a",
        (self.b ? self.b : [NSNull null]), @"b",
        (self.c ? self.c : [NSNull null]), @"c",
        (self.listInt ? self.listInt : [NSNull null]), @"listInt",
        (self.listString ? self.listString : [NSNull null]), @"listString",
        nil];
}

@end
''';
  }
}
