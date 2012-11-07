//
//  MOAISinaWeiboCompileView.h
//  TestUIView
//
//  Created by Benny on 11/7/12.
//  Copyright (c) 2012 Benny. All rights reserved.
//

#ifndef MOAISINAWEIBOCOMPILEVIEW_H
#define MOAISINAWEIBOCOMPILEVIEW_H

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "SinaWeiboRequest.h"

@interface MOAISinaWeiboCompileView : UIView<SinaWeiboRequestDelegate>
{
    UIButton *closeButton;
    UIButton *postButton;
    UITextView *textView;
	UIImageView *imageView;
    UIView *modalBackgroundView;
    UIActivityIndicatorView *indicatorView;
    UIInterfaceOrientation previousOrientation;

    NSString *postText;
	UIImage *image;
	
	SinaWeibo *sinaWeibo;
}

- (id)initWithPost:(SinaWeibo *)_sinaWeibo
				text:(NSString *)_postText
				image:(UIImage *)_image;

- (void)show;
- (void)hide;

@end

#endif