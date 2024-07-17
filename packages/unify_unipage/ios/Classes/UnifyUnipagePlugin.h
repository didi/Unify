#import <Flutter/Flutter.h>

@interface UnifyUnipagePlugin : NSObject<FlutterPlugin>

///  注册 UniPage 类
/// - Parameters:
///   - clsName: UniPage 派生类
///   - pageType:  对齐 Flutter 的 viewType
+ (void)registerUniPage:(Class)clsName viewType:(NSString*)viewType;

@end
