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


@interface VoteMeasureController : UITableViewController <UITableViewDataSource, UITableViewDelegate, ModalViewControllerDelegate, UIActionSheetDelegate> {

@private
	BOOL socialBallotView;
	Ballot *_ballot;
	Measure *_measure;
	MeasureVote *_vote;
	BallotItemViewCell *_selectedCell;
}

@property (nonatomic, retain) Ballot *ballot;
@property (nonatomic, retain) Measure *measure;
@property (nonatomic, retain) MeasureVote *vote;
@property (nonatomic, retain) BallotItemViewCell *selectedCell;

- (IBAction)voteOnMeasure:(id)sender;
- (IBAction)viewAllEndorsements:(id)sender;
- (void)presentCreateEndorsementViewController:(NSNumber *)voteSelected;
+ (NSString *)getTextForEndorsementButton:(Measure *)aMeasure onVote:(NSNumber *)aVote;
@end
