//
//  HXPhotoClipScrollView.h
//  HXPhotoPickerExample
//
//  Created by mambaxie on 2022/2/13.
//  Copyright © 2022 洪欣. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXPhotoClipScrollView : UIScrollView

@property (nonatomic, nullable, strong) UIImageView *zoomView;
@property (nonatomic, assign) BOOL aspectFill;

- (void)displayImage:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
