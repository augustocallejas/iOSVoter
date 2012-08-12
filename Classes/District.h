//
//  District.h
//  Supervote
//
//  Created by augusto callejas on 8/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class DistrictRegistration;
@class DistrictType;
@class Government;
@class PotentialDistrictRegistration;

@interface District :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * shortName;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSNumber * year;
@property (nonatomic, retain) NSString * districtDescription;
@property (nonatomic, retain) NSNumber * districtNum;
@property (nonatomic, retain) DistrictType * districtType;
@property (nonatomic, retain) NSSet* registrations;
@property (nonatomic, retain) NSSet* potentialRegistrations;
@property (nonatomic, retain) Government * inGovernment;

@end


@interface District (CoreDataGeneratedAccessors)
- (void)addRegistrationsObject:(DistrictRegistration *)value;
- (void)removeRegistrationsObject:(DistrictRegistration *)value;
- (void)addRegistrations:(NSSet *)value;
- (void)removeRegistrations:(NSSet *)value;

- (void)addPotentialRegistrationsObject:(PotentialDistrictRegistration *)value;
- (void)removePotentialRegistrationsObject:(PotentialDistrictRegistration *)value;
- (void)addPotentialRegistrations:(NSSet *)value;
- (void)removePotentialRegistrations:(NSSet *)value;

@end

