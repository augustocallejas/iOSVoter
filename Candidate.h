//
//  Candidate.h
//  Supervote
//
//  Created by augusto callejas on 1/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Position;

@interface Candidate :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * displayOrder;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) Position * position;

@end



