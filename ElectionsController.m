//
//  ElectionsController.m
//  Supervote
//
//  Created by augusto callejas on 8/4/11.
//  Copyright 2011 Supervote, LLC. All rights reserved.
//

#import "ElectionsController.h"
#import "ElectionDetailController.h"

@implementation ElectionsController

@synthesize managedObjectContext;

#pragma mark -
#pragma mark UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 0)
	{
		//NSManagedObjectModel *model = [[managedObjectContext persistentStoreCoordinator] managedObjectModel];
		//[[model entitiesByName] objectForKey:@"Election"];
		return 2;
	}
	
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section == 0)
	{
		return @"Elections";
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
				text = @"2012 Presidential Election";
				detailText = @"November 6th, 2012";
			}
			else if (index == 1)
			{
				text = @"2016 Presidential Election";
				detailText = @"";
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
			ElectionDetailController *controller = [[ElectionDetailController alloc] initWithNibName:@"ElectionDetail" bundle:[NSBundle mainBundle]];
			
			NSString *electionTitle = @"No title!";
			/* Index of Election */
			NSUInteger index = [indexPath indexAtPosition:1];
			if (index == 0)
			{
				electionTitle = @"2012 Election";
			}
			else if (index == 1)
			{
				electionTitle = @"2016 Election";
			}
			
			controller.title = electionTitle;
			controller.electionTitle = electionTitle;
			
			[[self navigationController] pushViewController:controller animated:YES];
			[controller release];
			controller = nil;			
		}
	}
}


#pragma mark -
#pragma mark UIController methods


// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
		NSLog(@"%p", self);
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	//[[UIApplication sharedApplication] man
	//self.managedObjectContext = [(SupervoteAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
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
	[managedObjectContext release];
    [super dealloc];
}


@end
