//
//  VoteMeasureController.h
//  Supervote
//
//  Created by augusto callejas on 9/1/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import "Ballot.h"
#import "BallotItemViewCell.h"
#import "CreateEndorsementViewController.h"
#import "Measure.h"
#import "MeasureVote.h"
#import "SupervoteClient.h"

@interface VoteMeasureController : UITableViewController <UITableViewDataSource, UITableViewDelegate, ModalViewControllerDelegate, UIActionSheetDelegate> {

@private
	BOOL socialBallotView;
	Ballot *_ballot;
	Measure *_measure;
	MeasureVote *_vote;
	SupervoteClient *_client;
}

@property (nonatomic, retain) Ballot *ballot;
@property (nonatomic, retain) Measure *measure;
@property (nonatomic, retain) MeasureVote *vote;
@property (nonatomic, retain) SupervoteClient *client;

- (void)barButtonAction:(id)sender;
- (void)setExpandBarButtonIcon;
- (IBAction)viewSingleEndorsement:(id)sender;
- (IBAction)voteOnMeasure:(id)sender;
- (IBAction)viewAllEndorsements:(id)sender;
- (void)presentCreateEndorsementViewController:(NSNumber *)voteSelected;
+ (NSString *)getTextForEndorsementButton:(Measure *)aMeasure onVote:(NSNumber *)aVote;
+ (void)displayEndorsements:(NSNumber *)aVote forMeasure:(Measure *)aMeasure onNavigationController:(UINavigationController *)navController;
+ (MeasureVote *)getMeasureVoteForBallot:(Ballot *)ballot forMeasure:(Measure *)measure withError:(NSError **)error andCount:(NSUInteger *)count;
+ (NSArray *)getMostRecentFriendEndorsements:(NSInteger)count forMeasure:(Measure *)measure withVote:(NSNumber *)vote withError:(NSError **)error;

@end
