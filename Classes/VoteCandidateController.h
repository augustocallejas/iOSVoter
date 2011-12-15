//
//  VoteCandidateController.h
//  Supervote
//
//  Created by augusto callejas on 8/25/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import "Ballot.h"
#import "BallotVote.h"
#import "Candidate.h"
#import "CreateEndorsementViewController.h"
#import "FetchedResultsBasedTableViewController.h"
#import "Position.h"
#import "BallotItemViewCell.h"
#import "SupervoteClient.h"

@interface VoteCandidateController : FetchedResultsBasedTableViewController <ModalViewControllerDelegate, UIActionSheetDelegate> {

@private
	BOOL socialBallotView;
	Ballot *ballot;
	Position *position;
	BallotVote *vote;
	SupervoteClient *_client;
}

@property (nonatomic, retain) Ballot *ballot;
@property (nonatomic, retain) Position *position;
@property (nonatomic, retain) SupervoteClient *client;

+ (NSString *)getTextForEndorsementButton:(Position *)position onCandidate:(Candidate *)candidate;
+ (BallotVote *)getBallotVoteForBallot:(Ballot *)ballot forPosition:(Position *)position withError:(NSError **)error andCount:(NSUInteger *)count;
+ (void)displayEndorsements:(Candidate *)candidate forPosition:(Position *)position onNavigationController:(UINavigationController *)navController;
+ (NSArray *)getMostRecentFriendEndorsements:(NSInteger)count forPosition:(Position *)position forCandidate:(Candidate *)candidate withError:(NSError **)error;

- (IBAction)viewSingleEndorsement:(id)sender;
- (IBAction)voteOnCandidate:(id)sender;
- (IBAction)viewAllEndorsements:(id)sender;
- (void)presentCreateEndorsementViewController:(Candidate *)candidate;
@end
