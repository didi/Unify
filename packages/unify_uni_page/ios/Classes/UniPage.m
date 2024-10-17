//
//  UniPage.m
//  unify_uni_page
//
//  Created by jerry on 2024/7/16.
//

#import "UniPage.h"
#import "UniPageConstants.h"
#import "UIView+GetController.h"

@interface UniPage()

@property (nonatomic, assign) BOOL isPosted;
@property (nonatomic, assign) NSUInteger ownerId;

@end

@implementation UniPage

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"jerry - 1017 dealloc UniPage: %@", self);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!self.isPosted) {
        [self postCreate];
        self.isPosted = YES;
    }
}

#pragma - public methods

- (void)pushNamed:(NSString*)routePath param:(NSDictionary *)args {
    NSAssert(routePath != nil, @"routePath cannot be nil");
    NSAssert(args != nil, @"args cannot be nil");

    if (self.delegate && [self.delegate respondsToSelector:@selector(pushNamed:param:)]) {
        [self.delegate pushNamed:routePath param: args];
    }
}

- (void)pop:(id)result {
    NSAssert(result != nil, @"result cannot be nil");
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(pop:)]) {
        [self.delegate pop:result];
    }
}

- (void)invoke:(NSString*)methodName arguments:(id _Nullable)params {
    [self invoke:methodName arguments:params result:nil];
}

- (void)invoke:(NSString*)methodName
     arguments:(id _Nullable)params
        result:(FlutterResult _Nullable)callback {
    NSAssert(methodName != nil, @"methodName cannot be nil");
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(invoke:arguments:result:)]) {
        [self.delegate invoke:methodName arguments:params result:callback];
    }
}

- (id)onMethodCall:(NSString*)methodName params:(NSDictionary *)args {
    return nil;
}

- (int64_t)getViewId {
    int64_t viewId = -1;
    if (self.delegate && [self.delegate respondsToSelector:@selector(getViewId)]) {
        viewId = [self.delegate getViewId];
    }
    return viewId;
}

- (NSDictionary*)getCreationParams {
    NSDictionary *params;
    if (self.delegate && [self.delegate respondsToSelector:@selector(getCreationParams)]) {
        params = [self.delegate getCreationParams];
    }
    return params;
}

- (NSString*)getViewType {
    NSString *viewType;
    if (self.delegate && [self.delegate respondsToSelector:@selector(getViewType)]) {
        viewType = [self.delegate getViewType];
    }
    return viewType;
}


- (void)onCreate {
    
}

- (void)postCreate {
    self.ownerId = [[self currentController] hash];
}

- (void)onForeground {
    
}

- (void)onBackground {
    
}

- (void)onDispose {
    
}

- (NSUInteger)getOwnerId {
    return self.ownerId;
}

#pragma mark - Notifications

- (void)applicationWillEnterForeground:(NSNotification*)notification {
  [self onForeground];
}

- (void)applicationDidEnterBackground:(NSNotification*)notification {
  [self onBackground];
}

@end
