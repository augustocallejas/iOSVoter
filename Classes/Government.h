//
//  Government.h
//  Supervote
//
//  Created by augusto callejas on 6/2/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class District;
@class GovernmentType;
@class PotentialGovernmentRegistration;

@interface Government :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * shortName;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Government * parent;
@property (nonatomic, retain) NSSet* children;
@property (nonatomic, retain) GovernmentType * governmentType;
@property (nonatomic, retain) NSSet* potentialGovernmentRegistrations;
@property (nonatomic, retain) NSSet* districts;

@end


@interface Government (CoreDataGeneratedAccessors)
- (void)addChildrenObject:(Government *)value;
- (void)removeChildrenObject:(Government *)value;
- (void)addChildren:(NSSet *)value;
- (void)removeChildren:(NSSet *)value;

- (void)addPotentialGovernmentRegistrationsObject:(PotentialGovernmentRegistration *)value;
- (void)removePotentialGovernmentRegistrationsObject:(PotentialGovernmentRegistration *)value;
- (void)addPotentialGovernmentRegistrations:(NSSet *)value;
- (void)removePotentialGovernmentRegistrations:(NSSet *)value;

- (void)addDistrictsObject:(District *)value;
- (void)removeDistrictsObject:(District *)value;
- (void)addDistricts:(NSSet *)value;
- (void)removeDistricts:(NSSet *)value;

@end

