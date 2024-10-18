//
//  AbsUniPageFactory.h
//  unify_uni_page
//
//  Created by jerry on 2024/7/16.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@class UniPageContainer;

// 别名定义
typedef UniPageContainer* _Nonnull (^UniPageFactoryCallback)(CGRect frame, int64_t viewId, NSDictionary *args);

@interface AbsUniPageFactory : NSObject<FlutterPlatformViewFactory>

///  UniPageContainer 工厂类
/// - Parameter page: UniPageContainer 对象实例
- (instancetype)init:(UniPageFactoryCallback)block;

@end

NS_ASSUME_NONNULL_END
