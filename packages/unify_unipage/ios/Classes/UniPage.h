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
                   viewIdentifier:(int64_t)viewId
                        arguments:(id _Nullable)args
                  binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger;

- (void)pushNamed:(NSString*)routePath param:(id)args;

- (void)pop:(id)result;

/// create生命周期，用户通过override此接口创建原生视图
- (UIView *)onCreate;


/// 销毁生命周期，可以通过override此接处理销毁后续工作
- (void)onDispose;

/// 获取viewId
- (int64_t)getViewId;

/// 获取Flutter传递过来的嵌原生页面参数
- (id)getCreationParams;

@end

NS_ASSUME_NONNULL_END
