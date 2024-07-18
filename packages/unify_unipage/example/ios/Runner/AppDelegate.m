#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
#import "UnifyUnipagePlugin.h"
#import "UniPageDemo.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // The 'registerUniPage: viewType:' method of UnifyUnipagePlugin must be called before the 'registerWithRegistry:' method of GeneratedPluginRegistry
  [UnifyUnipagePlugin registerUniPage:[UniPageDemo class] viewType:@"demo"];
  [GeneratedPluginRegistrant registerWithRegistry:self];

  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
