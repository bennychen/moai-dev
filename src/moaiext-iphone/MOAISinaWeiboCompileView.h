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

@protocol SinaWeiboCompileViewDelegate;

@interface MOAISinaWeiboCompileView : UIView<SinaWeiboRequestDelegate>
{
    UIButton *closeButton;
    UIButton *postButton;
	UIButton *logButton;
	UILabel *logInfo;
    UITextView *textView;
	UILabel	*hint;
	UIImageView *imageView;
    UIView *modalBackgroundView;
    UIActivityIndicatorView *indicatorView;
    UIInterfaceOrientation previousOrientation;

    NSString *postText;
	UIImage *image;
	
	SinaWeibo *sinaWeibo;
	
    id<SinaWeiboCompileViewDelegate> compileDelegate;
	id<SinaWeiboRequestDelegate> requestDelegate;
}

- (id)initWithPost:(SinaWeibo *)_sinaWeibo
				text:(NSString *)_postText
				image:(UIImage *)_image
				compileDelegate:(id<SinaWeiboCompileViewDelegate>)_compileDelegate
				requestDelegate:(id<SinaWeiboRequestDelegate>)_requestDelegate;

- (void)show;
- (void)hide;

@end


@protocol SinaWeiboCompileViewDelegate <NSObject>

- (void)onCancelClicked;
- (void)onPostClicked;

@end

#endif