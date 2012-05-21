//
//  Government.h
//  Supervote
//
//  Created by augusto callejas on 5/19/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class District;
@class GovernmentType;

@interface Government :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * shortName;
@property (nonatomic, retain) NSSet* children;
@property (nonatomic, retain) District * districts;
@property (nonatomic, retain) GovernmentType * governmentType;
@property (nonatomic, retain) Government * parent;

@end


@interface Government (CoreDataGeneratedAccessors)
- (void)addChildrenObject:(Government *)value;
- (void)removeChildrenObject:(Government *)value;
- (void)addChildren:(NSSet *)value;
- (void)removeChildren:(NSSet *)value;

@end

