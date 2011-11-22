//
//  Measure.h
//  Supervote
//
//  Created by augusto callejas on 11/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Election;

@interface Measure :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * levelOrder;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * level;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSNumber * displayOrder;
@property (nonatomic, retain) NSString * longDescription;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) Election * forElection;

@end



