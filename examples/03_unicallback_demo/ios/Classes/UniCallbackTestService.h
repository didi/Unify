// =================================================
// Autogenerated from Unify 3.0.0, do not edit directly.
// =================================================

#import <Foundation/Foundation.h>

@protocol FlutterBinaryMessenger;
@class FlutterError;
@class LocationInfoModel;

NS_ASSUME_NONNULL_BEGIN

@interface OnDoCallbackAction0Callback : NSObject


- (void)onEvent:(LocationInfoModel*)callback;

@end

@interface OnDoCallbackAction1Callback : NSObject


- (void)onEvent:(NSString*)callback;

@end

/*
 Call flow direction : dart -> native
*/
@protocol UniCallBackTestService


/*
  更新定位信息
*/
- (void)doCallbackAction0:(OnDoCallbackAction0Callback*)callback error:(FlutterError *_Nullable *_Nonnull)error;
- (void)doCallbackAction1:(OnDoCallbackAction1Callback*)callback error:(FlutterError *_Nullable *_Nonnull)error;

@end

extern void UniCallBackTestServiceSetup(id<FlutterBinaryMessenger> binaryMessenger, id<UniCallBackTestService> api);

NS_ASSUME_NONNULL_END