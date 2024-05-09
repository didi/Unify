//
//  UniCallbackTestServiceVendor.h
//  Runner
//
//  Created by jerry on 2024/5/8.
//

#import <Foundation/Foundation.h>
#import "UniCallbackTestService.h"

NS_ASSUME_NONNULL_BEGIN

@interface UniCallbackTestServiceVendor : NSObject<UniCallBackTestService>
@property (nonatomic, strong) dispatch_source_t timer;
@end

NS_ASSUME_NONNULL_END
