//
//  UIImage+QRCodeExtension.m
//  我的二维码
//
//  Created by 　yangrui on 2017/7/12.
//  Copyright © 2017年 　yangrui. All rights reserved.
//

#import "UIImage+QRCodeExtension.h"

@implementation UIImage (QRCodeExtension)



+ (UIImage *)codeImageWithString:(NSString *)string
                                size:(CGFloat)width
{
    CIImage *ciImage = [UIImage createQRForString:string];
    if (ciImage) {
        return [UIImage createNonInterpolatedUIImageFormCIImage:ciImage
                                                               size:width];
    } else {
        return nil;
    }
}

+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image
                                                    size:(CGFloat)size {
    
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent),
                        size/CGRectGetHeight(extent));
    // 1.创建一个位图图像，绘制到其大小的位图上下文
    size_t width        = CGRectGetWidth(extent) * scale;
    size_t height       = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs  = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil,
                                                   width,
                                                   height,
                                                   8,
                                                   0,
                                                   cs,
                                                   (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context     = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // 2.创建具有内容的位图图像
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    // 3.清理
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return (UIImage*)[UIImage imageWithCGImage:scaledImage];
}

+ (CIImage *)createQRForString:(NSString *)qrString {
    // 1.将字符串转换为UTF8编码的NSData对象
    NSData *stringData = [qrString dataUsingEncoding:NSUTF8StringEncoding];
    // 2.创建filter
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 3.设置内容和纠错级别
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
    // 4.返回CIImage
    return qrFilter.outputImage;
}


void ProviderReleaseData (void *info, const void *data, size_t size){
    free((void*)data);
}

+ (UIImage *_Nonnull)codeImageWithString:(NSString *_Nullable)string
                                        size:(CGFloat)width
                                       color:(UIColor *_Nullable)color;
{
    
    
    UIImage *image = [UIImage codeImageWithString:string size:width];
    
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    CGFloat red     = components[0]*255;
    CGFloat green   = components[1]*255;
    CGFloat blue    = components[2]*255;
    
    const int imageWidth    = image.size.width;
    const int imageHeight   = image.size.height;
    size_t      bytesPerRow = imageWidth * 4;
    uint32_t* rgbImageBuf   = (uint32_t*)malloc(bytesPerRow * imageHeight);
    
    // 1.创建上下文
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf,
                                                 imageWidth,
                                                 imageHeight,
                                                 8,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
    
    // 2.像素转换
    int pixelNum = imageWidth * imageHeight;
    uint32_t* pCurPtr = rgbImageBuf;
    for (int i = 0; i < pixelNum; i++, pCurPtr++){
        if ((*pCurPtr & 0xFFFFFF00) < 0x99999900){
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[3] = red; //0~255
            ptr[2] = green;
            ptr[1] = blue;
        }else{
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[0] = 0;
        }
    }
    
    // 3.生成UIImage
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL,
                                                                  rgbImageBuf,
                                                                  bytesPerRow * imageHeight,
                                                                  ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth,
                                        imageHeight,
                                        8,
                                        32,
                                        bytesPerRow,
                                        colorSpace,
                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little,
                                        dataProvider,
                                        NULL,
                                        true,
                                        kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    UIImage* resultUIImage = (UIImage*)[UIImage imageWithCGImage:imageRef];
    
    // 4.释放
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    return resultUIImage;
}

+ (UIImage *_Nonnull)codeImageWithString:(NSString *_Nullable)string
                                        width:(CGFloat)width
                                       color:(UIColor *_Nullable)color
                                        logo:(UIImage *_Nullable)logo
                                   logoWidth:(CGFloat)logoWidth{
    
    UIImage *bgImage = [UIImage codeImageWithString:string size:width color:color];
    UIGraphicsBeginImageContext(bgImage.size);
    [bgImage drawInRect:CGRectMake(0, 0, bgImage.size.width, bgImage.size.height)];
    
    
    CGFloat lWidth = logoWidth <= (width * 0.25) ? logoWidth : (width * 0.25);
    CGFloat x = (bgImage.size.width - lWidth) * 0.5;
    CGFloat y = (bgImage.size.height - lWidth) * 0.5;
    [logo drawInRect:CGRectMake( x,  y, lWidth,  lWidth)];
    
    UIImage *newImage =  UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *_Nonnull)codeImageWithString:(NSString *_Nullable)string
                                   width:(CGFloat)width
                                   color:(UIColor *_Nullable)color
                                    logo:(UIImage *_Nullable)logo
                               logoWidth:(CGFloat)logoWidth
                         logoBorderColor:(UIColor *_Nullable)logoBorderColor{

    UIImage *newLogo = logo;
    if (logoBorderColor != nil) {
        newLogo = [self  clipImage:logo toRoundImageSize:logoWidth borderColor:logoBorderColor];
    }
    
  
    return   [self codeImageWithString:string width:width color:color logo:newLogo logoWidth:logoWidth];

}







+ (UIImage *)clipImage:(UIImage *)rawImage  toRoundImageSize:(CGFloat) size  borderColor:(UIColor *)borderColor{
    
    
    // 白色border的宽度
    
    CGFloat outerWidth = size/30.0;
    
    // 黑色border的宽度
    CGFloat innerWidth = outerWidth/10000.0;
    
    // 圆角这个就是我觉着的适合的一个值 ，可以自行改
    CGFloat corenerRadius = size/5.0;
    
    
    
    // 为context创建一个区域
    CGRect areaRect = CGRectMake(0, 0, size, size);
    UIBezierPath *areaPath = [UIBezierPath bezierPathWithRoundedRect:areaRect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(corenerRadius, corenerRadius)];
    
    // 因为UIBezierpath划线是双向扩展的 初始位置就不会是（0，0）
    // origin position
    CGFloat outerOrigin = outerWidth/2.0;
    CGFloat innerOrigin = innerWidth/2.0 + outerOrigin/1.2;
    CGRect outerRect = CGRectInset(areaRect, outerOrigin, outerOrigin);
    CGRect innerRect = CGRectInset(outerRect, innerOrigin, innerOrigin);
    
    //  外层path
    UIBezierPath *outerPath = [UIBezierPath bezierPathWithRoundedRect:outerRect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(outerRect.size.width/5.0, outerRect.size.width/5.0)];
    //  内层path
    UIBezierPath *innerPath = [UIBezierPath bezierPathWithRoundedRect:innerRect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(innerRect.size.width/5.0, innerRect.size.width/5.0)];
    // 创建上下文
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(size, size), NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);{
        // 翻转context
        CGContextTranslateCTM(context, 0, size);
        CGContextScaleCTM(context, 1, -1);
        // context  添加 区域path -> 进行裁切画布
        CGContextAddPath(context, areaPath.CGPath);
        CGContextClip(context);
        // context 添加 背景颜色，避免透明背景会展示后面的二维码不美观的。（当然也可以对想遮住的区域进行clear操作，但是我当时写的时候还没有想到）
        CGContextAddPath(context, areaPath.CGPath);
        
        CGContextSetFillColorWithColor(context, borderColor.CGColor);
        CGContextFillPath(context);
        // context 执行画头像
        CGContextDrawImage(context, innerRect, rawImage.CGImage);
        // context 添加白色的边框 -> 执行填充白色画笔
        CGContextAddPath(context, outerPath.CGPath);
        CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
        CGContextSetLineWidth(context, outerWidth);
        CGContextStrokePath(context);
        
        // context 添加黑色的边界假象边框 -> 执行填充黑色画笔
        CGContextAddPath(context, innerPath.CGPath);
        CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
        CGContextSetLineWidth(context, innerWidth);
        CGContextStrokePath(context);
        
    }CGContextRestoreGState(context);
    UIImage *radiusImage  = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return radiusImage;
}


@end
