//
//  FriendBallotVote.h
//  Supervote
//
//  Created by augusto callejas on 10/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Candidate;
@class Friend;
@class Position;

@interface FriendBallotVote :  NSManagedObject  
{
}

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * statement;
@property (nonatomic, retain) Friend * author;
@property (nonatomic, retain) Position * forPosition;
@property (nonatomic, retain) Candidate * forCandidate;

@end



