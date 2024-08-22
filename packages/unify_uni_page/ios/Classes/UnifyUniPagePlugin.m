#import "UnifyUniPagePlugin.h"
#import "AbsUniPageFactory.h"
#import "UniPage.h"

static NSMutableDictionary<NSString*, Class> *pageRegister;

@implementation UnifyUniPagePlugin

+ (void)registerUniPage:(Class)clsName viewType:(NSString*)viewType {
    NSAssert(![clsName isKindOfClass:UniPage.class], @"clsName must be UniPage or its derived class");
    NSAssert(viewType != nil, @"viewType cannot be nil");
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (pageRegister == nil) {
            pageRegister = [NSMutableDictionary new];
        }
    });
    
    pageRegister[viewType] = clsName;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    for (NSString *key in pageRegister.allKeys) {
        Class cls = pageRegister[key];
        [registrar registerViewFactory:[[AbsUniPageFactory alloc] init:^UniPage * _Nonnull(CGRect frame, int64_t viewId, id  _Nullable args) {
            return [[cls alloc] initWithWithFrame:frame viewType:key viewIdentifier:viewId arguments:args binaryMessenger:[registrar messenger]];
        }] withId:key];
    }
}

@end
