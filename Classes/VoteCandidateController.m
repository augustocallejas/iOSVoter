//
//  VoteCandidateController.m
//  Supervote
//
//  Created by augusto callejas on 8/25/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import "VoteCandidateController.h"

#import <QuartzCore/QuartzCore.h>

#import "Candidate.h"
#import "CandidateViewCell.h"
#import "CreateEndorsementViewController.h"
#import "FacebookFriend.h"
#import "Friend.h"
#import "FriendBallotVote.h"
#import "ListEndorsementsController.h"

@implementation VoteCandidateController

@synthesize ballot;
@synthesize position;
@synthesize selectedRow;
@synthesize selectedCell;

#pragma mark -
#pragma mark UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == actionSheet.destructiveButtonIndex) {
		Candidate *candidate = (Candidate *) [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:actionSheet.tag inSection:0]];
		[self presentCreateEndorsementViewController:candidate];
	}
	else if (buttonIndex == actionSheet.cancelButtonIndex) {
		/* do nothing */
	}
}

#pragma mark -
#pragma mark Custom button actions

- (void)voteOnCandidate:(id)sender{
	Candidate *candidate = (Candidate *) [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:((UIButton *)sender).tag inSection:0]];
	
	if (vote != nil && vote.forCandidate != candidate) {
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to change your vote?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Yes" otherButtonTitles:nil];
		actionSheet.tag = ((UIButton *)sender).tag;
		[actionSheet showFromTabBar:self.tabBarController.tabBar];
		[actionSheet release];
	}
	else {
		[self presentCreateEndorsementViewController:candidate];
	}
}

- (void)presentCreateEndorsementViewController:(Candidate *)candidate{
	CreateEndorsementViewController *controller = [[CreateEndorsementViewController alloc] initWithNibName:@"CreateEndorsementViewController" bundle:[NSBundle mainBundle]];
	controller.delegate = self;
	controller.candidate = candidate;
	/* default value is viewable by friends */
	controller.viewableByFriends = YES;
	controller.isEditOfExisting = NO;
	
	if (vote != nil && vote.forCandidate == candidate) {
		controller.statement = vote.statement;
		controller.viewableByFriends = [vote.viewableByFriends boolValue];
		controller.isEditOfExisting = YES;
	}
	
	[self presentModalViewController:controller animated:YES];
	[controller release];
}

- (void)didDismissModalView:(BOOL)withVote toCandidate:(Candidate *)candidate orMeasureVote:(NSNumber *)measureVote withOptionalStatement:(NSString *)statement andViewableByFriends:(BOOL)viewable {
	if (withVote) {
		if (vote == nil) {
			vote = [(BallotVote *) [NSEntityDescription insertNewObjectForEntityForName:@"BallotVote" inManagedObjectContext:self.managedObjectContext] retain];
			vote.forBallot = ballot;
			vote.forPosition = position;
		}
		vote.forCandidate = candidate;
		vote.statement = statement;
		vote.viewableByFriends = [NSNumber numberWithBool:viewable];
		
		NSError *error;
		if (![self.managedObjectContext save:&error]) {
			NSLog(@"  DetailedError: %@", [error userInfo]);
			// Handle the error
		}
		
		// update the detailed text, because otherwise it stays the same.
		self.selectedCell.minorTitle.text = vote.forCandidate.name;
		
		/* TODO: does this reload all cells, or only visible ones? */
		[self.tableView reloadData];
	}
	else {
		NSLog(@"User canceled their vote selection");
	}
	
	NSLog(@"Statement: [%@]", statement);

    // Dismiss the modal view controller
    [self dismissModalViewControllerAnimated:YES];
	
}

- (IBAction)viewAllEndorsements:(id)sender{
	UIButton *button = (UIButton *)sender;
	
	Candidate *candidate = (Candidate *) [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:button.tag inSection:0]];
	ListEndorsementsController *controller = [[ListEndorsementsController alloc] init];//initWithNibName:@"VoteMeasure" bundle:[NSBundle mainBundle]];
	controller.position = self.position;
	controller.candidate = candidate;
	controller.title = @"Endorsements";
	controller.managedObjectContext = self.managedObjectContext;
	
	[self.navigationController pushViewController:controller animated:YES];
	[controller release];
}


#pragma mark -
#pragma mark FetchedResultsBasedTableViewController implementation methods

- (NSString *)getEntityName{
	return @"Candidate";
}

- (NSString *)getSectionNameKeyPath{
	return nil;
}

- (NSString *)getCacheName{
	return @"VoteCandidateController";
}

- (NSArray *)allocSortDescriptors{
	NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"displayOrder" ascending:YES];
    return [NSArray arrayWithObject:sort];
}

- (NSPredicate *)getPredicate{
	return [NSPredicate predicateWithFormat:@"position == %@", position];
}

- (NSString *)getCellIdentifier{
	return @"VoteCandidateController";
}

- (void)configureCell:(CandidateViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	//NSLog(@"Configure %d", indexPath.row);
	Candidate *candidate = (Candidate *) [self.fetchedResultsController objectAtIndexPath:indexPath];
	
	cell.candidateName.text = candidate.name;
	if (candidate.party != nil) {
		cell.partyName.text = candidate.party;
	}
	else if (candidate.occupation != nil) {
		cell.partyName.text = candidate.occupation;
	}
	
	/* fill out the top endorsements, sorted by descending date */
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setFetchLimit:3];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"FriendBallotVote" inManagedObjectContext:[ballot managedObjectContext]];
	[request setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"forPosition == %@ && forCandidate == %@", position, candidate];
	[request setPredicate:predicate];
	
	NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
	[request setSortDescriptors:[NSArray arrayWithObject:sort]];
	
	UIImage *icon = [UIImage imageNamed:@"users.png"];
	cell.friendIcon1.image = icon;

	NSError *error = nil;
	NSArray *array = [[ballot managedObjectContext] executeFetchRequest:request error:&error];
	if (error == nil) {
		NSUInteger count = [array count];
		
		FriendBallotVote *friendVote;
		if (count > 0) {
			friendVote = (FriendBallotVote *) [array objectAtIndex:0];
			cell.friendEndorsement1.text = friendVote.statement;
			
			if (friendVote.author.facebook != nil && friendVote.author.facebook.photoDownloaded != nil) {				
				/* TODO: this section is copy and pasted elsewhere, consider evaluating once and accessing from app delegate */
				NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
				NSString *documentsDirectory = [paths objectAtIndex:0];
				NSString *path = [NSString stringWithFormat:@"%@/facebook/%@.gif", documentsDirectory, friendVote.author.facebook.friendId];
				UIImage *fbIcon = [UIImage imageWithContentsOfFile:path];
				
				cell.friendIcon1.image = fbIcon;
			}
			else {
				cell.friendIcon1.image = icon;
			}
			
			if (count > 1) {
				friendVote = (FriendBallotVote *) [array objectAtIndex:1];
				cell.friendEndorsement2.text = friendVote.statement;
				
				if (count > 2) {
					friendVote = (FriendBallotVote *) [array objectAtIndex:2];
					cell.friendEndorsement3.text = friendVote.statement;
				}
			}
		}
	}
	else {
		/* TODO: log error */
		NSLog(@"No");
	}
	
	[sort release];

	cell.friendIcon2.image = icon;
	cell.friendIcon3.image = icon;

	/* query for friends' votes on this candidate */
	entity = [NSEntityDescription entityForName:@"FriendBallotVote" inManagedObjectContext:[ballot managedObjectContext]];
	[request setEntity:entity];
	
	predicate = [NSPredicate predicateWithFormat:@"forPosition == %@ && forCandidate == %@", position, candidate];
	[request setPredicate:predicate];
	
	[request setSortDescriptors:[NSArray arrayWithObjects:nil]];
	
	NSUInteger count = [[ballot managedObjectContext] countForFetchRequest:request error:&error];
	if (error == nil) {
		/* don't count users vote */
//		if (vote != nil && vote.forCandidate == candidate) {
//			count++;
//		}
//		NSUInteger orgCount = 0;
//		NSString *string = [NSString stringWithFormat:@"%d friend%@, %d organization%@", count, count==1?@"":@"s", orgCount, orgCount==1?@"":@"s"];
		NSString *string = [NSString stringWithFormat:@"%d friend%@", count, count==1?@"":@"s"];

		[cell.viewAllEndorsements setTitle:string forState:UIControlStateNormal];
		
		CGSize stringsize = [string sizeWithFont:[UIFont boldSystemFontOfSize:14]]; 
		[cell.viewAllEndorsements setFrame:CGRectMake(7,45,stringsize.width+10, stringsize.height)];
		
		//cell.viewAllEndorsements.layer.borderColor = [UIColor grayColor].CGColor;
		//cell.viewAllEndorsements.layer.borderWidth = 1.0f;
	}
	else {
		/* TODO: log the error */
		NSLog(@"no!");
	}

	if (vote != nil && vote.forCandidate == candidate) {
		/* display the vote status image */
		cell.voteStatus.hidden = NO;
		
		/* hide and disable the "vote" button */
		cell.voteCandidate.enabled = NO;
		cell.voteCandidate.hidden = YES;
		
		/* display privacy level */
		cell.votePrivate.hidden = [vote.viewableByFriends boolValue];

		/* enable the "edit endorsement" button */
		cell.editEndorsement.enabled = YES;
		cell.editEndorsement.hidden = NO;
		[cell.editEndorsement setTitle:@"Edit endorsement" forState:UIControlStateNormal];
	}
	else {
		/* hide the vote status image */
	    cell.voteStatus.hidden = YES;
		
		/* display the "vote" button and enable it */
		[[cell.voteCandidate layer] setCornerRadius:8.0f];
		[[cell.voteCandidate layer] setMasksToBounds:YES];
		[[cell.voteCandidate layer] setBorderWidth:1.0f];
//		[cell.voteCandidate setBackgroundColor:[UIColor colorWithRed:0.5f green:0.5f blue:0.8f alpha:1.0f]];
		cell.voteCandidate.enabled = YES;
		cell.voteCandidate.hidden = NO;
		
		/* display privacy level */
		cell.votePrivate.hidden = YES;
		
		/* disable the "edit endorsement" button */
		cell.editEndorsement.enabled = NO;
		cell.editEndorsement.hidden = YES;
	}
	
	[request release];
}


#pragma mark -
#pragma mark Initialization

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle {
	self = [super initWithNibName:nibName bundle:nibBundle];
	
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	socialBallotView = [prefs boolForKey:@"SocialBallotMode"];
	if (self) {
		UISegmentedControl *control = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Compact", @"Expanded", nil]];
		control.segmentedControlStyle = UISegmentedControlStyleBar;
		control.selectedSegmentIndex = socialBallotView ? 1 : 0;
		[control addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
		self.navigationItem.titleView = control;
		[control release];
//		self.tableView.allowsSelection = NO;
//		[self.tableView setAllowsSelection:NO];
//		[self.tableView allowsSelection:NO];
	}
	
	return self;
}

- (void)segmentAction:(id)sender {
	UISegmentedControl* segCtl = sender;
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	if ([segCtl selectedSegmentIndex] == 0) {
		socialBallotView = NO;
	}
	else {
		socialBallotView = YES;
	}
	[prefs setBool:socialBallotView forKey:@"SocialBallotMode"];
	if (![prefs synchronize]) {
		NSLog(@"Did not synchronize correctly");
	}
	
	[self.tableView beginUpdates];
	[self.tableView endUpdates];
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	self.tableView.allowsSelection = NO;
	
	/* query for a ballot vote, if any */
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setFetchLimit:2];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"BallotVote" inManagedObjectContext:[ballot managedObjectContext]];
	[request setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"forBallot == %@ && forPosition == %@", ballot, position];
	[request setPredicate:predicate];
	
	NSError *error = nil;
	NSArray *array = [[ballot managedObjectContext] executeFetchRequest:request error:&error];
	if (array != nil)
	{
		NSUInteger count = [array count];
		if (count == 0)
		{
		}
		else if (count == 1)
		{
			vote = [(BallotVote *) [array objectAtIndex:0] retain];
			selectedRow = [vote.forCandidate.displayOrder integerValue];
		}
		else
		{
			NSLog(@"NOOO");
		}
	}
	else
	{
		NSLog(@"no!");
	}
	
	[request release];
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section == 0)
	{
		return position.title;
	}
	
	return nil;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (socialBallotView == YES) {
		Candidate *candidate = (Candidate *) [self.fetchedResultsController objectAtIndexPath:indexPath];
		
		/* TODO: consider caching this? */
		/* fill out the top endorsements, sorted by descending date */
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		[request setFetchLimit:3];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"FriendBallotVote" inManagedObjectContext:[ballot managedObjectContext]];
		[request setEntity:entity];
		
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"forPosition == %@ && forCandidate == %@", position, candidate];
		[request setPredicate:predicate];
		
		NSError *error = nil;
		CGFloat height = 66;
		NSUInteger count = [[ballot managedObjectContext] countForFetchRequest:request error:&error];
		if (error == nil) {
			if (count == 0) {
				height = 66;
			}
			else if (count == 1) {
				height = 103;
			}
			else if (count == 2) {
				height = 137;
			}
			else {
				height = 176;
			}
		}
		else {
			/* TODO: log error */
			NSLog(@"%@", [error userInfo]);
		}
		
		[request release];
		
		return height;
    }
	
	return 66;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"cellForRow %d", indexPath.row);
    static NSString *identifier = @"CandidateViewCell";
    CandidateViewCell *cell = (CandidateViewCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
	if (cell == nil) {
		
		NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
		
		for (id nibObject in nibObjects) {
			if ([nibObject isKindOfClass:[CandidateViewCell class]]) {
				cell = (CandidateViewCell *)nibObject;
				break;
			}
		}
	}
	
	cell.editEndorsement.tag = indexPath.row;
	cell.voteCandidate.tag = indexPath.row;
	cell.viewAllEndorsements.tag = indexPath.row;
	
	[self configureCell:cell atIndexPath:indexPath];
	
    return cell;
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
	if (vote != nil)
	{
		[vote release];
		vote = nil;
	}
}


- (void)dealloc {
	self.ballot = nil;
	self.position = nil;
	self.selectedCell = nil;
	if (vote != nil)
	{
		[vote release];
	}
	[super dealloc];
}


@end

