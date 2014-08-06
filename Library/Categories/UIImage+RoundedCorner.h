//
// Created by Martin Ceperley on 1/31/14.
//

#import <Foundation/Foundation.h>

@interface UIImage (RoundedCorner)
- (UIImage *)roundedCornerImage:(NSInteger)cornerSize borderSize:(NSInteger)borderSize;

#pragma mark - Avatar styles
- (UIImage *)circleImageWithSize:(CGFloat)size;
- (UIImage *)squareImageWithSize:(CGFloat)size;

- (UIImage *)imageAsCircle:(BOOL)clipToCircle
               withDiamter:(CGFloat)diameter
               borderColor:(UIColor *)borderColor
               borderWidth:(CGFloat)borderWidth
              shadowOffSet:(CGSize)shadowOffset;
@end
