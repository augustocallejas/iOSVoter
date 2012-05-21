//
//  GovernmentRegistration.h
//  Supervote
//
//  Created by augusto callejas on 5/20/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class DistrictRegistration;
@class Government;

@interface GovernmentRegistration :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * displayOrder;
@property (nonatomic, retain) NSDate * createdTime;
@property (nonatomic, retain) Government * government;
@property (nonatomic, retain) NSSet* registrations;

@end


@interface GovernmentRegistration (CoreDataGeneratedAccessors)
- (void)addRegistrationsObject:(DistrictRegistration *)value;
- (void)removeRegistrationsObject:(DistrictRegistration *)value;
- (void)addRegistrations:(NSSet *)value;
- (void)removeRegistrations:(NSSet *)value;

@end

