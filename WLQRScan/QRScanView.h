//
//  QRScanView.h
//  WLQRScan
//
//  Created by Json on 16/12/26.
//  Copyright © 2016年 Json. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QRScanView : UIView
/**
 *  透明的区域
 */
@property (nonatomic, assign) CGSize transparentArea;
/**
 *  定时器
 */
@property (nonatomic, strong) NSTimer *timer;

@end
