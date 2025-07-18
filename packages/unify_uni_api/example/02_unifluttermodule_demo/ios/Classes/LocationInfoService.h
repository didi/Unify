// =================================================
// Autogenerated from Unify 3.0.2, do not edit directly.
// =================================================

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@protocol FlutterBinaryMessenger;
@class LocationInfoModel;
typedef void (^UniCompleted)(id result); // 这里result可能是nil

// Call flow direction : native -> dart
// Before using the code generated based on the "UniFlutterModule" template, you need to call the setup method to initialize it.
@interface LocationInfoService : NSObject


+ (void)setup:(id<FlutterBinaryMessenger>)binaryMessenger;
+ (void)updateLocationInfo:(LocationInfoModel*)model;

@end

NS_ASSUME_NONNULL_END
