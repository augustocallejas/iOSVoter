//
//  ListEndorsementsController.m
//  Supervote
//
//  Created by augusto callejas on 9/28/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import "ListEndorsementsController.h"

#import "Friend.h"
#import "EndorsementViewCell.h"
#import "FriendBallotVote.h"
#import "FriendMeasureVote.h"

#define FONT_SIZE 14.0f
#define LABEL_X_POSITION 69.0f
#define LABEL_Y_POSITION 10.0f
#define LABEL_CONTENT_WIDTH 251.0f
#define LABEL_CONTENT_MARGIN 10.0f

@implementation ListEndorsementsController

@synthesize position = _position;
@synthesize candidate = _candidate;
@synthesize measure = _measure;
@synthesize vote = _vote;

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

#pragma mark -
#pragma mark FetchedResultsBasedTableViewController implementation methods

- (NSString *)getEntityName{
	if (_position != nil) {
		return @"FriendBallotVote";
	}
	
	return @"FriendMeasureVote";
}

- (NSString *)getSectionNameKeyPath{
	return nil;
}

- (NSString *)getCacheName{
	/* TODO: cache name must be different for each candidate? this may be a general issue across my controllers */
	return nil;
	//return @"ListEndorsementsController";
}

- (NSArray *)allocSortDescriptors{
	NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    return [NSArray arrayWithObject:sort];
}

- (NSPredicate *)getPredicate{
	if (_position != nil) {
		return [NSPredicate predicateWithFormat:@"forPosition == %@ and forCandidate == %@", _position, _candidate];
	}
	
	return [NSPredicate predicateWithFormat:@"forMeasure == %@ and vote == %@", _measure, _vote];
}

- (NSString *)getCellIdentifier{
	return @"ListEndorsementsController";
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	FriendBallotVote *friendBallotVote = nil;
	FriendMeasureVote *friendMeasureVote = nil;
	if (_position != nil) {
		friendBallotVote = (FriendBallotVote *) [self.fetchedResultsController objectAtIndexPath:indexPath];
	}
	else {
		friendMeasureVote = (FriendMeasureVote *) [self.fetchedResultsController objectAtIndexPath:indexPath];
	}
	
	EndorsementViewCell *endorsementCell = (EndorsementViewCell *)cell;
	if (friendBallotVote != nil) {
		endorsementCell.endorsementStatement.text = [NSString stringWithFormat:@"%@: %@", friendBallotVote.author.name, friendBallotVote.statement];
	}
	else {
		endorsementCell.endorsementStatement.text = [NSString stringWithFormat:@"%@: %@", friendMeasureVote.author.name, friendMeasureVote.statement];
	}
	
	UIImage *icon = [UIImage imageNamed:@"users.png"];
	endorsementCell.endorserIcon.image = icon;
	
	/* set the size and position of the endorsement label */
	CGSize constraint = CGSizeMake(LABEL_CONTENT_WIDTH - (LABEL_CONTENT_MARGIN * 2), 20000.0f);
	CGSize size = [endorsementCell.endorsementStatement.text sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE]
														constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
	[endorsementCell.endorsementStatement setFrame:CGRectMake(LABEL_X_POSITION,
															  LABEL_Y_POSITION,
															  LABEL_CONTENT_WIDTH - (LABEL_CONTENT_MARGIN * 2),
															  MAX(size.height, 44.0f))];
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	self.tableView.userInteractionEnabled = NO;

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

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"EndorsementViewCell";
    EndorsementViewCell *cell = (EndorsementViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
	if (cell == nil) {
		NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
		
		for (id nibObject in nibObjects) {
			if ([nibObject isKindOfClass:[UITableViewCell class]]) {
				cell = (EndorsementViewCell *)nibObject;
				break;
			}
		}
		
		// http://www.cimgf.com/2009/09/23/uitableviewcell-dynamic-height/
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
		cell.endorsementStatement = label;
		[label setLineBreakMode:UILineBreakModeWordWrap];
		[label setMinimumFontSize:FONT_SIZE];
		[label setNumberOfLines:0];
		[label setFont:[UIFont systemFontOfSize:FONT_SIZE]];
		[cell addSubview:label];
		[label release];
	}
	
	[self configureCell:cell atIndexPath:indexPath];
	
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	FriendBallotVote *friendBallotVote = nil;
	FriendMeasureVote *friendMeasureVote = nil;
	if (_position != nil) {
		friendBallotVote = (FriendBallotVote *) [self.fetchedResultsController objectAtIndexPath:indexPath];
	}
	else {
		friendMeasureVote = (FriendMeasureVote *) [self.fetchedResultsController objectAtIndexPath:indexPath];
	}

	NSString *text = friendBallotVote != nil ? friendBallotVote.statement : friendMeasureVote.statement;
	
	CGSize constraint = CGSizeMake(LABEL_CONTENT_WIDTH - (LABEL_CONTENT_MARGIN * 2), 20000.0f);
	CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
	CGFloat height = MAX(size.height, 44.0f);
	
	return height + (LABEL_CONTENT_MARGIN * 2);
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

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    // Navigation logic may go here. Create and push another view controller.
//    /*
//    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
//     // ...
//     // Pass the selected object to the new view controller.
//    [self.navigationController pushViewController:detailViewController animated:YES];
//    [detailViewController release];
//    */
//}


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
	self.position = nil;
	self.candidate = nil;
	self.measure = nil;
	self.vote = nil;
    [super dealloc];
}


@end

