//
//  QRScanViewController.m
//  WLQRScan
//
//  Created by Json on 16/12/26.
//  Copyright © 2016年 Json. All rights reserved.
//

#import "QRScanViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>
#import "QRUtil.h"
#import "QRScanView.h"

@interface QRScanViewController ()<AVCaptureMetadataOutputObjectsDelegate>

/**设备*/
@property (strong, nonatomic) AVCaptureDevice *device;
/**输入流*/
@property (strong, nonatomic) AVCaptureDeviceInput *input;
/**输出流*/
@property (strong, nonatomic) AVCaptureMetadataOutput *output;
@property (strong, nonatomic) AVCaptureSession *session;
/**预览view*/
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *preview;

@property (strong, nonatomic) QRScanView *qrScanView;

@end

@implementation QRScanViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setQRScanView];
}

#pragma mark - 初始化 View
- (void)setQRScanView
{
    // Device 初始化设备(摄像头)
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    // Input 创建输入流
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    // Output 创建输出流
    _output = [[AVCaptureMetadataOutput alloc] init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    // Session 高质量采集率
    _session = [[AVCaptureSession alloc] init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([_session canAddInput:self.input]) {
        [_session addInput:self.input];
    }
    if ([_session canAddOutput:self.output]) {
        [_session addOutput:self.output];
    }
    AVCaptureConnection *outputConnection = [_output connectionWithMediaType:AVMediaTypeVideo];
    outputConnection.videoOrientation = [QRUtil videoOrientationFromCurrentDeviceOrientation];
    
    // 条码类型 AVMetadataObjectTypeQRCode
    _output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    //增加条形码扫描
    _output.metadataObjectTypes = @[AVMetadataObjectTypeEAN13Code,
                                    AVMetadataObjectTypeEAN8Code,
                                    AVMetadataObjectTypeCode128Code,
                                    AVMetadataObjectTypeQRCode];
    // Preview
    _preview = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _preview.videoGravity = AVLayerVideoGravityResize;
    _preview.frame = [QRUtil screenBounds];
    [self.view.layer insertSublayer:_preview atIndex:0];
    
    _preview.connection.videoOrientation = [QRUtil videoOrientationFromCurrentDeviceOrientation];
    [_session startRunning];
    // 扫描的区域
    CGRect screenRect = [QRUtil screenBounds];
    QRScanView *qrScanView = [[QRScanView alloc] initWithFrame:screenRect];
    qrScanView.transparentArea = CGSizeMake(200.0, 200.0);
    qrScanView.backgroundColor = [UIColor clearColor];
    qrScanView.center = CGPointMake(screenRect.size.width/2.0, screenRect.size.height/2.0);
    [self.view addSubview:self.qrScanView = qrScanView];
    //修正扫描区域
    CGFloat screenHeight = self.view.frame.size.height;
    CGFloat screenWidth = self.view.frame.size.width;
    CGRect cropRect = CGRectMake((screenWidth-qrScanView.transparentArea.width)/2, (screenHeight-qrScanView.transparentArea.height)/2, qrScanView.transparentArea.width, qrScanView.transparentArea.height);
    
    [_output setRectOfInterest:CGRectMake(cropRect.origin.y / screenHeight,
                                          cropRect.origin.x / screenWidth,
                                          cropRect.size.height / screenHeight,
                                          cropRect.size.width / screenWidth)];
    
    UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, screenWidth, 64.0)];
    navView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    [self.view addSubview:navView];
    // 返回按钮
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(10.0, 20.0, 50.0, 44.0);
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    @weakify(self);
    backButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        [self dismissViewControllerAnimated:YES completion:^{
            [self.qrScanView.timer invalidate];
            self.qrScanView.timer = nil;
            [_session stopRunning];
            _session = nil;
        }];
        return [RACSignal empty];
    }];
    [navView addSubview:backButton];
    // 开灯按钮
    UIButton *openButton = [UIButton buttonWithType:UIButtonTypeCustom];
    openButton.frame = CGRectMake(screenWidth-60.0, 20.0f, 50.0, 44.0);
    [openButton setTitle:@"开灯" forState:UIControlStateNormal];
    [openButton setTitle:@"关灯" forState:UIControlStateSelected];
    openButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(UIButton *sender) {
        @strongify(self);
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch] && [device hasFlash]) {
            // 开启闪光灯
            if (device.torchMode != AVCaptureTorchModeOn || device.flashMode != AVCaptureFlashModeOn) {
                [_session beginConfiguration];
                [device lockForConfiguration:nil];
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
                [device unlockForConfiguration];
                sender.selected = YES;
                [_session commitConfiguration];
            }
            // 关闭闪光灯
            if (device.torchMode != AVCaptureTorchModeOff || device.flashMode != AVCaptureFlashModeOff) {
                [_session beginConfiguration];
                [device lockForConfiguration:nil];
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
                [device unlockForConfiguration];
                sender.selected = NO;
                [_session commitConfiguration];
            }
        }
        return [RACSignal empty];
    }];
    [navView addSubview:openButton];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    //停止扫描
    [_session stopRunning];
    //[self.qrView.timer pauseTimer];
    NSString *stringValue;
    if ([metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
    }
    NSLog(@"%@",stringValue);
    [QRUtil playBeep];
    [self dismissViewControllerAnimated:YES completion:^{
        [self.qrScanView.timer invalidate];
        self.qrScanView.timer = nil;
        [_session stopRunning];
        if (self.qrUrlBlock) {
            self.qrUrlBlock(stringValue);
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [_session stopRunning];
    _session = nil;
}
@end
