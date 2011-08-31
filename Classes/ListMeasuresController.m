//
//  ListMeasuresController.m
//  Supervote
//
//  Created by augusto callejas on 8/31/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import "ListMeasuresController.h"

#import "Measure.h"
#import "MeasureVote.h"

@implementation ListMeasuresController

@synthesize election = _election;
@synthesize ballot = _ballot;
@synthesize parentNavController = _parentNavController;

#pragma mark -
#pragma mark FetchedResultsBasedTableViewController implementation methods

- (NSString *)getEntityName{
	return @"Measure";
}

- (NSString *)getSectionNameKeyPath{
	return @"levelOrder";
}

- (NSString *)getCacheName{
	return @"ListMeasuresController";
}

- (NSArray *)allocSortDescriptors{
	NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:@"levelOrder" ascending:YES];
	NSSortDescriptor *sort2 = [[NSSortDescriptor alloc] initWithKey:@"displayOrder" ascending:YES];
    return [NSArray arrayWithObjects:sort1, sort2, nil];
}

- (NSPredicate *)getPredicate{
	return [NSPredicate predicateWithFormat:@"forElection == %@", self.election];
}

- (NSString *)getCellIdentifier{
	return @"ListMeasuresController";
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Measure *measure = (Measure *) [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = measure.title;
	
	/* TODO: break this functionality out into a method that ChooseCandidate can use, or save references? */
	/* query for a measure vote, if any */
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setFetchLimit:2];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"MeasureVote" inManagedObjectContext:self.managedObjectContext];
	[request setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"forBallot == %@ && forMeasure == %@", self.ballot, measure];
	[request setPredicate:predicate];
	
	NSError *error = nil;
	NSArray *array = [self.managedObjectContext executeFetchRequest:request error:&error];
	if (array != nil)
	{
		NSUInteger count = [array count];
		if (count == 0)
		{
			cell.detailTextLabel.text = @"<Not selected>";
		}
		else if (count == 1)
		{
			NSNumber *vote = ((MeasureVote *) [array objectAtIndex:0]).vote;
			if (vote != nil) {
				if ([vote boolValue]) {
					cell.detailTextLabel.text = @"YES";
				}
				else {
					cell.detailTextLabel.text = @"NO";
				}
			}
			else {
				cell.detailTextLabel.text = @"Undecided";
			}
		}
		else
		{
			NSLog(@"Should have only one vote!");
		}
	}
	else
	{
		/* TODO: Handle the error */
		NSLog(@"  DetailedError: %@", [error userInfo]);
	}
	
	[request release];
}


#pragma mark -
#pragma mark View lifecycle

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSString *levelOrder = [[[self.fetchedResultsController sections] objectAtIndex:section] name];
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:[NSEntityDescription entityForName:@"Measure" inManagedObjectContext:self.managedObjectContext]];
	[fetchRequest setFetchLimit:1];
	
	NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterNoStyle];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"levelOrder == %@", [numberFormatter numberFromString:levelOrder]];
	[fetchRequest setPredicate:predicate];
	
	NSString *headerTitle = @"Unknown";
	NSError *error = nil;
	NSArray *fetchResults = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if ([fetchResults count] > 0) {
		Measure *measure =  (Measure *)[fetchResults objectAtIndex:0];
		headerTitle = [[measure.level retain] autorelease];
	} else {
		/* TODO: print error? */
	}
	
	[numberFormatter release];
	[fetchRequest release];
	
	return headerTitle;
}


#pragma mark -
#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	/* TODO: VoteMeasureController */
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
	self.election = nil;
	self.ballot = nil;
	self.parentNavController = nil;
    [super dealloc];
}


@end

