//
//  QRUtil.h
//  WLQRScan
//
//  Created by Json on 16/1/13.
//  Copyright © 2016年 Json. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@interface QRUtil : NSObject

/**
 *  从图片中读取二维码  这是iOS7以后的方法
 *
 *  @param qrImage 一张二维码图片
 *
 *  @return 二维码信息
 */
+ (NSString *)scQRReaderForImage:(UIImage *)qrImage;

/**
 *  从图片中读取二维码  这是iOS8以后的方法
 *
 *  @param qrImage 一张二维码图片
 *
 *  @return 二维码信息
 */
+ (NSString *)scQRReaderiOS8ForImage:(UIImage *)qrImage NS_AVAILABLE_IOS(8_0);

/**
 *  根据给定的字符串生成一个给定尺寸的二维码image 方法1
 *
 *  @param qrString  二维码的内容
 *  @param imageSize 二维码生成后的尺寸大小
 *
 *  @return 二维码
 */
+ (UIImage *)scQRCodeForString:(NSString *)qrString size:(CGFloat)imageSize;

/**
 *  根据给定的字符串生成一个给定尺寸的二维码image 方法2
 *
 *  @param qrString  二维码的内容
 *  @param imageSize 二维码生成后的尺寸大小
 *
 *  @return 二维码
 */
+ (UIImage *)zxQRCodeForString:(NSString *)qrString size:(CGFloat)imageSize;
/**
 *  根据给定的字符串生成一个给定尺寸和填充颜色的二维码image 方法3
 *
 *  @param qrString  二维码的内容
 *  @param imageSize 二维码生成后的尺寸大小
 *  @param fillColor 二维码填充颜色
 *
 *  @return 二维码
 */
+ (UIImage *)mdQRCodeForString:(NSString *)qrString size:(CGFloat)imageSize fillColor:(UIColor *)fillColor;

/**
 *  根据给定的字符串生成一个给定尺寸和给定颜色的二维码image
 *
 *  @param qrString  二维码的内容
 *  @param imageSize 二维码生成后的尺寸大小
 *  @param fillColor 二维码填充颜色
 *  @param backColor 二维码背景颜色
 *
 *  @return 二维码
 */
+ (UIImage *)scQRCodeForString:(NSString *)qrString size:(CGFloat)imageSize fillColor:(UIColor *)fillColor backColor:(UIColor *)backColor;

/**
 *  生成中间有logo的二维码
 *
 *  @param qrString  二维码的内容
 *  @param imageSize 二维码生成后的尺寸大小
 *  @param fillColor 二维码填充颜色
 *  @param backColor 二维码背景颜色
 *  @param subImage  二维码的子图
 *
 *  @return 带有子图的二维码
 */
+ (UIImage *)scQRCodeForString:(NSString *)qrString size:(CGFloat)imageSize fillColor:(UIColor *)fillColor backColor:(UIColor *)backColor subImage:(UIImage *)subImage;

+ (AVCaptureVideoOrientation)videoOrientationFromCurrentDeviceOrientation;

+ (CGRect)screenBounds;

+ (void)playBeep;
@end
