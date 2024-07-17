//
//  UniPage.m
//  unify_unipage
//
//  Created by jerry on 2024/7/16.
//

#import "UniPage.h"
#import "UniPageConstants.h"
#import "UniPageRegister.h"

@interface UniPage()<FlutterPlatformView>

@property (nonatomic, strong) FlutterMethodChannel *channel;
@property (nonatomic, assign) int64_t viewId;
@property (nonatomic, strong) id arguments;

@end

@implementation UniPage

- (void)dealloc {
    [self onDispose];
}

- (instancetype)initWithWithFrame:(CGRect)frame
                   viewIdentifier:(int64_t)viewId
                        arguments:(id _Nullable)args
                  binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger {
    if ([super init]) {
        self.viewId = viewId;
        self.arguments = args;
    }
    return self;
}

#pragma - public methods

- (void)pushNamed:(NSString*)routePath param:(id)args {
    NSAssert(routePath != nil, @"routePath 不能为 nil");
    NSAssert(args != nil, @"args 不能为 nil");
    
    NSDictionary *params = @{
        UNI_PAGE_CHANNEL_PARAMS_PATH: routePath,
        UNI_PAGE_CHANNEL_PARAMS_PARAMS: args
    };
    
    [UniPageRegister.channel invokeMethod:UNI_PAGE_ROUTE_PUSH_NAMED arguments:params];
}

- (void)pop:(id)result {
    NSAssert(result != nil, @"result 不能为 nil");
    
    NSDictionary *params = @{
        UNI_PAGE_CHANNEL_PARAMS_PARAMS: result
    };
    
    [UniPageRegister.channel invokeMethod:UNI_PAGE_ROUTE_POP arguments:params];
}

- (int64_t)getViewId {
    return self.viewId;
}

- (id)getCreationParams {
    return self.arguments;
}


- (UIView *)onCreate {
    return self;
}

- (void)onDispose {
    NSLog(@"@@@@@@@@ call %s", _cmd);
}

#pragma mark - FlutterPlatformView

/// 返回真正的视图
- (UIView *)view {
    return [self onCreate];
}


@end
