//
//  DistrictType.h
//  Supervote
//
//  Created by augusto callejas on 8/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class District;
@class DistrictRegistration;
@class PotentialDistrictRegistration;

@interface DistrictType :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * displayOrder;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet* districts;
@property (nonatomic, retain) NSSet* potentialRegistrations;
@property (nonatomic, retain) NSSet* registrations;

@end


@interface DistrictType (CoreDataGeneratedAccessors)
- (void)addDistrictsObject:(District *)value;
- (void)removeDistrictsObject:(District *)value;
- (void)addDistricts:(NSSet *)value;
- (void)removeDistricts:(NSSet *)value;

- (void)addPotentialRegistrationsObject:(PotentialDistrictRegistration *)value;
- (void)removePotentialRegistrationsObject:(PotentialDistrictRegistration *)value;
- (void)addPotentialRegistrations:(NSSet *)value;
- (void)removePotentialRegistrations:(NSSet *)value;

- (void)addRegistrationsObject:(DistrictRegistration *)value;
- (void)removeRegistrationsObject:(DistrictRegistration *)value;
- (void)addRegistrations:(NSSet *)value;
- (void)removeRegistrations:(NSSet *)value;

@end

