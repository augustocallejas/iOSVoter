//
//  ElectionsController.m
//  Supervote
//
//  Created by augusto callejas on 8/4/11.
//  Copyright 2011 Supervote, LLC. All rights reserved.
//

#import "Election.h"
#import "ElectionsController.h"
#import "ElectionDetailController.h"

@implementation ElectionsController

@synthesize managedObjectContext;
@synthesize elections;

#pragma mark -
#pragma mark UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 0)
	{
		if (self.elections != nil)
		{
			return [self.elections count];
		}
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
			NSManagedObject *object = (NSManagedObject *)[self.elections objectAtIndex:indexPath.row];
			
			text = [object valueForKey:@"title"];
			detailText =  [(NSDate *)[object valueForKey:@"date"] description];
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
			
			Election *election = (Election *) [self.elections objectAtIndex:indexPath.row];
			controller.title = election.title;
			controller.electionTitle = election.title;
			
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
	if (self.elections == nil)
	{
		NSError *error;
		
//		// insert data in the context
//		Election *election1 = (Election*) [NSEntityDescription insertNewObjectForEntityForName:@"Election" inManagedObjectContext:managedObjectContext];
//		election1.title = @"2012 Presidential Election";
//		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//		dateFormatter.dateFormat = @"dd-MM-yy";
//		election1.date = [dateFormatter dateFromString:@"06-11-12"];//[NSDate dateWithString:@"2012-11-06 00:00:00 -0700"];
//		[dateFormatter release];
//		
//		NSError *error = nil;
//		if (![managedObjectContext save:&error]) {
//			NSLog(@"  DetailedError: %@", [error userInfo]);
//			NSLog(@"no!");
//			// Handle the error
//		}
		
		// adding core data: http://wiresareobsolete.com/wordpress/2009/12/adding-core-data-existing-iphone-projects/
		// http://developer.apple.com/library/ios/#documentation/DataManagement/Conceptual/CoreDataSnippets/Introduction/Introduction.html
		// fetch data in the context
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Election" inManagedObjectContext:managedObjectContext];
		[fetchRequest setEntity:entity];
		
		//NSError *error = nil;
		// TODO: how do i know this is autoreleased?
		// http://stackoverflow.com/questions/1396967/iphone-core-data-executefetchrequest-memory-issue
		NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
		if (fetchedObjects == nil) {
			// Handle the error
			NSLog(@"no!");
		}
		
		self.elections = fetchedObjects;
		
		[fetchRequest release];
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
	[managedObjectContext release];
	[elections release];
    [super dealloc];
}


@end
