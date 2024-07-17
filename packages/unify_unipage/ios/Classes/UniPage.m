//
//  UniPage.m
//  unify_unipage
//
//  Created by jerry on 2024/7/16.
//

#import "UniPage.h"
#import "UniPageConstants.h"

@interface UniPage()<FlutterPlatformView>

@property (nonatomic, copy) NSString *viewType;
@property (nonatomic, assign) int64_t viewId;
@property (nonatomic, strong) NSDictionary *arguments;
@property (nonatomic, strong) FlutterMethodChannel *channel;

@end

@implementation UniPage

- (void)dealloc {
    [self onDispose];
}

- (instancetype)initWithWithFrame:(CGRect)frame
                   viewIdentifier:(int64_t)viewId
                         viewType:(NSString*)viewType
                        arguments:(NSDictionary *)args
                  binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger {
    if ([super init]) {
        self.viewId = viewId;
        self.viewType = viewType;
        self.arguments = args;
        self.channel = [FlutterMethodChannel methodChannelWithName:UNI_PAGE_CHANNEL binaryMessenger:messenger];
    }
    return self;
}

#pragma - public methods

- (void)pushNamed:(NSString*)routePath param:(NSDictionary *)args {
    NSAssert(routePath != nil, @"routePath cannot be nil");
    NSAssert(args != nil, @"args cannot be nil");
    
    NSDictionary *params = @{
        UNI_PAGE_CHANNEL_PARAMS_PATH: routePath,
        UNI_PAGE_CHANNEL_PARAMS_PARAMS: args
    };
    
    [self.channel invokeMethod:UNI_PAGE_ROUTE_PUSH_NAMED arguments:params];
}

- (void)pop:(id)result {
    NSAssert(result != nil, @"result cannot be nil");
    
    NSDictionary *params = @{
        UNI_PAGE_CHANNEL_PARAMS_PARAMS: result
    };
    
    [self.channel invokeMethod:UNI_PAGE_ROUTE_POP arguments:params];
}

- (int64_t)getViewId {
    return self.viewId;
}

- (NSDictionary*)getCreationParams {
    return self.arguments;
}

- (NSString*)getViewType {
    return self.viewType;
}


- (void)onCreate {
    
}

- (void)onDispose {
   
}

#pragma mark - FlutterPlatformView

/// 返回真正的视图
- (UIView *)view {
    [self onCreate];
    return self;
}


@end
