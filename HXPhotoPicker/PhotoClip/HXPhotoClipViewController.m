//
//  HXPhotoClipViewController.m
//  HXPhotoPickerExample
//
//  Created by mambaxie on 2022/2/13.
//  Copyright © 2022 洪欣. All rights reserved.
//

#import "HXPhotoClipViewController.h"
#import "UIView+HXExtension.h"
#import "UIButton+HXExtension.h"
#import "UIColor+HXExtension.h"
#import "UIImage+HXExtension.h"
#import "HXPhotoEditTransition.h"
#import "HXPhotoModel.h"
#import "HXPhotoDefine.h"
#import "HXPhotoClipScrollView.h"
#import "HXPhotoClipTouchView.h"

@interface HXPhotoClipViewController ()

@property (assign, nonatomic) PHContentEditingInputRequestID requestId;

@property (nonatomic, assign) UIImage *originImage;

@end

@implementation HXPhotoClipViewController

- (instancetype)initWithPhotoModel:(HXPhotoModel *)model config:(HXPhotoConfiguration *)config {
    if (self = [super init]) {
        _config = config;
        _photoModel = model;
//        self.transitioningDelegate = self;
//        self.modalPresentationStyle = UIModalPresentationCustom;
    }
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    
    [self requestImageData];
}

- (void)requestImageData {
    if (self.photoModel.previewPhoto) {
        self.originImage = self.photoModel.previewPhoto;
        [self.imageScrollView displayImage:self.originImage];
        return;
    }
    HXWeakSelf
    if (self.photoModel.type == HXPhotoModelMediaTypeLivePhoto) {
        [self.photoModel requestPreviewImageWithSize:self.photoModel.endImageSize startRequestICloud:^(PHImageRequestID iCloudRequestId, HXPhotoModel * _Nullable model) {
            weakSelf.requestId = iCloudRequestId;
        } progressHandler:nil success:^(UIImage * _Nullable image, HXPhotoModel * _Nullable model, NSDictionary * _Nullable info) {
            weakSelf.originImage = image;
            [weakSelf.view hx_handleLoading];
            [weakSelf loadImageCompletion];
        } failed:^(NSDictionary * _Nullable info, HXPhotoModel * _Nullable model) {
            [weakSelf.view hx_handleLoading];
            [weakSelf loadImageCompletion];
        }];
        return;
    }else if (self.photoModel.cameraPhotoType == HXPhotoModelMediaTypeCameraPhotoTypeLocalLivePhoto ||
              self.photoModel.cameraPhotoType == HXPhotoModelMediaTypeCameraPhotoTypeNetWorkLivePhoto) {
        self.originImage = self.photoModel.thumbPhoto;
        [self.view hx_handleLoading];
        [self loadImageCompletion];
        return;
    }
    self.requestId = [self.photoModel requestImageDataWithLoadOriginalImage:YES startRequestICloud:^(PHImageRequestID iCloudRequestId, HXPhotoModel * _Nullable model) {
        weakSelf.requestId = iCloudRequestId;
    } progressHandler:nil success:^(NSData * _Nullable imageData, UIImageOrientation orientation, HXPhotoModel * _Nullable model, NSDictionary * _Nullable info) {
        @autoreleasepool {
            UIImage *image = [UIImage imageWithData:imageData];
            [weakSelf requestImageCompletion:image];
        }
    } failed:^(NSDictionary * _Nullable info, HXPhotoModel * _Nullable model) {
        [weakSelf requestImaegURL];
    }];
}

- (void)requestImaegURL {
    HXWeakSelf
    self.requestId = [self.photoModel requestImageURLStartRequestICloud:^(PHContentEditingInputRequestID iCloudRequestId, HXPhotoModel *model) {
        weakSelf.requestId = iCloudRequestId;
    } progressHandler:nil success:^(NSURL *imageURL, HXPhotoModel *model, NSDictionary *info) {
        @autoreleasepool {
            NSData * imageData = [NSData dataWithContentsOfFile:imageURL.relativePath];
            UIImage *image = [UIImage imageWithData:imageData];
            [weakSelf requestImageCompletion:image];
        }
    } failed:^(NSDictionary *info, HXPhotoModel *model) {
        [weakSelf requestImage];
    }];
}

- (void)requestImage {
    HXWeakSelf
    self.requestId = [self.photoModel requestPreviewImageWithSize:PHImageManagerMaximumSize startRequestICloud:^(PHImageRequestID iCloudRequestId, HXPhotoModel * _Nullable model) {
        weakSelf.requestId = iCloudRequestId;
    } progressHandler:nil success:^(UIImage * _Nullable image, HXPhotoModel * _Nullable model, NSDictionary * _Nullable info) {
        if (image.images.count > 1) {
            image = image.images.firstObject;
        }
        [weakSelf requestImageCompletion:image];
    } failed:^(NSDictionary * _Nullable info, HXPhotoModel * _Nullable model) {
        [weakSelf.view hx_handleLoading];
        [weakSelf loadImageCompletion];
    }];
}

- (void)requestImageCompletion:(UIImage *)image {
    if (image.imageOrientation != UIImageOrientationUp) {
        image = [image hx_normalizedImage];
    }
    CGSize imageSize = image.size;
    if (imageSize.width * imageSize.height > 3 * 1000 * 1000) {
        while (imageSize.width * imageSize.height > 3 * 1000 * 1000) {
            imageSize.width /= 2;
            imageSize.height /= 2;
        }
        image = [image hx_scaleToFillSize:imageSize];
    }
    self.originImage = image;
    [self loadImageCompletion];
}

- (void)loadImageCompletion {
    [self.imageScrollView displayImage:self.originImage];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor blackColor];
    
    HXPhotoConfiguration *config = self.config;
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [cancelButton setTitle:config.photoClipCancelButtonTitle forState:UIControlStateNormal];
    cancelButton.hx_w = self.view.hx_w;
    cancelButton.hx_h = 61;
    cancelButton.hx_bottom = self.view.hx_h - homeIndicatorHeight();
    __weak typeof(self) weakSelf = self;
    [cancelButton hx_addTouchUpInsideWithAction:^(UIButton * _Nonnull button) {
        if (weakSelf.config.cancelButtonClickAction) {
            weakSelf.config.cancelButtonClickAction(weakSelf, button);
        }
        if (weakSelf.cancelButtonClickAction) {
            weakSelf.cancelButtonClickAction(weakSelf, button);
        }
    }];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [cancelButton setTitleColor:[UIColor hx_colorWithHexStr:@"3A82F7"] forState:UIControlStateNormal];
    [self.view addSubview:cancelButton];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.hx_w = cancelButton.hx_w;
    lineView.hx_h = 0.5;
    lineView.backgroundColor = [UIColor hx_colorWithHexStr:@"#323234"];
    lineView.hx_bottom = cancelButton.hx_y;
    [self.view addSubview:lineView];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [backButton setTitle:config.photoClipBackButtonTitle forState:UIControlStateNormal];
    backButton.hx_w = 175;
    backButton.hx_h = 48;
    backButton.titleLabel.font = [UIFont systemFontOfSize:16];
    backButton.layer.cornerRadius = backButton.hx_h * 0.5;
    backButton.hx_centerX = self.view.hx_w * 0.25;
    backButton.hx_bottom = lineView.hx_y - 33;
    backButton.backgroundColor = [UIColor hx_colorWithHexStr:@"2A2A2B"];
    [backButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [backButton hx_addTouchUpInsideWithAction:^(UIButton * _Nonnull button) {
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
        if (weakSelf.config.backButtonClickAction) {
            weakSelf.config.backButtonClickAction(weakSelf, button);
        }
        if (weakSelf.backButtonClickAction) {
            weakSelf.backButtonClickAction(weakSelf, button);
        }
    }];
    [self.view addSubview:backButton];
    self.backButton = backButton;
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [doneButton setTitle:config.photoClipDoneButtonTitle forState:UIControlStateNormal];
    doneButton.hx_size = backButton.hx_size;
    doneButton.hx_centerX = self.view.hx_w * 0.75;
    doneButton.layer.cornerRadius = doneButton.hx_h * 0.5;
    doneButton.hx_centerY = backButton.hx_centerY;
    doneButton.titleLabel.font = backButton.titleLabel.font;
    [doneButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    doneButton.backgroundColor = [UIColor hx_colorWithHexStr:@"3A82F7"];
    [doneButton hx_addTouchUpInsideWithAction:^(UIButton * _Nonnull button) {
        weakSelf.clipView.clipsToBounds = NO;
        UIImage *croppedImage = [weakSelf.clipView hx_toImage];
        weakSelf.clipView.clipsToBounds = YES;
        if (weakSelf.config.doneButtonClickAction) {
            weakSelf.config.doneButtonClickAction(weakSelf, button, croppedImage);
        }
            
        if (weakSelf.doneButtonClickAction) {
            weakSelf.doneButtonClickAction(weakSelf, button, croppedImage);
        }
    }];
    [self.view addSubview:doneButton];
    self.doneButton = doneButton;
    
    UIView *clipContainerView = [[UIView alloc] init];
    clipContainerView.hx_size = config.photoClipContainerSize;
    clipContainerView.hx_centerX = self.view.hx_w * 0.5;
    clipContainerView.hx_centerY = backButton.hx_y * 0.5;
    clipContainerView.backgroundColor = [UIColor hx_colorWithHexStr:@"#202020"];
    clipContainerView.layer.cornerRadius = 18;
    [self.view addSubview:clipContainerView];
    self.clipContainerView = clipContainerView;
    
    UILabel *tipsTitleLabel = [[UILabel alloc] init];
    tipsTitleLabel.hx_h = 60;
    tipsTitleLabel.hx_w = clipContainerView.hx_w;
    tipsTitleLabel.textColor = [UIColor whiteColor];
    tipsTitleLabel.text = config.photoClipTipsTitle;
    tipsTitleLabel.textAlignment = NSTextAlignmentCenter;
    tipsTitleLabel.font = [UIFont fontWithName:@"PingFang SC" size:16];
    [clipContainerView addSubview:tipsTitleLabel];
    self.tipsTitleLabel = tipsTitleLabel;
    
    HXPhotoClipTouchView *clipView = [[HXPhotoClipTouchView alloc] init];
    clipView.hx_size = config.photoClipSize;
    clipView.hx_centerX = clipContainerView.hx_w * 0.5;
    clipView.hx_centerY = (clipContainerView.hx_h - tipsTitleLabel.hx_bottom) * 0.5 + tipsTitleLabel.hx_bottom;
    clipView.layer.cornerRadius = config.photoClipCornerRadius;
    clipView.backgroundColor = [UIColor blackColor];
    clipView.clipsToBounds = YES;
    self.clipView = clipView;
    [clipContainerView addSubview:clipView];
    
    HXPhotoClipScrollView *imageScrollView = [[HXPhotoClipScrollView alloc] init];
    imageScrollView.userInteractionEnabled = NO;
    imageScrollView.clipsToBounds = NO;
    imageScrollView.aspectFill = YES;
    imageScrollView.alwaysBounceHorizontal = NO;
    imageScrollView.alwaysBounceVertical = NO;
    imageScrollView.hx_size = clipView.hx_size;
    self.imageScrollView = imageScrollView;
    [clipView addSubview:imageScrollView];
    clipView.receiver = imageScrollView;
}

#pragma mark - UIViewControllerTransitioningDelegate
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [HXPhotoEditTransition transitionWithType:HXPhotoEditTransitionTypePresent model:self.photoModel];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [HXPhotoEditTransition transitionWithType:HXPhotoEditTransitionTypeDismiss model:self.photoModel];
}

@end
