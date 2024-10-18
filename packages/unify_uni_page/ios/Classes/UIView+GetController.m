//
//  UIView+GetController.m
//  unify_uni_page
//
//  Created by jerry on 2024/10/17.
//

#import "UIView+GetController.h"

@implementation UIView (GetController)

- (UIViewController *)currentController {
    UIResponder *next = [self nextResponder];
    do {
        if ([next isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)next;
        }
        next = [next nextResponder];
    } while (next != nil);
    return nil;
}

@end
