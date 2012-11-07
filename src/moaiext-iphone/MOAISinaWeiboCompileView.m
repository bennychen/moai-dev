//
//  MOAISinaWeiboCompileView
//  TestUIView
//
//  Created by Benny on 11/7/12.
//  Copyright (c) 2012 Benny. All rights reserved.
//

#include "pch.h"

#import <moaiext-iphone/MOAISinaWeiboCompileView.h>
#import <QuartzCore/QuartzCore.h>

static CGFloat kBorderGray[4] = {0.3, 0.3, 0.3, 0.8};
static CGFloat kBorderBlack[4] = {0.3, 0.3, 0.3, 1};
static CGFloat kTransitionDuration = 0.3;
static CGFloat kPadding = 0;
static CGFloat kBorderWidth = 10;

@implementation MOAISinaWeiboCompileView

#pragma mark - Drawing

- (void)addRoundedRectToPath:(CGContextRef)context rect:(CGRect)rect radius:(float)radius
{
    CGContextBeginPath(context);
    CGContextSaveGState(context);
    
    if (radius == 0)
    {
        CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
        CGContextAddRect(context, rect);
    }
    else
    {
        rect = CGRectOffset(CGRectInset(rect, 0.5, 0.5), 0.5, 0.5);
        CGContextTranslateCTM(context, CGRectGetMinX(rect)-0.5, CGRectGetMinY(rect)-0.5);
        CGContextScaleCTM(context, radius, radius);
        float fw = CGRectGetWidth(rect) / radius;
        float fh = CGRectGetHeight(rect) / radius;
        
        CGContextMoveToPoint(context, fw, fh/2);
        CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
        CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
        CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
        CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
    }
    
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

- (void)drawRect:(CGRect)rect fill:(const CGFloat*)fillColors radius:(CGFloat)radius
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    
    if (fillColors)
    {
        CGContextSaveGState(context);
        CGContextSetFillColor(context, fillColors);
        if (radius)
        {
            [self addRoundedRectToPath:context rect:rect radius:radius];
            CGContextFillPath(context);
        }
        else
        {
            CGContextFillRect(context, rect);
        }
        CGContextRestoreGState(context);
    }
    
    CGColorSpaceRelease(space);
}

- (void)strokeLines:(CGRect)rect stroke:(const CGFloat*)strokeColor
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    
    CGContextSaveGState(context);
    CGContextSetStrokeColorSpace(context, space);
    CGContextSetStrokeColor(context, strokeColor);
    CGContextSetLineWidth(context, 1.0);
    
    {
        CGPoint points[] = {{rect.origin.x+0.5, rect.origin.y-0.5},
            {rect.origin.x+rect.size.width, rect.origin.y-0.5}};
        CGContextStrokeLineSegments(context, points, 2);
    }
    {
        CGPoint points[] = {{rect.origin.x+0.5, rect.origin.y+rect.size.height-0.5},
            {rect.origin.x+rect.size.width-0.5, rect.origin.y+rect.size.height-0.5}};
        CGContextStrokeLineSegments(context, points, 2);
    }
    {
        CGPoint points[] = {{rect.origin.x+rect.size.width-0.5, rect.origin.y},
            {rect.origin.x+rect.size.width-0.5, rect.origin.y+rect.size.height}};
        CGContextStrokeLineSegments(context, points, 2);
    }
    {
        CGPoint points[] = {{rect.origin.x+0.5, rect.origin.y},
            {rect.origin.x+0.5, rect.origin.y+rect.size.height}};
        CGContextStrokeLineSegments(context, points, 2);
    }
    
    CGContextRestoreGState(context);
    
    CGColorSpaceRelease(space);
}

- (void)drawRect:(CGRect)rect
{
    [self drawRect:rect fill:kBorderGray radius:0];
    
    CGRect webRect = CGRectMake(
                                ceil(rect.origin.x+kBorderWidth), ceil(rect.origin.y+kBorderWidth)+1,
                                rect.size.width-kBorderWidth*2, rect.size.height-(1+kBorderWidth*2));
    
    [self strokeLines:webRect stroke:kBorderBlack];
}

#pragma mark - Memory management

- (id)initWithPost:(SinaWeibo *)_sinaWeibo
				text:(NSString *)_postText
				image:(UIImage *)_image;
{
	sinaWeibo = _sinaWeibo;
	postText = _postText;
	image = _image;
    self = [self init];
    return self;
}

- (id)init
{
    if ((self = [super init]))
    {
        self.backgroundColor = [UIColor clearColor];
        self.autoresizesSubviews = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.contentMode = UIViewContentModeRedraw;
        
        closeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [closeButton setTitle:@"取消" forState:UIControlStateNormal];
        closeButton.frame = CGRectMake(10, 10, 100, 30);
        [closeButton addTarget:self action:@selector(cancel)
              forControlEvents:UIControlEventTouchUpInside];
        closeButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
        closeButton.showsTouchWhenHighlighted = YES;
        [self addSubview:closeButton];
        
        postButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [postButton setTitle:@"发布" forState:UIControlStateNormal];
        postButton.frame = CGRectMake(250, 10, 100, 30);
        [postButton addTarget:self action:@selector(post)
              forControlEvents:UIControlEventTouchUpInside];
        postButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
        postButton.showsTouchWhenHighlighted = YES;
        [self addSubview:postButton];
        
        textView = [[UITextView alloc] init];
        textView.text = postText;
        textView.frame = CGRectMake( 20, 100, 300, 200 );
        [self addSubview:textView];
		
        imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake( 100, 300, 100, 75 );
        [self addSubview:imageView];
        
        indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
                         UIActivityIndicatorViewStyleGray];
        indicatorView.autoresizingMask =
        UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin
        | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:indicatorView];
        
        modalBackgroundView = [[UIView alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    [postText release], postText = nil;
    [modalBackgroundView release], modalBackgroundView = nil;
    
    [super dealloc];
}

#pragma mark - View orientation

BOOL IsDeviceIPad()
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        return YES;
    }
#endif
    return NO;
}

- (BOOL)shouldRotateToOrientation:(UIInterfaceOrientation)orientation
{
    if (orientation == previousOrientation)
    {
        return NO;
    }
    else
    {
        return orientation == UIInterfaceOrientationPortrait
        || orientation == UIInterfaceOrientationPortraitUpsideDown
        || orientation == UIInterfaceOrientationLandscapeLeft
        || orientation == UIInterfaceOrientationLandscapeRight;
    }
}

- (CGAffineTransform)transformForOrientation
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationLandscapeLeft)
    {
        return CGAffineTransformMakeRotation(M_PI*1.5);
    }
    else if (orientation == UIInterfaceOrientationLandscapeRight)
    {
        return CGAffineTransformMakeRotation(M_PI/2);
    }
    else if (orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        return CGAffineTransformMakeRotation(-M_PI);
    }
    else
    {
        return CGAffineTransformIdentity;
    }
}

- (void)sizeToFitOrientation:(BOOL)transform
{
    if (transform)
    {
        self.transform = CGAffineTransformIdentity;
    }
    
    CGRect frame = [UIScreen mainScreen].applicationFrame;
    CGPoint center = CGPointMake(frame.origin.x + ceil(frame.size.width/2),
                                 frame.origin.y + ceil(frame.size.height/2));
    
    CGFloat scaleFactor = IsDeviceIPad() ? 0.6f : 1.0f;
    
    CGFloat width = floor(scaleFactor * frame.size.width) - kPadding * 2;
    CGFloat height = floor(scaleFactor * frame.size.height) - kPadding * 2;
    
    previousOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(previousOrientation))
    {
        self.frame = CGRectMake(kPadding, kPadding, height, width);
    }
    else
    {
        self.frame = CGRectMake(kPadding, kPadding, width, height);
    }
    self.center = center;
    
    if (transform)
    {
        self.transform = [self transformForOrientation];
    }
}

#pragma mark - UIDeviceOrientationDidChangeNotification Methods

- (void)deviceOrientationDidChange:(id)object
{
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	if ([self shouldRotateToOrientation:orientation])
    {
        NSTimeInterval duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
		
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:duration];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[self sizeToFitOrientation:orientation];
		[UIView commitAnimations];
	}
}

#pragma mark - Animation

- (void)bounce1AnimationStopped
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kTransitionDuration/2];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(bounce2AnimationStopped)];
    self.transform = CGAffineTransformScale([self transformForOrientation], 0.9, 0.9);
    [UIView commitAnimations];
}

- (void)bounce2AnimationStopped
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kTransitionDuration/2];
    self.transform = [self transformForOrientation];
    [UIView commitAnimations];
}

#pragma mark Obeservers

- (void)addObservers
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(deviceOrientationDidChange:)
												 name:@"UIDeviceOrientationDidChangeNotification" object:nil];
}

- (void)removeObservers
{
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:@"UIDeviceOrientationDidChangeNotification" object:nil];
}

#pragma mark - Activity Indicator

- (void)showIndicator
{
    [indicatorView sizeToFit];
    [indicatorView startAnimating];
}

- (void)hideIndicator
{
    [indicatorView stopAnimating];
}

#pragma mark - Show / Hide

- (void)showWebView
{
}

- (void)show
{
    [self sizeToFitOrientation:NO];
    
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    if (!window)
    {
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    }
    modalBackgroundView.frame = window.frame;
    [modalBackgroundView addSubview:self];
    [window addSubview:modalBackgroundView];
    
    self.transform = CGAffineTransformScale([self transformForOrientation], 0.001, 0.001);
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kTransitionDuration/1.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(bounce1AnimationStopped)];
    self.transform = CGAffineTransformScale([self transformForOrientation], 1.1, 1.1);
    [UIView commitAnimations];
    
    [self addObservers];
}

- (void)_hide
{
    [self removeFromSuperview];
    [modalBackgroundView removeFromSuperview];
}

- (void)hide
{
    [self removeObservers];
    
    [self performSelectorOnMainThread:@selector(_hide) withObject:nil waitUntilDone:NO];
}

- (void)post
{
	if (image != NULL )
	{
		[sinaWeibo requestWithURL:@"statuses/upload.json"
				   params:[NSMutableDictionary dictionaryWithObjectsAndKeys:
						   postText, @"status",
						   image, @"pic", nil]
			   httpMethod:@"POST"
				 delegate:self];
	}
	else
	{
		[sinaWeibo requestWithURL:@"statuses/update.json"
				   params:[NSMutableDictionary dictionaryWithObjectsAndKeys:postText, @"status", nil]
			   httpMethod:@"POST"
				 delegate:self];
	}
	
    [self showIndicator];
}

- (void)cancel
{
    [self hide];
}


#pragma mark - SinaWeiboRequest Delegate

- (void)request:(SinaWeiboRequest *)request didFailWithError:(NSError *)error
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"失败"
														message:@"发送失败，请稍后再试"
													   delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
	[alertView show];
	[alertView release];
}

- (void)request:(SinaWeiboRequest *)request didFinishLoadingWithResult:(id)result
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"成功"
														message:@"发送成功!"
													   delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
	[alertView show];
	[alertView release];
	[self hide];
}

@end