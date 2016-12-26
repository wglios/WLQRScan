//
//  ViewController.m
//  WLQRScan
//
//  Created by Json on 16/1/13.
//  Copyright © 2016年 Json. All rights reserved.
//

#import "ViewController.h"
#import "QRUtil.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>
#import "QRScanViewController.h"
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
#import <Photos/Photos.h>
#else
#import <AssetsLibrary/AssetsLibrary.h>
#endif

/**图片的宽高*/
static CGFloat const imageWH = 200.0;

@interface ViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
/**输入框*/
@property (nonatomic, strong)UITextField *textField;
/**生成按钮*/
@property (nonatomic, strong)UIButton *textSender;
/**生成的图片*/
@property (nonatomic, strong)UIImageView *textImage;
/**生成的文字*/
@property (nonatomic, strong)UILabel *textLabel;

@end

@implementation ViewController

#pragma mark - 懒加载
- (UITextField *)textField
{
    if (_textField == nil) {
        UITextField *textField = [[UITextField alloc] init];
        textField.font = [UIFont systemFontOfSize:15.0];
        textField.textColor = [UIColor blackColor];
        textField.placeholder = @"请输入文字";
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.clearButtonMode = UITextFieldViewModeAlways;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.backgroundColor = [UIColor whiteColor];
        textField.layer.cornerRadius = 5.0;
        textField.layer.borderWidth = 0.5;
        textField.layer.borderColor = [UIColor colorWithRed:236/255. green:236/255. blue:236/255. alpha:1.0].CGColor;
#ifdef DEBUG
        textField.text = @"www.baidu.com";
#endif
        _textField = textField;
    }
    return _textField;
}

- (UIButton *)textSender
{
    if (_textSender == nil) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:@"生成" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.backgroundColor = [UIColor colorWithRed:255/255.0 green:100/255.0 blue:33/255.0 alpha:1.0];
        button.layer.cornerRadius = 10.0;
        button.titleLabel.font = [UIFont systemFontOfSize:13.0];
        [button addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
        _textSender = button;
    }
    return _textSender;
}

- (UIImageView *)textImage
{
    if (_textImage == nil) {
        UIImageView *imgeView = [[UIImageView alloc] init];
        _textImage = imgeView;
    }
    return _textImage;
}

- (UILabel *)textLabel
{
    if (_textLabel == nil) {
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:13.0];
        label.textColor = [UIColor blackColor];
        label.textAlignment = NSTextAlignmentCenter;
        _textLabel = label;
    }
    
    return _textLabel;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.title = @"二维码扫描和生成";
    UIBarButtonItem *photoItem = [[UIBarButtonItem alloc] initWithTitle:@"照片" style:UIBarButtonItemStyleDone target:self action:@selector(selectPhoto)];
    UIBarButtonItem *sacnItem = [[UIBarButtonItem alloc] initWithTitle:@"扫描" style:UIBarButtonItemStyleDone target:self action:@selector(scanAction)];
    self.navigationItem.rightBarButtonItems = @[photoItem, sacnItem];
    
    // 输入框的约束
    self.textField.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *textFieldLeadingConStraint = [NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:10.0];
    NSLayoutConstraint *textFieldTopConStraint = [NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:30.0];
    NSLayoutConstraint *textFieldTrailingConStraint = [NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.textSender attribute:NSLayoutAttributeLeading multiplier:1 constant:-10.0];
    NSLayoutConstraint *textFieldHeightConStraint = [NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:35.0];
    
    // 按钮的约束
    self.textSender.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *textSenderLeadingConStraint = [NSLayoutConstraint constraintWithItem:self.textSender attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.textField attribute:NSLayoutAttributeTrailing multiplier:1 constant:10.0];
    NSLayoutConstraint *textSenderTopConStraint = [NSLayoutConstraint constraintWithItem:self.textSender attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.textField attribute:NSLayoutAttributeTop multiplier:1 constant:0.0];
    NSLayoutConstraint *textSenderTrailingConStraint = [NSLayoutConstraint constraintWithItem:self.textSender attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:-10.0];
    NSLayoutConstraint *textSenderWidthConStraint = [NSLayoutConstraint constraintWithItem:self.textSender attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:40.0];
    NSLayoutConstraint *textSenderHeightConStraint = [NSLayoutConstraint constraintWithItem:self.textSender attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.textField attribute:NSLayoutAttributeHeight multiplier:1 constant:0.0];
    
    // 二维码图片的约束
    self.textImage.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *textImgWidthConStraint = [NSLayoutConstraint constraintWithItem:self.textImage attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:imageWH];
    NSLayoutConstraint *textImgHeightConStraint = [NSLayoutConstraint constraintWithItem:self.textImage attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.textImage attribute:NSLayoutAttributeHeight multiplier:1 constant:0.0];
    NSLayoutConstraint *textImgCenterXConStraint = [NSLayoutConstraint constraintWithItem:self.textImage attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0.0];
    NSLayoutConstraint *textImgTopConStraint = [NSLayoutConstraint constraintWithItem:self.textImage attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.textField attribute:NSLayoutAttributeBottom multiplier:1 constant:30.0];
    
    // 文字的约束
    self.textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *textLabelLeadingConStraint = [NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0.0];
    NSLayoutConstraint *textLabelTopConStraint = [NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.textImage attribute:NSLayoutAttributeBottom multiplier:1 constant:30.0];
    NSLayoutConstraint *textLabelTrailingConStraint = [NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0.0];
    NSLayoutConstraint *textLabelHeightConStraint = [NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:25.0];
    [self.view addSubview:self.textField];
    [self.view addSubview:self.textSender];
    [self.view addSubview:self.textImage];
    [self.view addSubview:self.textLabel];
    [self.view addConstraints:@[textFieldLeadingConStraint, textFieldTopConStraint, textFieldTrailingConStraint, textFieldHeightConStraint, textSenderLeadingConStraint, textSenderTopConStraint, textSenderTrailingConStraint, textSenderWidthConStraint, textSenderHeightConStraint, textImgWidthConStraint, textImgHeightConStraint, textImgCenterXConStraint, textImgTopConStraint, textLabelLeadingConStraint, textLabelTopConStraint, textLabelTrailingConStraint, textLabelHeightConStraint]];
    
    @weakify(self);
    // 图片添加长按手势
    self.textImage.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] init];
    [self.textImage addGestureRecognizer:longPress];
    [[longPress rac_gestureSignal] subscribeNext:^(UILongPressGestureRecognizer *longPress) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
        UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:nil message:@"是否保存该图片到相册" preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            if (self.textImage.image) {
                UIImageWriteToSavedPhotosAlbum(self.textImage.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
            }
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertCtrl addAction:sureAction];
        [alertCtrl addAction:cancelAction];
        [self presentViewController:alertCtrl animated:YES completion:nil];
#else
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"是否保存该图片到相册" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"确定", nil];
        [actionSheet showInView:self.view];
        [[actionSheet rac_buttonClickedSignal] subscribeNext:^(id x) {
            if ([x integerValue] == 0 && self.textImage.image) {
                UIImageWriteToSavedPhotosAlbum(self.textImage.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
            }
        }];
#endif
    }];
    [self.textField.rac_textSignal subscribeNext:^(NSString *text) {
        @strongify(self);
        if ([text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0) {
            self.textSender.enabled = YES;
            self.textSender.backgroundColor = [UIColor colorWithRed:255/255.0 green:100/255.0 blue:33/255.0 alpha:1.0];
        } else {
            self.textSender.enabled = NO;
            self.textSender.backgroundColor = [UIColor colorWithRed:250/255.0 green:172/255.0 blue:139/255.0 alpha:1.0];
        }
    }];
    
    NSLog(@"%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"]);
}
#pragma mark - 生成二维码
- (void)buttonAction
{
    [self.view endEditing:YES];
    if (self.textField.text && self.textField.text.length > 0) {
        self.textImage.image = [QRUtil scQRCodeForString:self.textField.text size:imageWH fillColor:[UIColor blackColor] backColor:[UIColor whiteColor] subImage:[UIImage imageNamed:@"934"]];
    }
}
#pragma mark - 选择照片
- (void)selectPhoto
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
    PHAuthorizationStatus phAuthor = [PHPhotoLibrary authorizationStatus];
    if (phAuthor == PHAuthorizationStatusRestricted || phAuthor ==PHAuthorizationStatusDenied) {
        UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:@"提示" message:@"需要开启照片权限,请到设置->隐私->照片,我的App打开手机相册权限" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }];
        [alertCtrl addAction:sureAction];
        [self presentViewController:alertCtrl animated:YES completion:nil];
        return;
    }
#else
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    if (author == ALAuthorizationStatusRestricted || author ==ALAuthorizationStatusDenied) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"需要开启照片权限,请到设置->隐私->照片,我的App打开手机相册权限" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
        return;
    }
#endif
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    //资源类型为图片库
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)scanAction
{
#if TARGET_IPHONE_SIMULATOR  //模拟器
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:nil message:@"这是模拟器,不能打开" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alertCtrl addAction:sureAction];
    [self presentViewController:alertCtrl animated:YES completion:nil];
#else
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"这是模拟器,不能打开" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alertView show];
#endif
#elif TARGET_OS_IPHONE //真机
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
    @weakify(self);
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                //
            }
        }];
    }
    if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
        return;
    }
    QRScanViewController *qrScanVc = [[QRScanViewController alloc] init];
    qrScanVc.qrUrlBlock = ^(NSString *url){
        @strongify(self);
        self.textLabel.text = url;
    };
    [self presentViewController:qrScanVc animated:YES completion:nil];
#endif
#endif
}
#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        //
    }];
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    if (originalImage != nil){
        self.textLabel.text = [QRUtil scQRReaderForImage:originalImage];
    }
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    //
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
