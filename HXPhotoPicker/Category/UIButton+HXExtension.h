//
//  UIButton+HXExtension.h
//  HXPhotoPickerExample
//
//  Created by Silence on 17/2/16.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TouchUpInsideActionBlock)(UIButton * _Nonnull button);

@interface UIButton (HXExtension)
/**  扩大buuton点击范围  */
- (void)hx_setEnlargeEdgeWithTop:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom left:(CGFloat)left;

/// 添加点击事件回调
- (void)hx_addTouchUpInsideWithAction:(TouchUpInsideActionBlock _Nullable )action;

@end
