//
//  Election.h
//  Supervote
//
//  Created by augusto callejas on 8/26/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Position;

@interface Election :  NSManagedObject  
{
}

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet* positions;

@end


@interface Election (CoreDataGeneratedAccessors)
- (void)addPositionsObject:(Position *)value;
- (void)removePositionsObject:(Position *)value;
- (void)addPositions:(NSSet *)value;
- (void)removePositions:(NSSet *)value;

@end

