//
//  UniPageRegister.h
//  unify_unipage
//
//  Created by jerry on 2024/7/16.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface UniPageRegister : NSObject

///  注册 UniPage 类
/// - Parameters:
///   - clsName: UniPage 派生类
///   - pageType:  页面类型，对齐 Flutter 的 viewType
+ (void)registerUniPage:(Class)clsName pageType:(NSString*)pageType;


/// 关联 engine
/// - Parameter engine: FlutterEngine 实例
+ (void)attachToEngine:(FlutterEngine *)engine;

+ (FlutterMethodChannel*)channel;

@end

NS_ASSUME_NONNULL_END
