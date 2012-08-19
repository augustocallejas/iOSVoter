//
//  Election.h
//  Supervote
//
//  Created by augusto callejas on 8/18/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Ballot;
@class Measure;
@class Position;

@interface Election :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSDate * lastFriendUpdate;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSString * icon;
@property (nonatomic, retain) NSDate * lastModified;
@property (nonatomic, retain) Ballot * ballot;
@property (nonatomic, retain) NSSet* positions;
@property (nonatomic, retain) NSSet* measures;

@end


@interface Election (CoreDataGeneratedAccessors)
- (void)addPositionsObject:(Position *)value;
- (void)removePositionsObject:(Position *)value;
- (void)addPositions:(NSSet *)value;
- (void)removePositions:(NSSet *)value;

- (void)addMeasuresObject:(Measure *)value;
- (void)removeMeasuresObject:(Measure *)value;
- (void)addMeasures:(NSSet *)value;
- (void)removeMeasures:(NSSet *)value;

@end

