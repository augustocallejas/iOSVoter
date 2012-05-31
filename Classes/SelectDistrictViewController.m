//
//  SelectDistrictViewController.m
//  Supervote
//
//  Created by augusto callejas on 5/29/12.
//  Copyright 2012 Canary Falls Software LLC. All rights reserved.
//

#import "SelectDistrictViewController.h"

#import "District.h"

@implementation SelectDistrictViewController

@synthesize registration;
@synthesize sortedDistricts;
@synthesize client;

#pragma mark -
#pragma mark View lifecycle

- (void)loadDistricts {
	NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"districtNum" ascending:YES];
	
	NSArray *descriptors = [NSArray arrayWithObjects:sort, nil];
	
	if (sortedDistricts == nil) {
		sortedDistricts = [[NSMutableArray alloc] initWithCapacity:[self.registration.choices count]];
	}
	
	[sortedDistricts addObjectsFromArray:[[self.registration.choices allObjects] sortedArrayUsingDescriptors:descriptors]];
	
	[sort release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self loadDistricts];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [sortedDistricts count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"SelectDistrictViewController";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	District *district = [sortedDistricts objectAtIndex:indexPath.row];
    cell.textLabel.text = district.name;
	
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {	
//	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	District *district = [sortedDistricts objectAtIndex:indexPath.row];
	NSDate *date = nil;
	
	if ((date = [client selectDistrict:self.registration withChoice:district]) != nil) {
		/* replace PotentialDistrictRegistration with DistrictRegistration */
		NSError *error = nil;
		[client resolveDistrictRegistration:self.registration
							   withDistrict:district
							withCreatedTime:date
								  withError:&error];
		
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		
		[self.navigationController popViewControllerAnimated:YES];
	}
	else {
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		
		/* TODO: it isn't always an HttpError! */
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"HttpErrorTitle", nil)
														message:NSLocalizedString(@"HttpErrorMessage", nil)
													   delegate:nil 
											  cancelButtonTitle:NSLocalizedString(@"OK", nil)
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	self.registration = nil;
	self.sortedDistricts = nil;
	self.client = nil;
    [super dealloc];
}


@end

