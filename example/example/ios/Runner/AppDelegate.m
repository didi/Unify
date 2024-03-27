#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"

#import "LocationInfoService.h"
#import "LocationInfoModel.h"

#import "HUFUniAPI.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [GeneratedPluginRegistrant registerWithRegistry:self];
    
    [HUFUniAPI loadExportClass];
    
    [self didLocationUpdate];
    
    FlutterViewController *flutterVC = (FlutterViewController*)[UIApplication sharedApplication].delegate.window.rootViewController;
    [self didLoadFlutterEngine:flutterVC.engine];
    
    // Override point for customization after application launch.
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
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

- (void)didLoadFlutterEngine:(FlutterEngine *)engine {
    [LocationInfoService setup:engine.binaryMessenger];
}

- (void)updateLatitude:(double)lat longitude:(double)lng {
    LocationInfoModel *model = [LocationInfoModel new];
    model.lat = @(lat);
    model.lng = @(lng);
    [LocationInfoService updateLocationInfo:model];
}

@end
