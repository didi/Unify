//
//  UniPageContainer.m
//  unify_uni_page
//
//  Created by jerry on 2024/10/17.
//

#import "UniPageContainer.h"
#import "UniPageConstants.h"
#import "UniPage.h"
#import "UIView+GetController.h"

@interface UniPageContainer()<FlutterPlatformView>

@property (nonatomic, copy) NSString *viewType;
@property (nonatomic, assign) int64_t viewId;
@property (nonatomic, strong) NSDictionary *arguments;
@property (nonatomic, strong) FlutterMethodChannel *channel;
@property (nonatomic, strong) FlutterMethodChannel *disposeChannel;
@property (nonatomic, assign) BOOL isPosted;
@property (nonatomic, strong) UniPage *uniPage;

@end

@implementation UniPageContainer

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"jerry - 1017 dealloc UniPageContainer: %@", self);
}

- (instancetype)initWithWithFrame:(CGRect)frame
                         viewType:(NSString*)viewType
                   viewIdentifier:(int64_t)viewId
                        arguments:(NSDictionary *)args
                  binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger {
    if ([super init]) {
        self.viewId = viewId;
        self.viewType = viewType;
        self.arguments = args;
        self.channel = [FlutterMethodChannel methodChannelWithName:self.channelName binaryMessenger:messenger];
        __weak __typeof(self) weakSelf = self;
        [self.channel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf onMethodCall:call result:result];
        }];
        
        self.disposeChannel = [FlutterMethodChannel methodChannelWithName:self.disposeChannelName binaryMessenger:messenger];
        [self.disposeChannel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf onDispose];
        }];
        
        NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
        [center addObserver:self
                   selector:@selector(applicationWillEnterForeground:)
                       name:UIApplicationWillEnterForegroundNotification
                     object:nil];

        [center addObserver:self
                   selector:@selector(applicationDidEnterBackground:)
                       name:UIApplicationDidEnterBackgroundNotification
                     object:nil];
        
        [center addObserver:self
                   selector:@selector(onFlutterViewControllerWillDealloc:)
                       name:NotifyUniPageFlutterViewControllerWillDealloc
                     object:nil];
    }
    return self;
}

- (void)setupUniPage:(UniPage*)uniPage {
    self.uniPage = uniPage;
}

- (id)onMethodCall:(NSString*)methodName params:(NSDictionary *)args {
    return [self.uniPage onMethodCall:methodName params:args];
}

- (void)onDispose {
    [self.uniPage onDispose];
    [self.disposeChannel setMethodCallHandler:nil];
}

#pragma mark - UniPageProtocol

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

- (void)invoke:(NSString*)methodName
     arguments:(id _Nullable)params
        result:(FlutterResult _Nullable)callback {
    NSAssert(methodName != nil, @"methodName cannot be nil");
    
    NSDictionary *arguments = @{
        UNI_PAGE_CHANNEL_VIEW_TYPE: self.viewType,
        UNI_PAGE_CHANNEL_VIEW_ID: @(self.viewId),
        UNI_PAGE_CHANNEL_METHOD_NAME: methodName,
        UNI_PAGE_CHANNEL_PARAMS_PARAMS: params != nil ? params : @{},
    };
    
    [self.channel invokeMethod:UNI_PAGE_CHANNEL_INVOKE arguments:arguments result:callback];
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

#pragma mark - FlutterPlatformView

/// 返回真正的视图
- (UIView *)view {
    UIView *container = UIView.new;
    [container addSubview:self.uniPage];

    /*
     下面约束的作用是子视图完全撑开父视图，保持子视图和父视图四周边距紧邻着
     */
    [self.uniPage setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint* leftConstraint = [NSLayoutConstraint constraintWithItem:self.uniPage attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:container attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0];
    NSLayoutConstraint* rightConstraint = [NSLayoutConstraint constraintWithItem:self.uniPage attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:container attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0];
    NSLayoutConstraint* topConstraint = [NSLayoutConstraint constraintWithItem:self.uniPage attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:container attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    NSLayoutConstraint* bottomConstraint = [NSLayoutConstraint constraintWithItem:self.uniPage attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:container attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    if (@available(iOS 8.0, *)) {
        leftConstraint.active = YES;
        rightConstraint.active = YES;
        topConstraint.active = YES;
        bottomConstraint.active = YES;
    } else {
        [container addConstraints:@[leftConstraint, rightConstraint, topConstraint, bottomConstraint]];
    }
    
    [self.uniPage onCreate];
    return container;
}

#pragma mark - Notifications

- (void)applicationWillEnterForeground:(NSNotification*)notification {
    [self.uniPage onForeground];
}

- (void)applicationDidEnterBackground:(NSNotification*)notification {
    [self.uniPage onBackground];
}

#pragma mark - private methods

- (NSString*)createChannelName:(NSString*)viewType viewId:(int64_t)viewId suffix:(NSString*)suffix{
    NSString *suffixStr = suffix ? [NSString stringWithFormat:@".%@", suffix] : @"";
    return [NSString stringWithFormat:@"%@.%@.%lld%@", UNI_PAGE_CHANNEL, viewType, viewId, suffixStr];
}

- (void)onMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([call.method isEqualToString:UNI_PAGE_CHANNEL_INVOKE]) {
        id args = call.arguments;
        NSString *methodName = [args objectForKey:UNI_PAGE_CHANNEL_METHOD_NAME];
        id params = [args objectForKey:UNI_PAGE_CHANNEL_PARAMS_PARAMS];
        id ret = [self onMethodCall:methodName params:params];
        result(ret);
        return;
    }
    result(nil);
}

- (NSString*)channelName {
    return [self createChannelName:self.viewType viewId:self.viewId suffix:nil];
}

- (NSString*)disposeChannelName {
    return [self createChannelName:self.viewType viewId:self.viewId suffix:@"dispose"];
}

- (void)onFlutterViewControllerWillDealloc:(id)notification {
    NSUInteger noticeVCId = [[notification object] hash];
    NSUInteger curOwnerId = [self.uniPage getOwnerId];
    NSLog(@"jerry - 1017 notice noticeVCId = %lu unipage = %@", (unsigned long)noticeVCId, self.uniPage);
    NSLog(@"jerry - 1017 notice curOwnerId = %lu unipage = %@", (unsigned long)curOwnerId, self.uniPage);
    if (curOwnerId == noticeVCId) {
        [self.uniPage removeFromSuperview];
        self.uniPage = nil;
    }
}

@end
