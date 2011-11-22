//
//  Candidate.h
//  Supervote
//
//  Created by augusto callejas on 11/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Position;

@interface Candidate :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * displayOrder;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSString * party;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * occupation;
@property (nonatomic, retain) Position * position;

@end



