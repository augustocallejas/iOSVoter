//
//  FriendBallotVote.h
//  Supervote
//
//  Created by augusto callejas on 9/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Candidate;
@class Position;

@interface FriendBallotVote :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * statement;
@property (nonatomic, retain) NSManagedObject * author;
@property (nonatomic, retain) Position * forPosition;
@property (nonatomic, retain) Candidate * forCandidate;

@end



