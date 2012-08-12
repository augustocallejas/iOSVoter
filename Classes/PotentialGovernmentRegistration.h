//
//  PotentialGovernmentRegistration.h
//  Supervote
//
//  Created by augusto callejas on 8/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Government;
@class GovernmentRegistration;

@interface PotentialGovernmentRegistration :  NSManagedObject  
{
}

@property (nonatomic, retain) NSDate * createdTime;
@property (nonatomic, retain) NSSet* choices;
@property (nonatomic, retain) GovernmentRegistration * registration;

@end


@interface PotentialGovernmentRegistration (CoreDataGeneratedAccessors)
- (void)addChoicesObject:(Government *)value;
- (void)removeChoicesObject:(Government *)value;
- (void)addChoices:(NSSet *)value;
- (void)removeChoices:(NSSet *)value;

@end

