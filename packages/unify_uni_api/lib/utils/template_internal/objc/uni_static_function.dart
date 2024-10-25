const objcUniApiPrivateStaticFounction = '''
static NSMutableDictionary<NSString *, NSObject *> *UniSubscriberInstanceCache;//注册代理类实例

/// Subscriber实例存入缓存
/// @param clsName 实例类名
/// @param Obj 实例
static void _writeSubscriberToCache(NSString *clsName,id Obj) {
    if (Obj && clsName) {
        if (UniSubscriberInstanceCache[clsName] == nil) {
            UniSubscriberInstanceCache[clsName] = Obj;
        }
    }
}

/// 通过类名查询Subscriber实例
/// @param clsName Adapter类名称
static id _readSubscriberInCache(NSString *clsName) {
    if (!clsName) return nil;
    NSDictionary *dic = [UniSubscriberInstanceCache copy];
    return dic[clsName];
}
''';
