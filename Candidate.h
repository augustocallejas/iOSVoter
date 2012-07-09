//
//  Candidate.h
//  Supervote
//
//  Created by augusto callejas on 7/8/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class PoliticalParty;
@class Position;

@interface Candidate :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * displayOrder;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) PoliticalParty * party;
@property (nonatomic, retain) Position * position;

@end



