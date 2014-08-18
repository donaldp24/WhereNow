//
// Created by Martin Ceperley on 1/31/14.
//

#import <Foundation/Foundation.h>

@interface UIImage (Alpha)
- (BOOL)hasAlpha;
- (UIImage *)imageWithAlpha;
- (UIImage *)transparentBorderImage:(NSUInteger)borderSize;
@end
