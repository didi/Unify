#import "UnifyUniPagePlugin.h"
#import "AbsUniPageFactory.h"
#import "UniPageContainer.h"
#import "UniPage.h"

static NSMutableDictionary<NSString*, Class> *pageRegister;

static NSMutableDictionary<NSString*, NSString*> *noticeNameRegister;

@implementation UnifyUniPagePlugin

+ (void)registerUniPage:(Class)clsName viewType:(NSString*)viewType {
    NSAssert(![clsName isKindOfClass:UniPage.class], @"clsName must be UniPage or its derived class");
    NSAssert(viewType != nil, @"viewType cannot be nil");
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (pageRegister == nil) {
            pageRegister = [NSMutableDictionary new];
            noticeNameRegister = [NSMutableDictionary new];
        }
    });
    
    pageRegister[viewType] = clsName;
}

+ (void)registerFlutterViewControllerWillDeallocObserver:(NSString*)noticeName {
    NSAssert(noticeName != nil, @"noticeName cannot be nil");
    for (NSString *key in pageRegister.allKeys) {
        noticeNameRegister[key] = noticeName;
    }
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    for (NSString *key in pageRegister.allKeys) {
        Class cls = pageRegister[key];
        [registrar registerViewFactory:[[AbsUniPageFactory alloc] init:^UniPageContainer * _Nonnull(CGRect frame, int64_t viewId, id  _Nullable args) {
            /*
              这块构造 UniPageContainer->UniPage,而不是直接返回 UniPage 的主要目的是：
                在混合开发场景中，即： NA -> Flutter(wedget 使用了嵌原生)，如果直接侧滑返回的话，会造成 UniPage 泄漏。
                业务逻辑大多是在UniPage中的，UniPage泄漏是不可接受的。
              采用 UniPageContainer->UniPage 的结构，经过巧妙设计，可以解决 NA -> Flutter(wedget 使用了嵌原生) 场景中 UniPage 的泄漏问题
             */
            UniPageContainer *container = [[UniPageContainer alloc] initWithWithFrame:frame viewType:key viewIdentifier:viewId arguments:args binaryMessenger:[registrar messenger]];
            
            if ([noticeNameRegister objectForKey:key] != NULL) {
                [container addFlutterViewControllerWillDeallocObserver:[noticeNameRegister objectForKey:key]];
            }
            NSLog(@"jerry - 1017 create UniPageContainer: %@", container);
            UniPage *page = [[cls alloc] init];
            page.delegate = container;
            [container setupUniPage:page];
            NSLog(@"jerry - 1017 create UniPage:%@", page);
            return container;
        }] withId:key];
    }
}

@end
