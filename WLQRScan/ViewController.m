//
//  ViewController.m
//  WLQRScan
//
//  Created by wangguoliang on 16/1/13.
//  Copyright © 2016年 wangguoliang. All rights reserved.
//

#import "ViewController.h"
#import "QRUtil.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>
#import <AssetsLibrary/AssetsLibrary.h>
#define APPBOUNDS [UIScreen mainScreen].bounds/*设备的屏幕尺寸*/
#define APPW (APPBOUNDS.size.width)/*设备的宽*/
#define APPH (APPBOUNDS.size.height)/*设备的高*/

#define IMAGEWIDTH 200.0

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

- (UITextField *)textField
{
    if (_textField == nil) {
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(10.0, 30.0, APPW-80.0, 35.0)];
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
        textField.layer.borderColor = [UIColor darkGrayColor].CGColor;
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
        button.frame = CGRectMake(APPW-60.0, 30.0, 50.0, 35.0);
        [button setTitle:@"生成" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.backgroundColor = [UIColor redColor];
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
        UIImageView *imgeView = [[UIImageView alloc] initWithFrame:CGRectMake((APPW-IMAGEWIDTH)/2.0, 90.0, IMAGEWIDTH, IMAGEWIDTH)];
        _textImage = imgeView;
    }
    return _textImage;
}

- (UILabel *)textLabel
{
    if (_textLabel == nil) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 90.0+IMAGEWIDTH+30.0, APPW, 20.0)];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:13.0];
        label.textColor = [UIColor blackColor];
        label.textAlignment = NSTextAlignmentCenter;
        _textLabel = label;
    }
    
    return _textLabel;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.title = @"二维码";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"照片" style:UIBarButtonItemStyleDone target:self action:@selector(selectPhoto)];
    [self.view addSubview:self.textField];
    [self.view addSubview:self.textSender];
    [self.view addSubview:self.textImage];
    [self.view addSubview:self.textLabel];
    @weakify(self);
    [self.textField.rac_textSignal subscribeNext:^(NSString *text) {
        @strongify(self);
        if ([text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0) {
            self.textSender.enabled = YES;
            self.textSender.backgroundColor = [UIColor redColor];
        } else {
            self.textSender.enabled = NO;
            self.textSender.backgroundColor = [UIColor grayColor];
        }
    }];
}
#pragma mark - 生成二维码
- (void)buttonAction
{
    [self.view endEditing:YES];
    self.textImage.image =
    [QRUtil scQRCodeForString:self.textField.text size:IMAGEWIDTH fillColor:[UIColor blackColor] backColor:[UIColor whiteColor] subImage:[UIImage imageNamed:@"934"]];
    //[UIImage imageNamed:@"934"]
}
#pragma mark - 选择照片
- (void)selectPhoto
{
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    if (author == ALAuthorizationStatusRestricted || author ==ALAuthorizationStatusDenied) {
        // 判断没有权限获取用户相册的话，就提示个View
        UIAlertView *alvertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"需要开启照片权限,请到设置->隐私->照片,打开母婴之家照片权限" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alvertView show];
        return;
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    //资源类型为图片库
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
