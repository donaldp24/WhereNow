//
// Created by Martin Ceperley on 1/31/14.
//

#import "UIImage+RoundedCorner.h"
#import "UIImage+Alpha.h"


@interface UIImage ()
- (void)addRoundedRectToPath:(CGRect)rect context:(CGContextRef)context ovalWidth:(CGFloat)ovalWidth ovalHeight:(CGFloat)ovalHeight;
@end

@implementation UIImage (RoundedCorner)

// Creates a copy of this image with rounded corners
// If borderSize is non-zero, a transparent border of the given size will also be added
// Original author: Björn Sållarp. Used with permission. See: http://blog.sallarp.com/iphone-uiimage-round-corners/
- (UIImage *)roundedCornerImage:(NSInteger)cornerSize borderSize:(NSInteger)borderSize {
    // If the image does not have an alpha layer, add one
    UIImage *image = [self imageWithAlpha];

    // Build a context that's the same dimensions as the new size
    CGContextRef context = CGBitmapContextCreate(NULL,
            image.size.width,
            image.size.height,
            CGImageGetBitsPerComponent(image.CGImage),
            0,
            CGImageGetColorSpace(image.CGImage),
            CGImageGetBitmapInfo(image.CGImage));

    // Create a clipping path with rounded corners
    CGContextBeginPath(context);
    [self addRoundedRectToPath:CGRectMake(borderSize, borderSize, image.size.width - borderSize * 2, image.size.height - borderSize * 2)
                       context:context
                     ovalWidth:cornerSize
                    ovalHeight:cornerSize];
    CGContextClosePath(context);
    CGContextClip(context);

    // Draw the image to the context; the clipping path will make anything outside the rounded rect transparent
    CGContextDrawImage(context, CGRectMake(0, 0, image.size.width, image.size.height), image.CGImage);

    // Create a CGImage from the context
    CGImageRef clippedImage = CGBitmapContextCreateImage(context);
    CGContextRelease(context);

    // Create a UIImage from the CGImage
    UIImage *roundedImage = [UIImage imageWithCGImage:clippedImage];
    CGImageRelease(clippedImage);

    return roundedImage;
}

#pragma mark -
#pragma mark Private helper methods

// Adds a rectangular path to the given context and rounds its corners by the given extents
// Original author: Björn Sållarp. Used with permission. See: http://blog.sallarp.com/iphone-uiimage-round-corners/
- (void)addRoundedRectToPath:(CGRect)rect context:(CGContextRef)context ovalWidth:(CGFloat)ovalWidth ovalHeight:(CGFloat)ovalHeight {
    if (ovalWidth == 0 || ovalHeight == 0) {
        CGContextAddRect(context, rect);
        return;
    }
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM(context, ovalWidth, ovalHeight);
    CGFloat fw = CGRectGetWidth(rect) / ovalWidth;
    CGFloat fh = CGRectGetHeight(rect) / ovalHeight;
    CGContextMoveToPoint(context, fw, fh/2);
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

#pragma mark - Avatar styles
- (UIImage *)circleImageWithSize:(CGFloat)size
{
    return [self imageAsCircle:YES
                   withDiamter:size
                   borderColor:[UIColor colorWithHue:0.0f saturation:0.0f brightness:0.8f alpha:1.0f]
                   borderWidth:1.0f
                  shadowOffSet:CGSizeMake(0.0f, 1.0f)];
}

- (UIImage *)squareImageWithSize:(CGFloat)size
{
    return [self imageAsCircle:NO
                   withDiamter:size
                   borderColor:[UIColor colorWithHue:0.0f saturation:0.0f brightness:0.8f alpha:1.0f]
                   borderWidth:1.0f
                  shadowOffSet:CGSizeMake(0.0f, 1.0f)];
}

- (UIImage *)imageAsCircle:(BOOL)clipToCircle
               withDiamter:(CGFloat)diameter
               borderColor:(UIColor *)borderColor
               borderWidth:(CGFloat)borderWidth
              shadowOffSet:(CGSize)shadowOffset
{
    // increase given size for border and shadow
    CGFloat increase = diameter * 0.15f;
    CGFloat newSize = diameter + increase;
    
    CGRect newRect = CGRectMake(0.0f,
                                0.0f,
                                newSize,
                                newSize);
    
    // fit image inside border and shadow
    CGRect imgRect = CGRectMake(increase,
                                increase,
                                newRect.size.width - (increase * 2.0f),
                                newRect.size.height - (increase * 2.0f));
    
    UIGraphicsBeginImageContextWithOptions(newRect.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    // draw shadow
    if(!CGSizeEqualToSize(shadowOffset, CGSizeZero))
        CGContextSetShadowWithColor(context,
                                    CGSizeMake(shadowOffset.width, shadowOffset.height),
                                    3.0f,
                                    [UIColor colorWithWhite:0.0f alpha:0.45f].CGColor);
    
    // draw border
    // as circle or square
    CGPathRef borderPath = (clipToCircle) ? CGPathCreateWithEllipseInRect(imgRect, NULL) : CGPathCreateWithRect(imgRect, NULL);
    
    CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
    CGContextSetLineWidth(context, borderWidth);
    CGContextAddPath(context, borderPath);
    CGContextDrawPath(context, kCGPathFillStroke);
    CGPathRelease(borderPath);
    CGContextRestoreGState(context);
    
    // clip to circle
    if(clipToCircle) {
        UIBezierPath *imgPath = [UIBezierPath bezierPathWithOvalInRect:imgRect];
        [imgPath addClip];
    }
    
    [self drawInRect:imgRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
