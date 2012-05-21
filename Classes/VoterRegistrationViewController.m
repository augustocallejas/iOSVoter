//
//  VoterRegistrationViewController.m
//  Supervote
//
//  Created by augusto callejas on 5/20/12.
//  Copyright 2012 Canary Falls Software LLC. All rights reserved.
//

#import "VoterRegistrationViewController.h"

#import "GovernmentRegistration.h"

@implementation VoterRegistrationViewController

@synthesize context;
@synthesize client;
@synthesize registrations;

#pragma mark -
#pragma mark View lifecycle

- (void)getRegistration {
	NSError *error = nil;
	NSDictionary *profile = [self.client getProfileWithError:&error];
	if (error != nil) {
		LogError(@"Error while retrieving registration: %@", [error userInfo]);
	}
	else {
		[self.client findOrInsertGovernmentRegistration:profile withDisplayOrder:0 withParent:nil withError:&error];
		
		if (error != nil) {
			LogError(@"Error while storing registration: %@", [error userInfo]);
		}
	}
}

- (void)loadRegistration {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"GovernmentRegistration" inManagedObjectContext:self.context];
	[fetchRequest setEntity:entity];
	
	NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"displayOrder" ascending:YES];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sort, nil]];
	
	//  [fetchRequest setFetchBatchSize:20];
	//	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"status = 1"]];
	
	NSError *error = nil;
	self.registrations = [self.context executeFetchRequest:fetchRequest error:&error];
	[sort release];
	
	LogInfo([NSString stringWithFormat:@"Loaded %d government registration(s)", [self.registrations count]]);
}

- (void)viewDidLoad {
    [super viewDidLoad];

	if (self.registrations == nil) {
		[self getRegistration];
		[self loadRegistration];
	}
	
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
#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
	return [self.registrations count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//	return [NSString stringWithFormat:@"Section %d", section];
	return [[[(GovernmentRegistration *) [self.registrations objectAtIndex:section] government] governmentType] name];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"VoterRegistrationViewController";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	GovernmentRegistration *registration = [self.registrations objectAtIndex:[indexPath section]];
	cell.textLabel.text = registration.government.name;
    
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
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    /*
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
    // ...
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
    */
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
	self.context = nil;
	self.client = nil;
	self.registrations = nil;
    [super dealloc];
}


@end

