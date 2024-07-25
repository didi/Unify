//
//  AbsUniPageFactory.m
//  unify_uni_page
//
//  Created by jerry on 2024/7/16.
//

#import "AbsUniPageFactory.h"
#import "UniPage.h"

@interface AbsUniPageFactory()

@property (nonatomic, copy) UniPageFactoryCallback block;

@end

@implementation AbsUniPageFactory

- (instancetype)init:(UniPageFactoryCallback)block {
    self = [super init];
    if (self) {
        self.block = block;
    }
    return self;
}

#pragma mark - FlutterPlatformViewFactory

- (NSObject<FlutterPlatformView>*)createWithFrame:(CGRect)frame
                                   viewIdentifier:(int64_t)viewId
                                        arguments:(id _Nullable)args {
    return self.block(frame, viewId, args);
}

- (NSObject<FlutterMessageCodec> *)createArgsCodec {
    return [FlutterStandardMessageCodec sharedInstance];
}


@end
