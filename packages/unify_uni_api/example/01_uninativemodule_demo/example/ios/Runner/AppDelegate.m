#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
#import "UDUniAPI.h"
#import "DeviceInfoModel.h"
#import "DeviceInfoServiceVendor.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  [UDUniAPI loadExportClass];

  // 在原生侧使用 Unify 生成的接口 getDeviceInfo:fail:
  DeviceInfoServiceVendor* vendor = [UDUniAPI get:@"DeviceInfoServiceVendor"];
  if (vendor && [vendor respondsToSelector:@selector(getDeviceInfo:fail:)]) {
    [vendor getDeviceInfo:^(DeviceInfoModel * _Nonnull result) {
        NSLog(@"result = %@", result.toMap);
    } fail:nil];
  }
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
