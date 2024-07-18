//
//  AbsUniPageFactory.h
//  unify_unipage
//
//  Created by jerry on 2024/7/16.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@class UniPage;

// 别名定义
typedef UniPage* _Nonnull (^UniPageFactoryCallback)(CGRect frame, int64_t viewId, NSDictionary *args);

@interface AbsUniPageFactory : NSObject<FlutterPlatformViewFactory>

///  UniPage 工厂类
/// - Parameter page: UniPage 对象实例
- (instancetype)init:(UniPageFactoryCallback)block;

@end

NS_ASSUME_NONNULL_END
