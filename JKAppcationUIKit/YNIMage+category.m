//
//  YNIMage+category.m
//  JKAppcationUIKit
//
//  Created by qiyun on 16/6/13.
//  Copyright © 2016年 qiyun. All rights reserved.
//

#import "YNIMage+category.h"

@implementation UIImage (YNIMage_category)

- (UIImage *)imageCompressWithScaledToSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [self drawInRect:CGRectMake(0,0,size.width,size.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage*)imageCompressWithScale:(float)scale
{
    CGSize size = self.size;
    CGFloat width = size.width;
    CGFloat height = size.height;
    CGFloat scaledWidth = width * scale;
    CGFloat scaledHeight = height * scale;
    UIGraphicsBeginImageContext(size); // this will crop
    [self drawInRect:CGRectMake(0,0,scaledWidth,scaledHeight)];
    UIImage* newImage= UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

/**
 *  饱和度
 *
 *  @return a image with unsarurated pixels return
 */
- (UIImage *)getImageWithUnsaturatedPixels{
    
    const int RED = 1, GREEN = 2, BLUE = 3;
    
    CGRect imageRect = CGRectMake(0, 0, self.size.width*2, self.size.height*2);
    
    int width = imageRect.size.width, height = imageRect.size.height;
    
    uint32_t * pixels = (uint32_t *) malloc(width*height*sizeof(uint32_t));
    memset(pixels, 0, width * height * sizeof(uint32_t));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [self CGImage]);
    
    for(int y = 0; y < height; y++) {
        
        for(int x = 0; x < width; x++) {
            
            uint8_t * rgbaPixel = (uint8_t *) &pixels[y*width+x];
            uint32_t gray = (0.3*rgbaPixel[RED]+0.59*rgbaPixel[GREEN]+0.11*rgbaPixel[BLUE]);
            
            rgbaPixel[RED] = gray;
            rgbaPixel[GREEN] = gray;
            rgbaPixel[BLUE] = gray;
        }
    }
    
    CGImageRef newImage = CGBitmapContextCreateImage(context);
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(pixels);
    
    UIImage * resultUIImage = [UIImage imageWithCGImage:newImage scale:2 orientation:0];
    CGImageRelease(newImage);
    
    return resultUIImage;
}

- (UIImage *) getImageWithTint:(UIColor *)color withIntensity:(float)alpha {
    CGSize size = self.size;
    
    UIGraphicsBeginImageContextWithOptions(size, FALSE, 2);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self drawAtPoint:CGPointZero blendMode:kCGBlendModeNormal alpha:1.0];
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextSetBlendMode(context, kCGBlendModeOverlay);
    CGContextSetAlpha(context, alpha);
    
    CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(CGPointZero.x, CGPointZero.y, self.size.width, self.size.height));
    
    UIImage * tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tintedImage;
}

+ (unsigned char *)UIImageToByteArray:(UIImage*)image{
    
    unsigned char *imageData = (unsigned char*)(malloc( 4*image.size.width*image.size.height));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGImageRef imageRef = [image CGImage];
    CGContextRef bitmap = CGBitmapContextCreate( imageData,
                                                image.size.width,
                                                image.size.height,
                                                8,
                                                image.size.width*4,
                                                colorSpace,
                                                kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    
    CGContextDrawImage( bitmap, CGRectMake(0, 0, image.size.width, image.size.height), imageRef);
    
    CGContextRelease( bitmap);
    CGColorSpaceRelease( colorSpace);
    
    return imageData;
}

@end
