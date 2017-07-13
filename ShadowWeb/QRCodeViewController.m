//
// Created by clowwindy on 14-2-17.
// Copyright (c) 2014 clowwindy. All rights reserved.
//

#import "QRCodeViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface QRCodeViewController()<AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic,strong) AVCaptureSession *sesstion;
@property (nonatomic,strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic,strong) dispatch_queue_t dispatchQueue;
@property (nonatomic,assign)QRCodeViewControllerReturnBlock returnBlock;
@property (nonatomic, strong)UIButton * cancelButton;
@end
@implementation QRCodeViewController

- (id)initWithReturnBlock:(QRCodeViewControllerReturnBlock)block {
    self = [super init];
    if (self) {
        _sesstion = [[AVCaptureSession alloc]init];
        _returnBlock = block;
      //  _previewLayer =
        _dispatchQueue = dispatch_queue_create("QRCodeQueue", NULL);
    }
    return self;
}

- (void)viewDidLoad {

    [self readQRCodd];
    self.cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 44 - 10, 20, 44, 44)];
    [self.cancelButton setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.cancelButton];
}

- (void)readQRCodd {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *err = nil;
    AVCaptureDeviceInput * captureDevice = [[AVCaptureDeviceInput alloc]initWithDevice:device error:&err];
    if (err == nil) {
        [self.sesstion addInput:captureDevice];
        AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc]init];
         [output setMetadataObjectsDelegate:self queue:self.dispatchQueue];
        [self.sesstion addOutput:output];
        output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeCode128Code , AVMetadataObjectTypeEAN8Code , AVMetadataObjectTypeEAN13Code];
        AVCaptureVideoPreviewLayer *preview = [AVCaptureVideoPreviewLayer layerWithSession:self.sesstion];
        preview.videoGravity = AVLayerVideoGravityResizeAspect;
        preview.frame = self.view.bounds;
        
        [self.view.layer insertSublayer:preview atIndex:0];
        self.previewLayer = preview;
        [self.sesstion startRunning];
    }
    
}

- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects.count > 0) {
        if ([metadataObjects[0] isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
            AVMetadataMachineReadableCodeObject *object = (AVMetadataMachineReadableCodeObject *)metadataObjects[0];
            dispatch_async(dispatch_get_main_queue(), ^{
                  [self.sesstion stopRunning];
                  self.returnBlock(object.stringValue);
                 [self dismissViewControllerAnimated:YES completion:nil];
            });
        }
    }
}


- (void)cancel {
    [self.sesstion stopRunning];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
