//
//  UniPageContainer.h
//  unify_uni_page
//
//  Created by jerry on 2024/10/17.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import "UniPageProtocol.h"

NS_ASSUME_NONNULL_BEGIN
@class UniPage;

@interface UniPageContainer : NSObject<FlutterPlatformView, UniPageProtocol>
- (instancetype)initWithWithFrame:(CGRect)frame
                         viewType:(NSString*)viewType
                   viewIdentifier:(int64_t)viewId
                        arguments:(NSDictionary *)args
                  binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger;

- (void)setupUniPage:(UniPage*)uniPage;

@end

NS_ASSUME_NONNULL_END
