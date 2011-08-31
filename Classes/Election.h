//
//  Election.h
//  Supervote
//
//  Created by augusto callejas on 8/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Position;

@interface Election :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSSet* positions;
@property (nonatomic, retain) NSSet* measures;

@end


@interface Election (CoreDataGeneratedAccessors)
- (void)addPositionsObject:(Position *)value;
- (void)removePositionsObject:(Position *)value;
- (void)addPositions:(NSSet *)value;
- (void)removePositions:(NSSet *)value;

- (void)addMeasuresObject:(NSManagedObject *)value;
- (void)removeMeasuresObject:(NSManagedObject *)value;
- (void)addMeasures:(NSSet *)value;
- (void)removeMeasures:(NSSet *)value;

@end

