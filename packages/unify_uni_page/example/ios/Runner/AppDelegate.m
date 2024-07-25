#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
#import "UnifyUniPagePlugin.h"
#import "UniPageDemo.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // The 'registerUniPage: viewType:' method of UnifyUniPagePlugin must be called before the 'registerWithRegistry:' method of GeneratedPluginRegistry
  [UnifyUniPagePlugin registerUniPage:[UniPageDemo class] viewType:@"demo"];
  [GeneratedPluginRegistrant registerWithRegistry:self];

  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
