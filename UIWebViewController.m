//
//  UIWebViewController.m
//  Supervote
//
//  Created by augusto callejas on 2/25/12.
//  Copyright 2012 Canary Falls Software LLC. All rights reserved.
//

#import "UIWebViewController.h"


@implementation UIWebViewController

@synthesize delegate = _delegate;
@synthesize url = _url;
@synthesize webView = _webView;
@synthesize navItem = _navItem;

#pragma mark -
#pragma mark IBAction methods

// Done button clicked
- (IBAction)dismissView:(id)sender {
    // Call the delegate to dismiss the modal view
	[_delegate didDismissModalView];
}

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	if ([self title] != nil) {
		[[self navItem] setTitle:[self title]];
	}

	if (_url != nil) {
		NSURLRequest *requestObj = [NSURLRequest requestWithURL:[NSURL URLWithString:_url]];
		[_webView loadRequest:requestObj];
	}
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
