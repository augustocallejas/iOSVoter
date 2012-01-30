//
//  SupervoteViewController.m
//  Supervote
//
//  Created by augusto callejas on 8/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SupervoteViewController.h"

#import "SupervoteAppDelegate.h"

@implementation SupervoteViewController

@synthesize FirstZIPField;
@synthesize SecondZIPField;
@synthesize joinButton;
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


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


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
#pragma mark IBAction methods

- (IBAction)doCopyrightButton {
	NSString* launchUrl = @"http://www.canaryfalls.com";
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString: launchUrl]];
}

- (IBAction)doJoinButtonSendZip {
	NSString *ZIP;
	
	if ([FirstZIPField.text length] != 5) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid ZIP Code" 
														message:@"ZIP Code must contain 5 digits." 
													   delegate:nil 
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	else if ([SecondZIPField.text length] != 0 && [SecondZIPField.text length] != 4) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid ZIP+4 Code" 
														message:@"ZIP+4 Code must contain 4 digits." 
													   delegate:nil 
											  cancelButtonTitle:@"OK"
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
				NSLog(@"Error: %@", [error userInfo]);
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to connect to server"
																message:[error localizedDescription]
															   delegate:nil 
													  cancelButtonTitle:@"OK"
													  otherButtonTitles:nil];
				[alert show];
				[alert release];
			}
			else {
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bad ZIP Code" 
																message:@"Invalid ZIP Code, please review and try again." 
															   delegate:nil 
													  cancelButtonTitle:@"OK"
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
