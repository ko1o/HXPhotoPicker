//
//  HXPhotoClipTouchView.h
//  HXPhotoPickerExample
//
//  Created by mambaxie on 2022/2/13.
//  Copyright © 2022 洪欣. All rights reserved.
//

#import "HXPhotoClipTouchView.h"

@implementation HXPhotoClipTouchView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
	if ([self pointInside:point withEvent:event]) {
		return self.receiver;
	}
	return nil;
}

@end
