//
//  QRScanViewController.h
//  WLQRScan
//
//  Created by Json on 16/12/26.
//  Copyright © 2016年 Json. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QRScanViewController : UIViewController

#if NS_BLOCKS_AVAILABLE
@property (nonatomic, copy) void(^qrUrlBlock)(NSString *url);
#endif

@end
