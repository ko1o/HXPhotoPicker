//
//  HXPhotoClipViewController.h
//  HXPhotoPickerExample
//
//  Created by mambaxie on 2022/2/13.
//  Copyright © 2022 洪欣. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HXPhotoConfiguration.h"
#import "HXPhotoClipScrollView.h"
#import "HXPhotoViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface HXPhotoClipViewController : UIViewController <UIViewControllerTransitioningDelegate>

@property (nonatomic, weak) HXPhotoViewController *photoPickerViewController; // 相册选择器

- (instancetype)initWithPhotoModel:(HXPhotoModel *)model config:(HXPhotoConfiguration *)config;

@property (nonatomic, strong) HXPhotoConfiguration *config;
@property (nonatomic, strong) HXPhotoModel *photoModel;

@property (nonatomic, strong) UIView *clipContainerView;
@property (nonatomic, strong) UIView *clipView;
@property (nonatomic, strong) UILabel *tipsTitleLabel;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *doneButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) HXPhotoClipScrollView *imageScrollView;

/// 图片裁剪返回点击
@property (strong, nonatomic) void(^backButtonClickAction)(HXPhotoClipViewController *viewController, UIButton *sender);
/// 图片裁剪完成按钮点击
@property (strong, nonatomic) void(^doneButtonClickAction)(HXPhotoClipViewController *viewController, UIButton *sender, UIImage *croppedImage);
/// 图片裁剪取消按钮点击
@property (strong, nonatomic) void(^cancelButtonClickAction)(HXPhotoClipViewController *viewController, UIButton *sender);

@end

NS_ASSUME_NONNULL_END
