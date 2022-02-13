//
//  CustomClipViewController.m
//  HXPhotoPickerExample
//
//  Created by mambaxie on 2022/2/12.
//  Copyright © 2022 洪欣. All rights reserved.
//

#import "CustomClipViewController.h"
#import "UIView+HXExtension.h"
#import "HXPhotoPicker.h"
#import "HXPhotoClipViewController.h"

@interface CustomClipViewController ()

@property (strong, nonatomic) HXPhotoManager *photoManager;

@property (nonatomic, strong) UIImageView *avatarImageView;

@end

@implementation CustomClipViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImageView *avatarImageView = [[UIImageView alloc] init];
    avatarImageView.frame = CGRectMake(0, 150, 160, 160);
    avatarImageView.hx_centerX = self.view.hx_w * 0.5;
    avatarImageView.layer.cornerRadius = avatarImageView.hx_w * 0.5;
    avatarImageView.clipsToBounds = YES;
    avatarImageView.backgroundColor = [UIColor lightGrayColor];
    avatarImageView.userInteractionEnabled = YES;
    self.avatarImageView = avatarImageView;
    [avatarImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didPickerImageClick:)]];
    [self.view addSubview:avatarImageView];
    
    UIImageView *coverImageView = [[UIImageView alloc] init];
    coverImageView.userInteractionEnabled = YES;
    coverImageView.backgroundColor = [UIColor lightGrayColor];
    coverImageView.frame = CGRectMake(0, 0, 346, 156);
    coverImageView.layer.cornerRadius = 8;
    coverImageView.clipsToBounds = YES;
    coverImageView.hx_centerX = avatarImageView.hx_centerX;
    coverImageView.hx_y = CGRectGetMaxY(avatarImageView.frame) + 50;
    [coverImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didPickerImageClick:)]];
    [self.view addSubview:coverImageView];
}

- (void)didPickerImageClick:(UITapGestureRecognizer *)tap {
    UIImageView *imageView = (UIImageView *)tap.view;
    BOOL isAvatar = self.avatarImageView == imageView;
    HXPhotoManager *manager = [[HXPhotoManager alloc] initWithType:HXPhotoManagerSelectedTypePhoto];
    HXPhotoConfiguration *config = manager.configuration;
    config.type = HXConfigurationTypePhotoClip;
    config.singleSelected = YES;
    config.singleJumpEdit = YES;
    config.photoClipContainerSize = CGSizeMake(self.view.hx_w - 40, isAvatar ? 456 : 325);
    CGFloat clipW = config.photoClipContainerSize.width - 40;
    config.photoClipSize = CGSizeMake(clipW, isAvatar ? clipW : clipW * 156.0 / 346);
    config.photoClipCornerRadius = isAvatar ? clipW * 0.5 : imageView.layer.cornerRadius;
    config.photoClipTipsTitle = @"Drag and Zoom";
    config.photoClipCancelButtonTitle = @"Cancel";
    config.photoClipBackButtonTitle = @"Retack";
    config.photoClipDoneButtonTitle = @"OK";
    config.doneButtonClickAction = ^(HXPhotoClipViewController *viewController, UIButton *sender, UIImage *croppedImage) {
        imageView.image = croppedImage;
    };
    [self hx_presentSelectPhotoControllerWithManager:manager didDone:nil cancel:nil];
}

@end
