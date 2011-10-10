//
//  CreateEndorsementViewController.h
//  Supervote
//
//  Created by augusto callejas on 9/29/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import "Candidate.h"
#import "Measure.h"

@protocol ModalViewControllerDelegate <NSObject>

- (void)didDismissModalView:(BOOL)withVote toCandidate:(Candidate *)candidate orMeasureVote:(NSNumber *)measureVote withOptionalStatement:(NSString *)statement;

@end

@interface CreateEndorsementViewController : UIViewController {
	id<ModalViewControllerDelegate> delegate;
@private
	Candidate *_candidate;
	Measure *_measure;
	NSNumber *_measureVote;
	NSString *_statement;
	IBOutlet UINavigationItem *_navItem;
	IBOutlet UITextView *_textView;
	IBOutlet UIBarButtonItem* _voteButton;
	IBOutlet UIBarButtonItem* _cancelButton;
}

@property (nonatomic, assign) id<ModalViewControllerDelegate> delegate;
@property (nonatomic, retain) Candidate *candidate;
@property (nonatomic, retain) Measure *measure;
@property (nonatomic, assign) NSNumber *measureVote;
@property (nonatomic, retain) NSString *statement;
@property (nonatomic, retain) UINavigationItem *navItem;
@property (nonatomic, retain) UITextView *textView;
@property (nonatomic, retain) UIBarButtonItem* voteButton;
@property (nonatomic, retain) UIBarButtonItem* cancelButton;

- (IBAction)dismissView:(id)sender;

@end
