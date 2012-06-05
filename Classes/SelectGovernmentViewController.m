//
//  SelectGovernmentViewController.m
//  Supervote
//
//  Created by augusto callejas on 6/2/12.
//  Copyright 2012 Canary Falls Software LLC. All rights reserved.
//

#import "SelectGovernmentViewController.h"

@implementation SelectGovernmentViewController

@synthesize registration;
@synthesize selectedRow;
@synthesize choice;
@synthesize client;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	self.selectedRow = nil;
	
	UITextView *tableHeader = [[UITextView alloc] initWithFrame:CGRectMake(0.0, 0.0, 300, 64.0)];
	tableHeader.editable = NO;
	tableHeader.backgroundColor = [UIColor clearColor];
	tableHeader.textAlignment = UITextAlignmentCenter;
	tableHeader.font = [UIFont systemFontOfSize:16];
	tableHeader.text = [NSString stringWithFormat:@"%@ %@ %@",
						NSLocalizedString(@"WhereIn", nil),
						self.registration.registration.government.name,
						NSLocalizedString(@"AreYou", nil)];
	
	self.tableView.tableHeaderView = tableHeader;
	[tableHeader release];
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
-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
		// back button was pressed.  We know this is true because self is no longer
		// in the navigation stack.
		if (self.selectedRow != nil) {
			Government *choice = [self.fetchedResultsController objectAtIndexPath:self.selectedRow];
			
			[self.client selectGovernment:self.registration withChoice:choice];
		}
    }
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
#pragma mark FetchedResultsBasedTableViewController implementation methods

- (NSString *)getEntityName{
	return @"Government";
}

- (NSString *)getSectionNameKeyPath{
	return @"governmentType.name";
}

- (NSString *)getCacheName{
	/* TODO: cache name must be different for each candidate? this may be a general issue across my controllers */
	return nil;
}

- (NSArray *)allocSortDescriptors{
	NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:@"governmentType.displayOrder" ascending:YES];
	NSSortDescriptor *sort2 = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
	return [NSArray arrayWithObjects:sort1, sort2, nil];
}

- (NSPredicate *)getPredicate{
	return [NSPredicate predicateWithFormat:@"potentialGovernmentRegistrations contains %@", self.registration];
}

- (NSString *)getCellIdentifier{
	return @"SelectGovernmentViewController";
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	Government *government = [self.fetchedResultsController objectAtIndexPath:indexPath];
	cell.textLabel.text = government.name;
//	cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
//	cell.accessoryType = UITableViewCellAccessoryCheckmark;
	
	if (self.selectedRow != nil && [self.selectedRow isEqual:selectedRow]) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}

	cell.textLabel.adjustsFontSizeToFitWidth = YES;
	cell.textLabel.minimumFontSize = 12;
}

#pragma mark -
#pragma mark Table view data source

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
#pragma mark UITableViewDelegate delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.selectedRow == nil) {
		self.selectedRow = indexPath;
		[self.tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
		
		self.choice = [self.fetchedResultsController objectAtIndexPath:self.selectedRow];
	}
	else if ([self.selectedRow isEqual:indexPath]) {
		[self.tableView cellForRowAtIndexPath:self.selectedRow].accessoryType = UITableViewCellAccessoryNone;
		self.selectedRow = nil;
		
		self.choice = nil;
	}
	else if (![self.selectedRow isEqual:indexPath]) {
		[self.tableView cellForRowAtIndexPath:self.selectedRow].accessoryType = UITableViewCellAccessoryNone;
		self.selectedRow = indexPath;
		[self.tableView cellForRowAtIndexPath:self.selectedRow].accessoryType = UITableViewCellAccessoryCheckmark;
		
		self.choice = [self.fetchedResultsController objectAtIndexPath:self.selectedRow];
	}

	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
//	NSLog(@"Display detailed information about this government");
//}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 32.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	/* http://www.iphonedevsdk.com/forum/iphone-sdk-development/5172-font-size-color-tableview-header.html */
	UIFont *font = [UIFont fontWithName:@"LeagueGothic" size:22.0];
	
	UIView* customView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 300.0, 32.0)] autorelease];
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
	label.opaque = NO;
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor darkGrayColor];
	label.font = font;
	label.adjustsFontSizeToFitWidth = YES;
	label.minimumFontSize = 18.0;
	label.frame = CGRectMake(10.0, 0.0, 290.0, 32.0);
	
	label.text = [self tableView:tableView titleForHeaderInSection:section];
	
	[customView addSubview:label];
	return customView;
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
	self.tableView.tableHeaderView = nil;
}

- (void)dealloc {
	self.registration = nil;
	self.selectedRow = nil;
	self.choice = nil;
	self.client = nil;
    [super dealloc];
}

@end

