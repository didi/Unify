//
//  DeviceInfoServiceVendor.m
//  Runner
//
//  Created by jerry on 2023/10/8.
//

#import "DeviceInfoServiceVendor.h"
#import <Flutter/Flutter.h>
#import "DeviceInfoModel.h"
#import "UDUniAPI.h"

@implementation DeviceInfoServiceVendor
UNI_EXPORT(DeviceInfoServiceVendor)

-(instancetype)init {
    if (self = [super init]) {
        // binaryMessenger可通过Flutter Engine进行获取
        FlutterViewController *flutterVC = (FlutterViewController*)[UIApplication sharedApplication].delegate.window.rootViewController;
        DeviceInfoServiceSetup(flutterVC.binaryMessenger, self);
    }
    return self;
}

#pragma mark - DeviceInfoService协议 实现
/*
  获取设备信息
*/
- (void)getDeviceInfo:(void(^)(DeviceInfoModel* result))success fail:(void(^)(FlutterError* error))fail {
    DeviceInfoModel *model = [DeviceInfoModel new];
    model.osVersion = [@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]];
    model.memory = [self getTotalMemorySize];
    model.plaform = [[UIDevice currentDevice] model];
    if (success) {
        success(model);
    } else if (fail) {
        FlutterError *err = [FlutterError errorWithCode:@"-1000" message:@"getDeviceInfo fail!" details:@""];
        fail(err);
    }
}

- (NSString *)getTotalMemorySize {
    NSInteger KB = 1024;
    NSInteger MB = KB*KB;
    NSInteger GB = MB*KB;
    long long fileSize = [NSProcessInfo processInfo].physicalMemory;

    if (fileSize < 10) return @"0 B";
    else if (fileSize < KB) return @"< 1 KB";
    else if (fileSize < MB) return [NSString stringWithFormat:@"%.2f KB",((CGFloat)fileSize)/KB];
    else if (fileSize < GB)return [NSString stringWithFormat:@"%.2f MB",((CGFloat)fileSize)/MB];
    else return [NSString stringWithFormat:@"%.2f GB",((CGFloat)fileSize)/GB];
}
@end
