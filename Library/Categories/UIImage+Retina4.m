//
//  UIImage+Retina4.m
//  Knotable
//
//  Created by Martin Ceperley on 12/16/13.
//
//

#import "UIImage+Retina4.h"
#import <objc/runtime.h>

//static Method origImageNamedMethod = nil;

@implementation UIImage (Retina4)

/*
+ (void)initialize {
    if (origImageNamedMethod == nil) {
        origImageNamedMethod = class_getClassMethod(self, @selector(imageNamed:));
        method_exchangeImplementations(origImageNamedMethod,
                                       class_getClassMethod(self, @selector(retina4ImageNamed:)));
    }
}
 */

+ (UIImage *)retina4ImageNamed:(NSString *)imageName {
    NSMutableString *imageNameMutable = [imageName mutableCopy];
    NSRange retinaAtSymbol = [imageName rangeOfString:@"@"];
    if (retinaAtSymbol.location != NSNotFound) {
        [imageNameMutable insertString:@"-568h" atIndex:retinaAtSymbol.location];
    } else {
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        if ([UIScreen mainScreen].scale == 2.f && screenHeight == 568.0f) {
            NSRange dot = [imageName rangeOfString:@"."];
            if (dot.location != NSNotFound) {
                [imageNameMutable insertString:@"-568h@2x" atIndex:dot.location];
            } else {
                [imageNameMutable appendString:@"-568h@2x"];
            }
        }
    }
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:imageNameMutable ofType:@""];
    if (imagePath) {
        return [UIImage imageNamed:imageNameMutable];
    } else {
        return [UIImage imageNamed:imageName];
    }
    return nil;
}

@end
