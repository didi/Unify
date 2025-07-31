#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
#import "UFUniAPI.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  FlutterViewController *flutterVC = (FlutterViewController*)[UIApplication sharedApplication].delegate.window.rootViewController;
  [UFUniAPI init:flutterVC.binaryMessenger];
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
