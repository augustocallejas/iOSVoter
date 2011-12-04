//
//  FeedController.m
//  Supervote
//
//  Created by augusto callejas on 8/4/11.
//  Copyright 2011 Supervote, LLC. All rights reserved.
//

#import "FeedController.h"


@implementation FeedController

@synthesize managedObjectContext = _managedObjectContext;

#pragma mark -
#pragma mark UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 0)
	{
		return 0;
	}
	
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return @"Feed";
}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//	UITableViewCell *cell;
//	
//	NSString *text = @"Title";
//	NSString *detailText = @"detail text";
//	
//	if ([indexPath length] == 2)
//	{
//		if ([indexPath indexAtPosition:0] == 0)
//		{
//			NSUInteger index = [indexPath indexAtPosition:1];
//			if (index == 0)
//			{
//				text = @"2012 Presidential Election";
//				detailText = @"November 6th, 2012";
//			}
//			else if (index == 1)
//			{
//				text = @"2016 Presidential Election";
//				detailText = @"";
//			}
//		}
//	}
//	
//	cell = [tableView dequeueReusableCellWithIdentifier:@"default"];
//	
//	if (cell == nil)
//	{
//		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"default"] autorelease];
//	}
//	
//	cell.textLabel.text = text;
//	cell.detailTextLabel.text = detailText;
//	
//	NSString *path = [[NSBundle mainBundle] pathForResource:@"users" ofType:@"png"]; 
//	UIImage *icon = [UIImage imageWithContentsOfFile:path];
//	cell.imageView.image = icon;
//	
//	return cell;
//}

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

#pragma mark -
#pragma mark View methods

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	client = [[SupervoteClient alloc] init];
	
	NSError *error = nil;
	NSArray *elections = [client getElections];
	/* TODO: run in background? */
	[client insertElections:elections intoManagedContext:_managedObjectContext withError:&error];
	
//	error = nil;
//	NSArray *friends = [client getFriends];
//	[client insertFriends:friends intoManagedContext:_managedObjectContext withError:&error];
	

	//NSLog(@"Elections: %@", [client getElections]);
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
	[client release];
}


- (void)dealloc {
	self.managedObjectContext = nil;
    [super dealloc];
}


@end
