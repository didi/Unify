//
//  UniCallbackTestServiceVendor.m
//  Runner
//
//  Created by jerry on 2024/5/8.
//

#import "UniCallbackTestServiceVendor.h"
#import <Flutter/Flutter.h>
#import "LocationInfoModel.h"
#import "UFUniAPI.h"

@interface UniCallbackTestServiceVendor ()
@property(nonatomic, strong) OnDoCallbackAction0Callback* action0Callback;
@end

@implementation UniCallbackTestServiceVendor
UNI_EXPORT(UniCallbackTestServiceVendor)

-(instancetype)init {
    if (self = [super init]) {
        // binaryMessenger可通过Flutter Engine进行获取
        FlutterViewController *flutterVC = (FlutterViewController*)[UIApplication sharedApplication].delegate.window.rootViewController;
        UniCallBackTestServiceSetup(flutterVC.binaryMessenger, self);
        [self didLocationUpdate];
    }
    return self;
}

- (void)didLocationUpdate {
    dispatch_queue_t queue1 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue1);
    self.timer = timer;
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        int value = arc4random() % 200;
        double latitude = value / 2.0;
        double longitude = value/ 4.0;
        
        [self updateLatitude:latitude longitude:longitude];
    });
    dispatch_resume(timer);
}

- (void)updateLatitude:(double)lat longitude:(double)lng {
    LocationInfoModel *model = [LocationInfoModel new];
    model.lat = @(lat);
    model.lng = @(lng);
    
    if (self.action0Callback) {
        [self.action0Callback onEvent:model];
    }
}


#pragma mark - UniCallBackTestService

/*
  更新定位信息
*/
- (void)doCallbackAction0:(OnDoCallbackAction0Callback*)callback error:(FlutterError *_Nullable *_Nonnull)error {
    self.action0Callback = callback;
}

- (void)doCallbackAction1:(OnDoCallbackAction1Callback*)callback error:(FlutterError *_Nullable *_Nonnull)error {
    if (callback) {
        [callback onEvent:@"I come from the function doCallbackAction1"];
    }
}

@end
