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

@synthesize scrollView;
@synthesize toolBar;
@synthesize leftLabel = _leftLabel;
@synthesize rightLabel = _rightLabel;
@synthesize ZIPCodePrompt;
@synthesize AddressField;
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

- (void)doPrev {
	if ([self.AddressField isFirstResponder]) {
		[self.SecondZIPField becomeFirstResponder];
	}
	else if ([self.FirstZIPField isFirstResponder]) {
		[self.AddressField becomeFirstResponder];
	}
	else if ([self.SecondZIPField isFirstResponder]) {
		[self.FirstZIPField becomeFirstResponder];
	}
}

- (void)doNext {
	if ([self.AddressField isFirstResponder]) {
		[self.FirstZIPField becomeFirstResponder];
	}
	else if ([self.FirstZIPField isFirstResponder]) {
		[self.SecondZIPField becomeFirstResponder];
	}
	else if ([self.SecondZIPField isFirstResponder]) {
		[self.AddressField becomeFirstResponder];
	}
}

- (void)doDone {
	if ([self.AddressField isFirstResponder]) {
		[self.AddressField endEditing:YES];
	}
	else if ([self.FirstZIPField isFirstResponder]) {
		[self.FirstZIPField endEditing:YES];
	}
	else if ([self.SecondZIPField isFirstResponder]) {
		[self.SecondZIPField endEditing:YES];
	}
}

#pragma mark -
#pragma mark Keyboard/Scrolling methods

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWasShown:)
												 name:UIKeyboardDidShowNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillBeHidden:)
												 name:UIKeyboardWillHideNotification object:nil];
	
}

- (void)unregisterForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
													name:UIKeyboardDidShowNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:UIKeyboardWillHideNotification object:nil];
	
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
	
	float kbHeight = kbSize.height + [toolBar frame].size.height; 
	
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbHeight, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
	
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbHeight;
	CGPoint scrollPoint = CGPointMake(0.0, FirstZIPField.frame.origin.y-aRect.size.height);
	[self.scrollView setContentOffset:scrollPoint animated:YES];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	toolBar = [[UIToolbar alloc] init];
	[toolBar setBarStyle:UIBarStyleBlack];
	[toolBar setTranslucent:YES];
	[toolBar sizeToFit];
	
	self.AddressField.placeholder = NSLocalizedString(@"Address", nil);
	
	UIBarButtonItem *prev = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Previous", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(doPrev)];
	UIBarButtonItem *next = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(doNext)];
	
	[toolBar setItems:[NSArray arrayWithObjects:prev, next, nil]];
	[prev release];
	[next release];
	
	self.AddressField.inputAccessoryView = toolBar;
	self.FirstZIPField.inputAccessoryView = toolBar;
	self.SecondZIPField.inputAccessoryView = toolBar;
	
	UIFont *font = [UIFont fontWithName:@"LeagueGothic" size:50.0];
	[_leftLabel setFont:font];
	[_rightLabel setFont:font];
	
	[ZIPCodePrompt setText:NSLocalizedString(@"ZIPCodePrompt", nil)];
	[joinButton setTitle:NSLocalizedString(@"Join", nil) forState:UIControlStateNormal];
	[agreeStatement setText:NSLocalizedString(@"AgreeStatement", nil)];
	[tosButton setTitle:NSLocalizedString(@"TOS", nil) forState:UIControlStateNormal];
	[privacyButton setTitle:NSLocalizedString(@"Privacy", nil) forState:UIControlStateNormal];
	
	[self registerForKeyboardNotifications];
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
	[self unregisterForKeyboardNotifications];
	toolBar = nil;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string  
{
	if (textField == AddressField) {
		return YES;
	}
	
    BOOL validCharactersInRange = YES;  
    if (![string isEqualToString:@""])  
    {
		NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
		for (int i = 0; i < [string length]; i++) {
			unichar c = [string characterAtIndex:i];
			if (![myCharSet characterIsMember:c]) {
				return NO;
			}
		}
		
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
	/*
	 * 1. adddress + zip
	 * 2. zip + 4
	 *
	 */
	
	if ([FirstZIPField.text length] != 5) {
		/* ZIP doesn't contain 5 required digits */
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"InvalidZIPTitle", nil)
														message:NSLocalizedString(@"InvalidZIPMessage", nil) 
													   delegate:nil 
											  cancelButtonTitle:NSLocalizedString(@"OK", nil)
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	else if ([SecondZIPField.text length] != 0 && [SecondZIPField.text length] != 4) {
		/* ZIP contains 5 digits, but +4 portion is incomplete */
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
		NSString *ZIP;
		
		if ([SecondZIPField.text length] == 0) {
			ZIP = [NSString stringWithFormat:@"%@", FirstZIPField.text];
		}
		else {
			ZIP = [NSString stringWithFormat:@"%@%@", FirstZIPField.text, SecondZIPField.text];
		}
		
		NSError *error = nil;
		NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
		if ([_client registerDevice:ZIP withAddress:AddressField.text withLanguage:language withError:&error]) {
			
#ifdef USE_TESTFLIGHT
			[TestFlight passCheckpoint:@"RegisteredSuccessfully"];
#endif
			
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
