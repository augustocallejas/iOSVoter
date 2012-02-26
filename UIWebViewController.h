//
//  UIWebViewController.h
//  Supervote
//
//  Created by augusto callejas on 2/25/12.
//  Copyright 2012 Canary Falls Software LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UIWebViewControllerDelegate <NSObject>

- (void)didDismissModalView;

@end

@interface UIWebViewController : UIViewController {
	id<UIWebViewControllerDelegate> _delegate;
@private
	NSString *_url;
	IBOutlet UIWebView *_webView;
}

@property (nonatomic, retain) id<UIWebViewControllerDelegate> delegate;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) UIWebView *webView;

- (IBAction)dismissView:(id)sender;

@end
