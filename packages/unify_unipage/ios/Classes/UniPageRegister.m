//
//  UniPageRegister.m
//  unify_unipage
//
//  Created by jerry on 2024/7/16.
//

#import "UniPageRegister.h"
#import "UniPageConstants.h"
#import "AbsUniPageFactory.h"
#import "UniPage.h"

@interface FlutterEngine (UnifyUniPage)
- (NSMutableDictionary*)registrars;
- (NSObject<FlutterPluginRegistrar>*)registrarForPluginKey:(NSString*)pluginKey;
@end
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation FlutterEngine (UnifyUniPage)
- (NSObject<FlutterPluginRegistrar>*)registrarForPluginKey:(NSString*)pluginKey {
    return [[self registrars] objectForKey:pluginKey];
}
@end

@interface UniPageRegister ()

@property (nonatomic, strong) NSMutableDictionary<NSString*, Class> *pageRegister;
@property (nonatomic, strong) FlutterMethodChannel *channel;

@end

@implementation UniPageRegister

+ (UniPageRegister *)sharedInstance {
  static UniPageRegister *instance = nil;
  if (instance == nil) {
    instance = [[UniPageRegister alloc] init];
  }
  return instance;
}

+ (void)registerUniPage:(Class)clsName pageType:(NSString*)pageType {
    NSAssert(![clsName isKindOfClass:UniPage.class], @"clsName 必须是 UniPage 或其 派生类");
    NSAssert(pageType != nil, @"pageType 不能为 nil");
    self.sharedInstance.pageRegister[pageType] = clsName;
}

+ (void)attachToEngine:(FlutterEngine *)engine {
    self.sharedInstance.channel = [FlutterMethodChannel methodChannelWithName:UNI_PAGE_CHANNEL binaryMessenger:engine.binaryMessenger];
    for (NSString *key in self.sharedInstance.pageRegister.allKeys) {
        Class cls = self.sharedInstance.pageRegister[key];
        NSObject<FlutterPluginRegistrar>*registrar = [engine registrarForPluginKey:@"UnifyUnipagePlugin"];
        [registrar registerViewFactory:[[AbsUniPageFactory alloc] init:^UniPage * _Nonnull(CGRect frame, int64_t viewId, id  _Nullable args) {
            return [[cls alloc] initWithWithFrame:frame viewIdentifier:viewId arguments:args binaryMessenger:engine.binaryMessenger];
        }] withId:key];
    }
}

+ (FlutterMethodChannel*)channel {
    return self.sharedInstance.channel;
}

- (NSMutableDictionary*)pageRegister {
    if (!_pageRegister) {
        _pageRegister = NSMutableDictionary.new;
    }
    return _pageRegister;
}

@end
