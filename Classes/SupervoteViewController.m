//
//  SupervoteViewController.m
//  Supervote
//
//  Created by augusto callejas on 8/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SupervoteViewController.h"

#import "SupervoteAppDelegate.h"
#import "UIWebViewController.h"

@implementation SupervoteViewController

@synthesize leftLabel = _leftLabel;
@synthesize rightLabel = _rightLabel;
@synthesize ZIPCodePrompt;
@synthesize FirstZIPField;
@synthesize SecondZIPField;
@synthesize joinButton;
@synthesize agreeStatement;
@synthesize tosButton;
@synthesize privacyButton;
//@synthesize mainAppController;
@synthesize client = _client;

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	UIFont *font = [UIFont fontWithName:@"LeagueGothic" size:50.0];
	[_leftLabel setFont:font];
	[_rightLabel setFont:font];
	
	[ZIPCodePrompt setText:NSLocalizedString(@"ZIPCodePrompt", nil)];
	[joinButton setTitle:NSLocalizedString(@"Join", nil) forState:UIControlStateNormal];
	[agreeStatement setText:NSLocalizedString(@"AgreeStatement", nil)];
	[tosButton setTitle:NSLocalizedString(@"TOS", nil) forState:UIControlStateNormal];
	[privacyButton setTitle:NSLocalizedString(@"Privacy", nil) forState:UIControlStateNormal];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string  
{  
    BOOL validCharactersInRange = YES;  
    if (![string isEqualToString:@""])  
    {
        NSUInteger testLength = textField.text.length + string.length + range.length;
		NSUInteger max = FirstZIPField == textField ? 5 : 4;
        validCharactersInRange = (testLength > max) ? NO : YES; //change the 1 to your textfield's upper limit
		
		if (FirstZIPField == textField && !validCharactersInRange && range.location == 5 && range.length == 0)
		{
			[SecondZIPField becomeFirstResponder];
			SecondZIPField.text = [string retain];
		}
    }  
	
    return validCharactersInRange;  
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return NO;
}

#pragma mark -
#pragma mark UIWebViewController methods

- (void) didDismissModalView {
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark IBAction methods

- (IBAction)doTermsOfService {
	NSString* launchUrl = @"http://supervote.org/termsofservice.html";
	
	UIWebViewController *controller = [[UIWebViewController alloc] initWithNibName:@"UIWebViewController" bundle:nil];
	controller.title = NSLocalizedString(@"TOS", nil);
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

- (IBAction)doJoinButtonSendZip {
	NSString *ZIP;
	
	if ([FirstZIPField.text length] != 5) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"InvalidZIPTitle", nil)
														message:NSLocalizedString(@"InvalidZIPMessage", nil) 
													   delegate:nil 
											  cancelButtonTitle:NSLocalizedString(@"OK", nil)
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	else if ([SecondZIPField.text length] != 0 && [SecondZIPField.text length] != 4) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"InvalidZIP4Title", nil)
														message:NSLocalizedString(@"InvalidZIP4Message", nil) 
													   delegate:nil 
											  cancelButtonTitle:NSLocalizedString(@"OK", nil)
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	else
	{
		if ([SecondZIPField.text length] == 0) {
			ZIP = [NSString stringWithFormat:@"%@", FirstZIPField.text];
		}
		else {
			ZIP = [NSString stringWithFormat:@"%@%@", FirstZIPField.text, SecondZIPField.text];
		}
		
		NSError *error = nil;
		if ([_client registerDevice:ZIP withError:&error]) {
			SupervoteAppDelegate *appDelegate = (SupervoteAppDelegate *)[[UIApplication sharedApplication] delegate];
			[appDelegate switchToMainApp:self.view];
		}
		else {
			//
			if (error != nil) {
				/* TODO: see if someone comes up with a better answer: http://stackoverflow.com/questions/10039420/accessing-localized-error-message-from-asihttprequest-calls */
				NSString *errorStr = [[[error userInfo] objectForKey:@"NSUnderlyingError"] localizedFailureReason];
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"HttpErrorTitle", nil)
																message:errorStr//[error localizedDescription]
															   delegate:nil 
													  cancelButtonTitle:NSLocalizedString(@"OK", nil)
													  otherButtonTitles:nil];
				[alert show];
				[alert release];
			}
			else {
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"BadZIPTitle", nil) 
																message:NSLocalizedString(@"BadZIPMessage", nil) 
															   delegate:nil 
													  cancelButtonTitle:NSLocalizedString(@"OK", nil)
													  otherButtonTitles:nil];
				[alert show];
				[alert release];
			}
		}
	}
}


- (void)dealloc {
	self.client = nil;
	if (responseData != nil) {
		[responseData release];
	}
	//[FirstZIPField dealloc];
	//[SecondZIPField dealloc];
	//[joinButton dealloc];
	//[mainAppController dealloc];
    [super dealloc];
}

@end
