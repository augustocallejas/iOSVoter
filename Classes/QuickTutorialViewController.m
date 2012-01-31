//
//  QuickTutorialViewController.m
//  Supervote
//
//  Created by augusto callejas on 1/30/12.
//  Copyright 2012 Canary Falls Software LLC. All rights reserved.
//

#import "QuickTutorialViewController.h"

#import <QuartzCore/QuartzCore.h>
#import "SupervoteAppDelegate.h"

@implementation QuickTutorialViewController

@synthesize privacyCell1 = _privacyCell1;
@synthesize privacyCell2 = _privacyCell2;

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
	
	_privacyCell1.layer.cornerRadius = 10.0f;
	_privacyCell1.layer.borderColor = [UIColor grayColor].CGColor;
	_privacyCell1.layer.borderWidth = 1.0f;
	
	_privacyCell2.layer.cornerRadius = 10.0f;
	_privacyCell2.layer.borderColor = [UIColor grayColor].CGColor;
	_privacyCell2.layer.borderWidth = 1.0f;
}

#pragma mark -
#pragma mark Custom IBAction methods

- (void)markAsViewed {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:@"1" forKey:@"ShowedTutorial"];
	[defaults synchronize];
}

- (IBAction)doShowBallots {
	[self markAsViewed];
	
	SupervoteAppDelegate *appDelegate = (SupervoteAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate switchToMainApp:self.view];
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
