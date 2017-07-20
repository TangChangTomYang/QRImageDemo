//
//  UIImage+QRCodeExtension.h
//  我的二维码
//
//  Created by 　yangrui on 2017/7/12.
//  Copyright © 2017年 　yangrui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (QRCodeExtension)



/**
 *  1.生成一个二维码
 *
 *  @param string 字符串
 *  @param width  二维码宽度
 */
+ (UIImage *_Nonnull)codeImageWithString:(NSString *_Nullable)string
                                        size:(CGFloat)width;

/**
 *  2.生成一个二维码
 *
 *  @param string 字符串
 *  @param width  二维码宽度
 *  @param color  二维码颜色
 */
+ (UIImage *_Nonnull)codeImageWithString:(NSString *_Nullable)string
                                        size:(CGFloat)width
                                       color:(UIColor *_Nullable)color;
/**
 *  3.生成一个二维码
 *
 *  @param string    字符串
 *  @param width     二维码宽度
 *  @param color     二维码颜色
 *  @param logo      头像
 *  @param logoWidth 头像宽度，建议宽度小于二维码宽度的1/4
 */
+ (UIImage *_Nonnull)codeImageWithString:(NSString *_Nullable)string
                                   width:(CGFloat)width
                                   color:(UIColor *_Nullable)color
                                    logo:(UIImage *_Nullable)logo
                               logoWidth:(CGFloat)logoWidth;


/**
 *  4.生成一个二维码 带logo  logo有个边框
 *
 *  @param string    字符串
 *  @param width     二维码宽度
 *  @param color     二维码颜色
 *  @param logo      头像
 *  @param logoWidth 头像宽度，建议宽度小于二维码宽度的1/4
 */

+ (UIImage *_Nonnull)codeImageWithString:(NSString *_Nullable)string
                                   width:(CGFloat)width
                                   color:(UIColor *_Nullable)color
                                    logo:(UIImage *_Nullable)logo
                               logoWidth:(CGFloat)logoWidth
                         logoBorderColor:(UIColor *_Nullable)logoBorderColor;



/**生成圆角 border 图片*/
+ (UIImage *_Nullable)clipImage:(UIImage *_Nullable)rawImage  toRoundImageSize:(CGFloat) size  borderColor:(UIColor *_Nullable)borderColor;


@end
