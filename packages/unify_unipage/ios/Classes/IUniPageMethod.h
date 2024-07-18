//
//  IUniPageMethod.h
//  unify_unipage
//
//  Created by jerry on 2024/7/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol IUniPageMethod <NSObject>
@optional
/// 处理 UniPage 收到的 Flutter 事件
/// - Parameters:
///   - methodName: 方法名 / 事件名
///   - args: 收到的参数
- (id)onMethodCall:(NSString*)methodName params:(NSDictionary *)args;

@end

NS_ASSUME_NONNULL_END
