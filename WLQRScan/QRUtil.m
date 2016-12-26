//
//  QRUtil.m
//  WLQRScan
//
//  Created by Json on 16/1/13.
//  Copyright © 2016年 Json. All rights reserved.
//

#import "QRUtil.h"
#import <ZXingObjC/ZXingObjC.h>
#import "qrencode.h"
@implementation QRUtil

/**
 *  从图片中读取二维码  这是iOS7以后的方法
 *
 *  @param qrImage 一张二维码图片
 *
 *  @return 二维码信息
 */
+ (NSString *)scQRReaderForImage:(UIImage *)qrImage
{
    if (qrImage == nil) {
        return nil;
    }
    ZXLuminanceSource *source = [[ZXCGImageLuminanceSource alloc] initWithCGImage:qrImage.CGImage];
    ZXBinaryBitmap *bitmap = [ZXBinaryBitmap binaryBitmapWithBinarizer:[ZXHybridBinarizer binarizerWithSource:source]];
    
    NSError *error = nil;
    
    ZXDecodeHints *hints = [ZXDecodeHints hints];
    
    ZXMultiFormatReader *reader = [ZXMultiFormatReader reader];
    ZXResult *result = [reader decode:bitmap
                                hints:hints
                                error:&error];
    // The coded result as a string. The raw data can be accessed with
    // result.rawBytes and result.length.
    return result.text;
}

/**
 *  从图片中读取二维码  这是iOS8以后的方法
 *
 *  @param qrImage 一张二维码图片
 *
 *  @return 二维码信息
 */
+ (NSString *)scQRReaderiOS8ForImage:(UIImage *)qrImage NS_AVAILABLE_IOS(8_0)
{
    if (qrImage == nil) {
        return nil;
    }
    UIImage *srcImage = qrImage;
    CIContext *context = [CIContext contextWithOptions:nil];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:context options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    CIImage *image = [CIImage imageWithCGImage:srcImage.CGImage];
    NSArray *features = [detector featuresInImage:image];
    CIQRCodeFeature *feature = [features firstObject];
    NSString *result = feature.messageString;
    return result;
}

/**
 *  根据给定的字符串生成一个给定尺寸的二维码image 方法1
 *
 *  @param qrString  二维码的内容
 *  @param imageSize 二维码生成后的尺寸大小
 *
 *  @return 二维码
 */
+ (UIImage *)scQRCodeForString:(NSString *)qrString size:(CGFloat)imageSize
{
    return [QRUtil scQRCodeForString:qrString size:imageSize fillColor:[UIColor blackColor] backColor:[UIColor whiteColor]];
}

/**
 *  根据给定的字符串生成一个给定尺寸的二维码image 方法2
 *
 *  @param qrString  二维码的内容
 *  @param imageSize 二维码生成后的尺寸大小
 *
 *  @return 二维码
 */
+ (UIImage *)zxQRCodeForString:(NSString *)qrString size:(CGFloat)imageSize
{
    if (qrString.length == 0) {
        return nil;
    }
    if (imageSize < 10.0) {
        return nil;
    }
    NSError *error = nil;
    ZXMultiFormatWriter *writer = [ZXMultiFormatWriter writer];
    ZXBitMatrix *result = [writer encode:qrString
                                  format:kBarcodeFormatQRCode
                                   width:imageSize
                                  height:imageSize
                                   error:&error];
    if (result) {
        CGImageRef image = [[ZXImage imageWithMatrix:result] cgimage];
        UIImage *qrImage = [UIImage imageWithCGImage:image];
        // This CGImageRef image can be placed in a UIImage, NSImage, or written to a file.
        return qrImage;
    } else {
        //NSString *errorMessage = [error localizedDescription];
        return nil;
    }
    return nil;
}

/**
 *  根据给定的字符串生成一个给定尺寸和填充颜色的二维码image 方法3
 *
 *  @param qrString  二维码的内容
 *  @param imageSize 二维码生成后的尺寸大小
 *  @param fillColor 二维码填充颜色
 *
 *  @return 二维码
 */
+ (UIImage *)mdQRCodeForString:(NSString *)qrString size:(CGFloat)imageSize fillColor:(UIColor *)fillColor
{
    if (qrString.length == 0) {
        return nil;
    }
    if (imageSize < 10.0) {
        return nil;
    }
    // generate QR
    QRcode *code = QRcode_encodeString([qrString UTF8String], 0, QR_ECLEVEL_L, QR_MODE_8, 1);
    if (!code) {
        return nil;
    }
    
    CGFloat size = imageSize * [[UIScreen mainScreen] scale];
    if (code->width > size) {
        printf("Image size is less than qr code size (%d)\n", code->width);
        return nil;
    }
    
    // create context
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // The constants for specifying the alpha channel information are declared with the CGImageAlphaInfo type but can be passed to this parameter safely.
    
    CGContextRef ctx = CGBitmapContextCreate(0, size, size, 8, size * 4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    
    CGAffineTransform translateTransform = CGAffineTransformMakeTranslation(0, -size);
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(1, -1);
    CGContextConcatCTM(ctx, CGAffineTransformConcat(translateTransform, scaleTransform));
    
    // draw QR on this context
    [self mdDrawQRCode:code context:ctx size:size fillColor:fillColor];
    
    // get image
    CGImageRef qrCGImage = CGBitmapContextCreateImage(ctx);
    UIImage * qrImage = [UIImage imageWithCGImage:qrCGImage];
    
    // free memory
    CGContextRelease(ctx);
    CGImageRelease(qrCGImage);
    CGColorSpaceRelease(colorSpace);
    QRcode_free(code);
    return qrImage;
}

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
+ (UIImage *)scQRCodeForString:(NSString *)qrString size:(CGFloat)imageSize fillColor:(UIColor *)fillColor backColor:(UIColor *)backColor
{
    if (qrString.length == 0) {
        return nil;
    }
    if (imageSize < 10.0) {
        return nil;
    }
    if (!fillColor) {
        fillColor = [UIColor blackColor];
    }
    if (!backColor) {
        backColor = [UIColor whiteColor];
    }
    NSData *stringData = [qrString dataUsingEncoding:NSUTF8StringEncoding];
    
    //生成
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
    
    //上色
    CIFilter *colorFilter = [CIFilter filterWithName:@"CIFalseColor"
                                       keysAndValues:
                             @"inputImage",qrFilter.outputImage,
                             @"inputColor0",[CIColor colorWithCGColor:fillColor.CGColor],
                             @"inputColor1",[CIColor colorWithCGColor:backColor.CGColor],
                             nil];
    
    CIImage *qrImage = colorFilter.outputImage;
    
    //绘制
    CGSize imgSize = CGSizeMake(imageSize, imageSize);
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:qrImage fromRect:qrImage.extent];
    UIGraphicsBeginImageContext(imgSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
    UIImage *codeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRelease(cgImage);
    return codeImage;
}

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
+ (UIImage *)scQRCodeForString:(NSString *)qrString size:(CGFloat)imageSize fillColor:(UIColor *)fillColor backColor:(UIColor *)backColor subImage:(UIImage *)subImage
{
    UIImage *qrImage = [QRUtil scQRCodeForString:qrString size:imageSize fillColor:fillColor backColor:backColor];
    if (subImage) {
        return [QRUtil addSubImage:qrImage sub:subImage];
    }
    return qrImage;
}
#pragma mark - private
+ (UIImage *)addSubImage:(UIImage *)img sub:(UIImage *)subImage
{
    //get image width and height
    NSInteger w = img.size.width;
    NSInteger h = img.size.height;
    NSInteger subWidth = subImage.size.width;
    NSInteger subHeight = subImage.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    //create a graphic context with CGBitmapContextCreate
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
    CGContextDrawImage(context, CGRectMake( (w-subWidth)/2, (h - subHeight)/2, subWidth, subHeight), [subImage CGImage]);
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return [UIImage imageWithCGImage:imageMasked];
    //  CGContextDrawImage(contextRef, CGRectMake(100, 50, 200, 80), [smallImg CGImage]);
}
+ (void)mdDrawQRCode:(QRcode *)code context:(CGContextRef)ctx size:(CGFloat)size fillColor:(UIColor *)fillColor
{
    int margin = 0;
    unsigned char *data = code->data;
    int width = code->width;
    int totalWidth = width + margin * 2;
    int imageSize = (int)floorf(size);
    
    // @todo - review float->int stuff
    int pixelSize = imageSize / totalWidth;
    if (imageSize % totalWidth) {
        pixelSize = imageSize / width;
        margin = (imageSize - width * pixelSize) / 2;
    }
    
    CGRect rectDraw = CGRectMake(0.0f, 0.0f, pixelSize, pixelSize);
    // draw
    CGContextSetFillColorWithColor(ctx, fillColor.CGColor);
    for(int i = 0; i < width; ++i) {
        for(int j = 0; j < width; ++j) {
            if(*data & 1) {
                rectDraw.origin = CGPointMake(margin + j * pixelSize, margin + i * pixelSize);
                CGContextAddRect(ctx, rectDraw);
            }
            ++data;
        }
    }
    CGContextFillPath(ctx);
}

+ (AVCaptureVideoOrientation)videoOrientationFromCurrentDeviceOrientation
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait) {
        return AVCaptureVideoOrientationPortrait;
    } else if (orientation == UIInterfaceOrientationLandscapeLeft) {
        return AVCaptureVideoOrientationLandscapeLeft;
    } else if (orientation == UIInterfaceOrientationLandscapeRight) {
        return AVCaptureVideoOrientationLandscapeRight;
    } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
        return AVCaptureVideoOrientationPortraitUpsideDown;
    }
    return AVCaptureVideoOrientationPortrait;
}

+ (CGRect)screenBounds
{
    UIScreen *screen = [UIScreen mainScreen];
    if (![screen respondsToSelector:@selector(fixedCoordinateSpace)] && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        return CGRectMake(0.0, 0.0, screen.bounds.size.height, screen.bounds.size.width);
    }
    return screen.bounds;
}

+ (void)playBeep
{
    SystemSoundID soundID;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"noticeMusic"ofType:@"wav"];
    if (path) {
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundID);
        //把需要销毁的音效文件的ID传递给它既可销毁
        //AudioServicesDisposeSystemSoundID(soundID);
        //下面的两个函数都可以用来播放音效文件，第一个函数伴随有震动效果
        //AudioServicesPlayAlertSound(soundID);
        AudioServicesPlaySystemSound(soundID);
    }
    // Vibrate  震动效果
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}
@end
