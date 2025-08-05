
String objcUniApiClassMethods(String sectname, String clsName) => '''
+ (void)init:(NSObject<FlutterBinaryMessenger>* _Nonnull)binaryMessenger {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self loadExportClass];
        [$clsName init: binaryMessenger];
    });
}

+ (void)loadExportClass {
  static int __UNIAPI = 0;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    UniSubscriberInstanceCache = [NSMutableDictionary new];

    Dl_info info;
    dladdr(&__UNIAPI, &info);

#ifndef __LP64__
    const struct mach_header *mhp = (struct mach_header*)info.dli_fbase;
    unsigned long size = 0;
    uint32_t *memory = (uint32_t*)getsectiondata(mhp, "__DATA", "$sectname", & size);
#else /* defined(__LP64__) */
    const struct mach_header_64 *mhp = (struct mach_header_64*)info.dli_fbase;
    unsigned long size = 0;
    uint64_t *memory = (uint64_t*)getsectiondata(mhp, "__DATA", "$sectname", & size);
#endif /* defined(__LP64__) */

    for(int idx = 0; idx < size/sizeof(void*); ++idx){
      char *string = (char*)memory[idx];
      NSString *clsName = [NSString stringWithUTF8String:string];

      id obj = _readSubscriberInCache(clsName);
      if (!obj) {
        _writeSubscriberToCache(clsName,[NSClassFromString(clsName) new]);
      }
    }
  });
}

/// 慢速查找, 用于用户传入protocol的场景。多用于用户开发的Plugin插件中
/// @param protocolName 协议名称
+ (id)slowLookup:(NSString *)protocolName {
  NSDictionary *cache = [UniSubscriberInstanceCache copy];
  NSArray *subscribers = cache.allValues;
  Protocol *p = NSProtocolFromString(protocolName);
  id subscriber;
  for (id obj in subscribers) {
    if ([obj conformsToProtocol:p]) {
      subscriber = obj;
      break;
    }
  }
  return subscriber;
}

+ (id)get:(NSString *)className {
  id value = _readSubscriberInCache(className);
  if (!value) {
    value = [self slowLookup:className];
  }
  return value;
}
''';
