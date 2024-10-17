#import <Flutter/Flutter.h>

@interface UnifyUniPagePlugin : NSObject<FlutterPlugin>

///  注册 UniPage 类
/// - Parameters:
///   - clsName: UniPage 派生类
///   - pageType:  对齐 Flutter 的 viewType
+ (void)registerUniPage:(Class)clsName viewType:(NSString*)viewType;


/// 注册 Flutter VC将销毁的通知监听
/// - Parameter noticeName: 容器自定义的通知名称
+ (void)registerFlutterViewControllerWillDeallocObserver:(NSString*)noticeName;

@end
