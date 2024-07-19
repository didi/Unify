//
//  UniPage.h
//  unify_unipage
//
//  Created by jerry on 2024/7/16.
//

#import <UIKit/UIKit.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface UniPage : UIView<FlutterPlatformView>

- (instancetype)initWithWithFrame:(CGRect)frame
                         viewType:(NSString*)viewType
                   viewIdentifier:(int64_t)viewId
                        arguments:(NSDictionary *)args
                  binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger;

- (void)pushNamed:(NSString*)routePath param:(NSDictionary*)args;

- (void)pop:(id)result;

/// create生命周期，用户通过override此接口创建原生视图元素
- (void)onCreate;

/// 销毁生命周期，可以通过override此接处理销毁后续工作
- (void)onDispose;

/// 获取viewId
- (int64_t)getViewId;

/// 获取Flutter传递过来的嵌原生页面参数
- (NSDictionary*)getCreationParams;

/// 获取UniPage对应的 viewType
- (NSString*)getViewType;


/// 调用指定的 Flutter 侧方法，并向其传递指定参数
/// - Parameters:
///   - methodName: 要调用的 Flutter 侧方法名
///   - params: 传递的参数。注意：参数必须是此Channel关联的编解码器支持的类型
- (void)invoke:(NSString*)methodName arguments:(id _Nullable)params;


/// 调用指定的 Flutter 侧方法，并向其传递指定参数，可异步接收返回结果
/// - Parameters:
///   - methodName: 要调用的 Flutter 侧方法名
///   - params: 传递的参数。注意：参数必须是此Channel关联的编解码器支持的类型
///   - callback: 接收异步结果而使用的回调
- (void)invoke:(NSString*)methodName
     arguments:(id _Nullable)params
        result:(FlutterResult _Nullable)callback;

/// 处理 UniPage 收到的 Flutter 事件
/// - Parameters:
///   - methodName: 方法名 / 事件名
///   - args: 收到的参数
- (id)onMethodCall:(NSString*)methodName params:(NSDictionary *)args;

@end

NS_ASSUME_NONNULL_END
