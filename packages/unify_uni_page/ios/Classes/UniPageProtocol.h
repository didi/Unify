//
//  UniPageProtocol.h
//  unify_uni_page
//
//  Created by jerry on 2024/10/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol UniPageProtocol <NSObject>

/// 调用指定的 Flutter 侧方法，并向其传递指定参数，可异步接收返回结果
/// - Parameters:
///   - methodName: 要调用的 Flutter 侧方法名
///   - params: 传递的参数。注意：参数必须是此Channel关联的编解码器支持的类型
///   - callback: 接收异步结果而使用的回调
- (void)invoke:(NSString*)methodName
     arguments:(id _Nullable)params
        result:(FlutterResult _Nullable)callback;

- (void)pushNamed:(NSString*)routePath param:(NSDictionary*)args;

- (void)pop:(id)result;

/// 获取viewId
- (int64_t)getViewId;

/// 获取Flutter传递过来的嵌原生页面参数
- (NSDictionary*)getCreationParams;

/// 获取UniPage对应的 viewType
- (NSString*)getViewType;

@end

NS_ASSUME_NONNULL_END
