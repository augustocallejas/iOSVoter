//
//  VoterRegistrationViewController.m
//  Supervote
//
//  Created by augusto callejas on 5/20/12.
//  Copyright 2012 Canary Falls Software LLC. All rights reserved.
//

#import "VoterRegistrationViewController.h"

#import "DistrictRegistration.h"
#import "GovernmentRegistration.h"
#import "PotentialDistrictRegistration.h"

@implementation VoterRegistrationViewController

@synthesize context;
@synthesize client;
@synthesize registrations;
@synthesize sortedDistrictRegistrations;
@synthesize pushedDistrictController;
@synthesize pushedController;

#pragma mark -
#pragma mark View lifecycle

- (void)getRegistration {
	NSError *error = nil;
	NSDictionary *profile = [self.client getProfileWithError:&error];
	if (error != nil) {
		LogError(@"Error while retrieving registration: %@", [error localizedDescription]);
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
	
	if (sortedDistrictRegistrations == nil) {
		sortedDistrictRegistrations = [[NSMutableArray alloc] initWithCapacity:[self.registrations count]];
	}
	else {
		[sortedDistrictRegistrations removeAllObjects];
	}

	
	NSSortDescriptor *sort2 =
	[[NSSortDescriptor alloc] initWithKey:@"districtType.displayOrder" ascending:YES];
	
	NSArray *descriptors = [NSArray arrayWithObjects:sort2, nil];
	
	for (GovernmentRegistration *registration in self.registrations) {
		
		LogDebug(@"GovernmentRegistration (%@, %@) has %d potential district registration(s)",
				 registration.government.governmentType.name,
				 registration.government.name,
				 [registration.potentialRegistrations count]);
		
		NSMutableArray *allOfThem = [[NSMutableArray alloc] initWithArray:[registration.registrations allObjects]];
		[allOfThem addObjectsFromArray:[registration.potentialRegistrations allObjects]];
		
		[sortedDistrictRegistrations addObject:[allOfThem sortedArrayUsingDescriptors:descriptors]];
		[allOfThem release];
	}
	[sort2 release];	
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
		
	if (self.pushedController != nil) {
		if (self.pushedController.choice != nil) {
			[[ProgressHUD defaultHUD] showInView:self.view];
			[self.client selectGovernment:self.pushedController.registration
							   withChoice:self.pushedController.choice
							 withDelegate:self];
		}
		
		self.pushedController = nil;
	}
	else if (self.pushedDistrictController != nil) {
		if (self.pushedDistrictController.choice != nil) {
			[[ProgressHUD defaultHUD] showInView:self.view];
			[self.client selectDistrict:self.pushedDistrictController.registration
							 withChoice:self.pushedDistrictController.choice
						   withDelegate:self];
		}
		
		self.pushedDistrictController = nil;
	}
	else {
		[self getRegistration];
		[self loadRegistration];
		
		[self.tableView reloadData];
		[self.tableView beginUpdates];
		[self.tableView endUpdates];
	}
}

- (void)selectDistrictSuccess {
	[self selectChoiceSuccess];
}

- (void)selectGovernmentSuccess {
	[self selectChoiceSuccess];
}

- (void)selectChoiceSuccess {
	[[ProgressHUD defaultHUD] hideActivityIndicator];
		
	[self loadRegistration];
	[self.tableView reloadData];
	[self.tableView beginUpdates];
	[self.tableView endUpdates];
}

- (void)selectDistrictFailed:(NSNumber *)status {
	[self selectChoiceFailed:status];
}

- (void)selectGovernmentFailed:(NSNumber *)status {
	[self selectChoiceFailed:status];
}

- (void)selectChoiceFailed:(NSNumber *)status {
	[[ProgressHUD defaultHUD] hideActivityIndicator];
	
	NSString *title = nil;
	NSString *message = nil;
	switch ([status intValue]) {
		case STATUS_BAD_REQUEST:
			title = NSLocalizedString(@"BadRequestTitle", nil);
			message = NSLocalizedString(@"BadRequestMessage", nil);
			break;
			break;
		case STATUS_HTTP_ERROR:
			title = NSLocalizedString(@"HttpErrorTitle", nil);
			message = NSLocalizedString(@"HttpErrorMessage", nil);
			break;
		case STATUS_SERVER_ERROR:
			title = NSLocalizedString(@"ServerErrorTitle", nil);
			message = NSLocalizedString(@"SaveVoteServerErrorMessage", nil);
			break;
		case STATUS_UNEXPECTED_RESPONSE:
		default:
			title = NSLocalizedString(@"UnexpectedResponseTitle", nil);
			message	= NSLocalizedString(@"UnexpectedResponseMessage", nil);
			break;
	}

	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
													message:message 
												   delegate:nil 
										  cancelButtonTitle:NSLocalizedString(@"OK", nil)
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
}

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
	NSInteger count = [self.registrations count];
	if (count > 0 && [[self.registrations lastObject] potentialGovernmentRegistration] != nil) {
		count++;
	}
	return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if (section >= [self.registrations count]) {
		return 1;
	}
	
	return 1 + [[self.sortedDistrictRegistrations objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"VoterRegistrationViewController";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		//[cell.textLabel setFont:[UIFont systemFontOfSize:14.0]];
		//[[cell textLabel] setFont:[UIFont systemFontOfSize:12.0]];
		//	label.minimumFontSize = 18.0;
    }
	
	/* by default, no decorations */
	cell.imageView.image = nil;
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.textLabel.adjustsFontSizeToFitWidth = YES;
	cell.textLabel.minimumFontSize = 12;
    
	if ([indexPath section] >= [self.registrations count]) {
		/* handle special case of a PotentialGovernmentRegistration */

		PotentialGovernmentRegistration *potentialGovernmentRegistration = 
		[[self.registrations lastObject] potentialGovernmentRegistration];
		
		cell.textLabel.text = [NSString stringWithFormat:@"%d %@",
							   [potentialGovernmentRegistration.choices count],
							   NSLocalizedString(@"Choices", nil)];
		
		cell.imageView.image = [UIImage imageNamed:@"error.png"];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	}
	else {
		GovernmentRegistration *registration = [self.registrations objectAtIndex:[indexPath section]];
		
		if ([indexPath row] == 0) {
			cell.textLabel.text = registration.government.name;
			//	cell.detailTextLabel.text = @"detailText";
			/* TODO: temporary */
		}
		else {			
			NSArray *districtRegistrations = [self.sortedDistrictRegistrations objectAtIndex:indexPath.section];
			id obj = [districtRegistrations objectAtIndex:(indexPath.row - 1)];
			
			if ([obj isKindOfClass:[DistrictRegistration class]]) {
				DistrictRegistration *reg = (DistrictRegistration *)obj;
				cell.textLabel.text = reg.district.name;
				cell.detailTextLabel.text = reg.district.districtType.name;
			}
			else if ([obj isKindOfClass:[PotentialDistrictRegistration class]]) {
				PotentialDistrictRegistration *reg = (PotentialDistrictRegistration *)obj;
				cell.textLabel.text = [NSString stringWithFormat:@"%d %@",
									   [reg.choices count],
									   NSLocalizedString(@"Choices", nil)];
				cell.detailTextLabel.text = reg.districtType.name;
				
				cell.imageView.image = [UIImage imageNamed:@"error.png"];
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			}
		}
	}
    
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
	
	if (section >= [self.registrations count]) {
		label.text = [[[self.registrations lastObject] government] name]; 
	}
	else {
		label.text = [[[[self.registrations objectAtIndex:section] government] governmentType] name];
	}
	
	[customView addSubview:label];
	return customView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section >= [self.registrations count]) {
		
		SelectGovernmentViewController *controller = [[SelectGovernmentViewController alloc] initWithNibName:@"SelectGovernmentViewController" bundle:[NSBundle mainBundle]];
		controller.registration = [[self.registrations lastObject] potentialGovernmentRegistration];
		controller.client = client;
		controller.managedObjectContext = self.context;
		
		/* remember which registration was selected */
		self.pushedController = controller;
		
		[[self navigationController] pushViewController:controller animated:YES];
		[controller release];
	}
	else if (indexPath.row > 0) {
		NSArray *districtRegistrations = [self.sortedDistrictRegistrations objectAtIndex:indexPath.section];
		id obj = [districtRegistrations objectAtIndex:(indexPath.row - 1)];
		
		if ([obj isKindOfClass:[PotentialDistrictRegistration class]]) {
			PotentialDistrictRegistration *reg = (PotentialDistrictRegistration *)obj;
			
			SelectDistrictViewController *controller = [[SelectDistrictViewController alloc] initWithNibName:@"SelectDistrictViewController" bundle:[NSBundle mainBundle]];
			controller.registration = reg;
			controller.client = self.client;
			controller.managedObjectContext = self.context;
			
			/* remember which registration was selected */
			self.pushedDistrictController = controller;
			
			[[self navigationController] pushViewController:controller animated:YES];
			[controller release];
		}
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
	self.context = nil;
	self.client = nil;
	self.registrations = nil;
	self.sortedDistrictRegistrations = nil;
	self.pushedDistrictController = nil;
	self.pushedController = nil;
    [super dealloc];
}


@end

