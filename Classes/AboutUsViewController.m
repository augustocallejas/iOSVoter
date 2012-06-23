//
//  AboutUsViewController.m
//  Supervote
//
//  Created by augusto callejas on 3/13/12.
//  Copyright 2012 Canary Falls Software LLC. All rights reserved.
//

#import "AboutUsViewController.h"


@implementation AboutUsViewController

@synthesize leftLabel;
@synthesize rightLabel;
@synthesize descriptionText;
@synthesize emailUsButton;
@synthesize facebookUsButton;
@synthesize twitterUsButton;
@synthesize tosButton;
@synthesize privacyButton;
@synthesize iconsFromLabel;

#pragma mark -
#pragma mark UIWebViewController methods

- (void) didDismissModalView {
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark IBAction methods

- (IBAction)doEmailUs {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:support@supervote.org"]];
}

- (IBAction)doFacebook {
	LogInfo(@"TODO: fill with facebook url");
}

- (IBAction)doTermsOfService {
	NSString* launchUrl = @"http://supervote.org/termsofservice.html";
	
	UIWebViewController *controller = [[UIWebViewController alloc] initWithNibName:@"UIWebViewController" bundle:nil];
	controller.title =NSLocalizedString(@"TOS", nil);
	controller.url = launchUrl;
	controller.delegate = self;
	
	[self presentModalViewController:controller animated:YES];
	[controller release];
}

- (IBAction)doPrivacy {
	NSString* launchUrl = @"http://supervote.org/privacy.html";
	
	UIWebViewController *controller = [[UIWebViewController alloc] initWithNibName:@"UIWebViewController" bundle:nil];
	controller.title = NSLocalizedString(@"Privacy", nil);
	controller.url = launchUrl;
	controller.delegate = self;
	
	[self presentModalViewController:controller animated:YES];
	[controller release];
}

- (IBAction)doTwitter {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://mobile.twitter.com/supervote"]];
}

- (IBAction)doGotoQuiz {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.gotoquiz.com/web-coding/web-design/royalty-free-state-flag-icons"]];
}

- (IBAction)doIconDrawer {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.icondrawer.com/"]];
}

- (IBAction)doFatCow {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.fatcow.com/free-icons"]];
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
	UIFont *font = [UIFont fontWithName:@"LeagueGothic" size:50.0];
	[leftLabel setFont:font];
	[rightLabel setFont:font];
	
	[descriptionText setText:NSLocalizedString(@"SupervoteDescription", nil)];
	
	[emailUsButton setTitle:NSLocalizedString(@"EmailUs", nil) forState:UIControlStateNormal];
	[facebookUsButton setTitle:NSLocalizedString(@"FacebookUs", nil) forState:UIControlStateNormal];
	[twitterUsButton setTitle:NSLocalizedString(@"TwitterUs", nil) forState:UIControlStateNormal];
	[tosButton setTitle:NSLocalizedString(@"TOS", nil) forState:UIControlStateNormal];
	[privacyButton setTitle:NSLocalizedString(@"Privacy", nil) forState:UIControlStateNormal];
	
	[iconsFromLabel setText:NSLocalizedString(@"IconsFrom", nil)];
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
