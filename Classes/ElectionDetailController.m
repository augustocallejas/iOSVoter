    //
//  ElectionDetailController.m
//  Supervote
//
//  Created by augusto callejas on 8/9/11.
//  Copyright 2011 Supervote, LLC. All rights reserved.
//

#import "ElectionDetailController.h"
#import "ChooseCandidateController.h"


@implementation ElectionDetailController

@synthesize electionTitle;

#pragma mark -
#pragma mark UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 0)
	{
		return 4;
	}
	
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section == 0)
	{
		return @"Details";
	}
	
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell;
	
	NSString *text = @"Title";
	NSString *detailText = @"detail text";
	
	if ([indexPath length] == 2)
	{
		if ([indexPath indexAtPosition:0] == 0)
		{
			NSUInteger index = [indexPath indexAtPosition:1];
			if (index == 0)
			{
				text = @"President and Vice President";
				detailText = @"John F. Kerry & John Edwards";
			}
			else if (index == 1)
			{
				text = @"Secretary of State";
				detailText = @"";
			}
			else if (index == 2)
			{
				text = @"State Treasurer";
				detailText = @"Randall Edwards";
			}
			else if (index == 3)
			{
				text = @"Proposition 19";
				detailText = @"Regulate, Control & Tax Cannabis Act";
			}
		}
	}
	
	cell = [tableView dequeueReusableCellWithIdentifier:@"default"];
	
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"default"] autorelease];
	}
	
	cell.textLabel.text = text;
	cell.detailTextLabel.text = detailText;
	
	NSString *path = [[NSBundle mainBundle] pathForResource:@"users" ofType:@"png"]; 
	UIImage *icon = [UIImage imageWithContentsOfFile:path];
	cell.imageView.image = icon;
	
	return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([indexPath length] == 2)
	{
		/* Only one section */
		if ([indexPath indexAtPosition:0] == 0)
		{
			// TODO: unnecessarily creating a new controller on each selection!
			ChooseCandidateController *controller = [[ChooseCandidateController alloc] initWithNibName:@"ChooseCandidate" bundle:[NSBundle mainBundle]];
			controller.selectedRow = -1;
			[[self navigationController] pushViewController:controller animated:YES];
			[controller release];
			controller = nil;			
		}
	}
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
	[electionTitle release];
}


@end
