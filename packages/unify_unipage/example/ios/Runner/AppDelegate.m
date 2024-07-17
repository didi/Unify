#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
#import "UniPageRegister.h"
#import "UniPageDemo.h"

@interface FlutterAppDelegate (UnifyUniPage)
- (FlutterViewController*)rootFlutterViewController;
@end
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation FlutterAppDelegate (UnifyUniPage)
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  FlutterViewController *flutterVC = [self rootFlutterViewController];
  [GeneratedPluginRegistrant registerWithRegistry:self];
  [UniPageRegister registerUniPage:[UniPageDemo class] pageType:@"demo"];
  [UniPageRegister attachToEngine:flutterVC.engine];
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
