//
//  QRScanView.m
//  WLQRScan
//
//  Created by Json on 16/12/26.
//  Copyright © 2016年 Json. All rights reserved.
//

#import "QRScanView.h"
#import "QRUtil.h"

@interface QRScanView ()
{
    UIImageView *qrLine;
    UILabel *qrLabel;
    CGFloat qrLineY;
}

@end

@implementation QRScanView

- (instancetype)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (!qrLine) {
        [self initQRLine];
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(show) userInfo:nil repeats:YES];
        self.timer = timer;
        [timer fire];
    }
}

#pragma mark - 上下走动的线
- (void)initQRLine
{
    CGRect screenBounds = [QRUtil screenBounds];
    qrLine = [[UIImageView alloc] initWithFrame:CGRectMake(screenBounds.size.width / 2 - self.transparentArea.width / 2, screenBounds.size.height / 2 - self.transparentArea.height / 2, self.transparentArea.width, 2)];
    qrLine.image = [UIImage imageNamed:@"qr_scan_line"];
    qrLine.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:qrLine];
    qrLineY = qrLine.frame.origin.y;
    
    qrLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, screenBounds.size.height/2-self.transparentArea.height/2+self.transparentArea.width+20.0f, screenBounds.size.width, 30.0f)];
    qrLabel.backgroundColor = [UIColor clearColor];
    qrLabel.text = @"将二维码/条码放入框内，即可自动扫描";
    qrLabel.textColor = [UIColor whiteColor];
    qrLabel.textAlignment = NSTextAlignmentCenter;
    qrLabel.font = [UIFont systemFontOfSize:13.0f];
    [self addSubview:qrLabel];
}

#pragma mark - 定时器的方法
- (void)show
{
    [UIView animateWithDuration:0.02 animations:^{
        CGRect rect = qrLine.frame;
        rect.origin.y = qrLineY;
        qrLine.frame = rect;
        
    } completion:^(BOOL finished) {
        
        CGFloat maxBorder = self.frame.size.height / 2 + self.transparentArea.height / 2 - 4;
        if (qrLineY > maxBorder) {
            qrLineY = self.frame.size.height / 2 - self.transparentArea.height /2;
        }
        qrLineY++;
    }];
}

- (void)drawRect:(CGRect)rect
{
    //整个二维码扫描界面的颜色
    CGSize screenSize = [QRUtil screenBounds].size;
    CGRect screenDrawRect = CGRectMake(0, 0, screenSize.width, screenSize.height);
    
    //中间清空的矩形框
    CGRect clearDrawRect = CGRectMake(screenDrawRect.size.width / 2 - self.transparentArea.width / 2,
                                      screenDrawRect.size.height / 2 - self.transparentArea.height / 2,
                                      self.transparentArea.width,
                                      self.transparentArea.height);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [self addScreenFillRect:ctx rect:screenDrawRect];
    
    [self addCenterClearRect:ctx rect:clearDrawRect];
    
    [self addWhiteRect:ctx rect:clearDrawRect];
    
    [self addCornerLineWithContext:ctx rect:clearDrawRect];
}

- (void)addScreenFillRect:(CGContextRef)ctx rect:(CGRect)rect
{
    CGContextSetRGBFillColor(ctx, 40/255.0, 40/255.0, 40/255.0, 0.5);
    CGContextFillRect(ctx, rect);   //draw the transparent layer
}

- (void)addCenterClearRect:(CGContextRef)ctx rect:(CGRect)rect
{
    CGContextClearRect(ctx, rect);  //clear the center rect  of the layer
}

- (void)addWhiteRect:(CGContextRef)ctx rect:(CGRect)rect
{
    CGContextStrokeRect(ctx, rect);
    CGContextSetRGBStrokeColor(ctx, 1, 1, 1, 1);
    CGContextSetLineWidth(ctx, 0.8);
    CGContextAddRect(ctx, rect);
    CGContextStrokePath(ctx);
}

- (void)addCornerLineWithContext:(CGContextRef)ctx rect:(CGRect)rect
{
    //画四个边角
    CGContextSetLineWidth(ctx, 2);
    CGContextSetRGBStrokeColor(ctx, 83/255.0, 239/255.0, 111/255.0, 1);//绿色
    
    //左上角
    CGPoint poinsTopLeftA[] = {
        CGPointMake(rect.origin.x+0.7, rect.origin.y),
        CGPointMake(rect.origin.x+0.7, rect.origin.y + 15)
    };
    
    CGPoint poinsTopLeftB[] = {CGPointMake(rect.origin.x, rect.origin.y +0.7), CGPointMake(rect.origin.x + 15, rect.origin.y+0.7)};
    [self addLine:poinsTopLeftA pointB:poinsTopLeftB ctx:ctx];
    
    //左下角
    CGPoint poinsBottomLeftA[] = {CGPointMake(rect.origin.x+ 0.7, rect.origin.y + rect.size.height - 15), CGPointMake(rect.origin.x +0.7, rect.origin.y + rect.size.height)};
    CGPoint poinsBottomLeftB[] = {CGPointMake(rect.origin.x, rect.origin.y + rect.size.height - 0.7), CGPointMake(rect.origin.x+0.7 +15, rect.origin.y + rect.size.height - 0.7)};
    [self addLine:poinsBottomLeftA pointB:poinsBottomLeftB ctx:ctx];
    
    //右上角
    CGPoint poinsTopRightA[] = {CGPointMake(rect.origin.x+ rect.size.width - 15, rect.origin.y+0.7), CGPointMake(rect.origin.x + rect.size.width, rect.origin.y +0.7)};
    CGPoint poinsTopRightB[] = {CGPointMake(rect.origin.x+ rect.size.width-0.7, rect.origin.y), CGPointMake(rect.origin.x + rect.size.width-0.7, rect.origin.y + 15 +0.7)};
    [self addLine:poinsTopRightA pointB:poinsTopRightB ctx:ctx];
    
    CGPoint poinsBottomRightA[] = {CGPointMake(rect.origin.x+ rect.size.width -0.7, rect.origin.y+rect.size.height+ -15), CGPointMake(rect.origin.x-0.7 + rect.size.width, rect.origin.y +rect.size.height)};
    CGPoint poinsBottomRightB[] = {CGPointMake(rect.origin.x+ rect.size.width - 15, rect.origin.y + rect.size.height-0.7), CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height - 0.7)};
    [self addLine:poinsBottomRightA pointB:poinsBottomRightB ctx:ctx];
    CGContextStrokePath(ctx);
}

- (void)addLine:(CGPoint[])pointA pointB:(CGPoint[])pointB ctx:(CGContextRef)ctx
{
    CGContextAddLines(ctx, pointA, 2);
    CGContextAddLines(ctx, pointB, 2);
}

- (void)dealloc
{
    [self.timer invalidate];
    self.timer = nil;
}

@end
